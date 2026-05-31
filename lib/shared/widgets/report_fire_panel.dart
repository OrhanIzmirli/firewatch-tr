import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import 'glass_panel.dart';
import 'status_chip.dart';

class ReportFirePanel extends StatefulWidget {
  final VoidCallback onClose;

  const ReportFirePanel({super.key, required this.onClose});

  @override
  State<ReportFirePanel> createState() => _ReportFirePanelState();
}

class _ReportFirePanelState extends State<ReportFirePanel> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final Dio _dio = Dio();

  String _selectedSeverity = 'Orta';
  bool _smokeVisible = true;
  bool _windStrong = false;
  bool _nearSettlement = false;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;

  double? _latitude;
  double? _longitude;
  String? _detectedCity;
  String? _detectedRegion;

  static const String _backendUrl = 'https://firewatch-tr-backend.onrender.com';

  @override
  void dispose() {
    _noteController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack('Konum servisi kapalı. Lütfen açın.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showSnack('Konum izni verilmedi.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      // PostGIS ile şehir bul
      final response = await _dio.get(
        '$_backendUrl/api/fires/nearest-city',
        queryParameters: {'lat': position.latitude, 'lng': position.longitude},
      );
      if (response.statusCode == 200) {
        final data = response.data['data'];
        setState(() {
          _detectedCity = data['city'];
          _detectedRegion = data['region'];
        });
      }
    } catch (e) {
      _showSnack('Konum alınamadı: ${e.toString().substring(0, 40)}');
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _submitReport() async {
    if (_latitude == null || _longitude == null) {
      _showSnack('Lütfen önce konumunuzu alın.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final extraDetails = <String>[];
      if (_smokeVisible) extraDetails.add('Yoğun duman gözlemlendi');
      if (_windStrong) extraDetails.add('Güçlü rüzgar mevcut');
      if (_nearSettlement) extraDetails.add('Yerleşim alanına yakın');

      final description = [
        if (_noteController.text.isNotEmpty) _noteController.text,
        if (extraDetails.isNotEmpty) extraDetails.join(', '),
        'Risk seviyesi: $_selectedSeverity',
      ].join('\n');

      final response = await _dio.post(
        '$_backendUrl/api/fires/report',
        data: {
          'latitude': _latitude,
          'longitude': _longitude,
          'title': _detectedCity != null
              ? '$_detectedCity yangın bildirimi'
              : 'Yangın bildirimi',
          'description': description,
          'reporter_name': _nameController.text.isNotEmpty
              ? _nameController.text
              : 'Anonim',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final verified = data['verified'] as bool;
        final message = data['message'] as String;
        final city = data['city'] as String;

        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1A1A2E)
                  : Colors.white,
              title: Text(
                verified ? '✅ Rapor Doğrulandı' : '⏳ Rapor Alındı',
                style: GoogleFonts.inter(fontWeight: FontWeight.w800),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Şehir: $city', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(message, style: GoogleFonts.inter(fontSize: 13, height: 1.4)),
                ],
              ),
              actions: [
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onClose();
                  },
                  child: const Text('Tamam'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      _showSnack('Rapor gönderilemedi. İnternet bağlantınızı kontrol edin.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: GoogleFonts.inter())),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = theme.textTheme.titleLarge?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final secondaryTextColor = isDark
        ? AppColors.white.withValues(alpha: 0.72)
        : Colors.black.withValues(alpha: 0.62);
    final fieldLabelColor = isDark
        ? AppColors.white.withValues(alpha: 0.78)
        : Colors.black.withValues(alpha: 0.62);
    final dividerColor = isDark
        ? AppColors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.06);

    return SafeArea(
      child: GlassPanel(
        padding: const EdgeInsets.all(AppSpacing.xl),
        radius: 28,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: StatusChip(label: 'Yeni Bildirim', icon: Icons.edit_location_alt_rounded),
                ).animate().fadeIn(duration: 280.ms).slideX(begin: -0.04, end: 0),
                IconButton(onPressed: widget.onClose, icon: const Icon(Icons.close_rounded))
                    .animate(delay: 60.ms).fadeIn(duration: 240.ms).scale(
                      begin: const Offset(0.85, 0.85), end: const Offset(1, 1), curve: Curves.easeOutBack),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Yangın Raporla',
                style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: titleColor))
                .animate(delay: 80.ms).fadeIn(duration: 280.ms).slideY(begin: 0.08, end: 0),
            const SizedBox(height: AppSpacing.sm),
            Text('GPS ile konumunuzu alın ve yangını bildirin. NASA verisiyle otomatik doğrulanacak.',
                style: GoogleFonts.inter(fontSize: 14, height: 1.45, color: secondaryTextColor))
                .animate(delay: 140.ms).fadeIn(duration: 280.ms).slideY(begin: 0.08, end: 0),
            const SizedBox(height: AppSpacing.xl),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ── Konum Butonu ──────────────────────────────
                    GlassPanel(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Konum', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: fieldLabelColor)),
                          const SizedBox(height: AppSpacing.sm),
                          if (_latitude != null)
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on_rounded, color: AppColors.success, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _detectedCity != null ? '$_detectedCity, $_detectedRegion' : 'Konum alındı',
                                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: titleColor),
                                        ),
                                        Text(
                                          '${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
                                          style: GoogleFonts.inter(fontSize: 12, color: secondaryTextColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Text('Henüz konum alınmadı', style: GoogleFonts.inter(fontSize: 13, color: secondaryTextColor)),
                          const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _isLoadingLocation ? null : _getLocation,
                              icon: _isLoadingLocation
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.my_location_rounded),
                              label: Text(_latitude != null ? 'Konumu Yenile' : 'GPS ile Konum Al'),
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 180.ms).fadeIn(duration: 280.ms).slideY(begin: 0.08, end: 0),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Risk Seviyesi ──────────────────────────────
                    _PanelField(
                      label: 'Risk Seviyesi',
                      labelColor: fieldLabelColor,
                      delay: 250.ms,
                      child: DropdownButtonFormField<String>(
                        value: _selectedSeverity,
                        items: const [
                          DropdownMenuItem(value: 'Düşük', child: Text('Düşük')),
                          DropdownMenuItem(value: 'Orta', child: Text('Orta')),
                          DropdownMenuItem(value: 'Yüksek', child: Text('Yüksek')),
                        ],
                        onChanged: (value) { if (value != null) setState(() => _selectedSeverity = value); },
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── İsim ──────────────────────────────────────
                    _PanelField(
                      label: 'Adınız (isteğe bağlı)',
                      labelColor: fieldLabelColor,
                      delay: 290.ms,
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Anonim olarak gönderilecek',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Not ───────────────────────────────────────
                    _PanelField(
                      label: 'Ek Not',
                      labelColor: fieldLabelColor,
                      delay: 320.ms,
                      child: TextField(
                        controller: _noteController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Alev yüksekliği, duman yoğunluğu, yol durumu...',
                          alignLabelWithHint: true,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Ekstra Bilgiler ───────────────────────────
                    GlassPanel(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      color: isDark
                          ? AppColors.white.withValues(alpha: 0.03)
                          : Colors.black.withValues(alpha: 0.02),
                      child: Column(
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _smokeVisible,
                            onChanged: (v) => setState(() => _smokeVisible = v),
                            title: Text('Yoğun duman gözleniyor',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: titleColor)),
                          ),
                          Divider(color: dividerColor),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _windStrong,
                            onChanged: (v) => setState(() => _windStrong = v),
                            title: Text('Rüzgar güçlü görünüyor',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: titleColor)),
                          ),
                          Divider(color: dividerColor),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _nearSettlement,
                            onChanged: (v) => setState(() => _nearSettlement = v),
                            title: Text('Yerleşim alanına yakın',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: titleColor)),
                          ),
                        ],
                      ),
                    ).animate(delay: 390.ms).fadeIn(duration: 320.ms).slideY(begin: 0.08, end: 0).scale(
                          begin: const Offset(0.98, 0.98), end: const Offset(1, 1)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSubmitting ? null : _submitReport,
                icon: _isSubmitting
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded),
                label: Text(_isSubmitting ? 'Gönderiliyor...' : 'Bildirimi Gönder'),
              ),
            ).animate(delay: 460.ms).fadeIn(duration: 280.ms).slideY(begin: 0.16, end: 0).scale(
                  begin: const Offset(0.97, 0.97), end: const Offset(1, 1)),

            const SizedBox(height: AppSpacing.md),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(onPressed: widget.onClose, child: const Text('Vazgeç')),
            ).animate(delay: 530.ms).fadeIn(duration: 280.ms).slideY(begin: 0.16, end: 0).scale(
                  begin: const Offset(0.97, 0.97), end: const Offset(1, 1)),
          ],
        ),
      ).animate().fadeIn(duration: 260.ms).slideX(begin: 0.12, end: 0).scale(
            begin: const Offset(0.99, 0.99), end: const Offset(1, 1)),
    );
  }
}

class _PanelField extends StatelessWidget {
  final String label;
  final Widget child;
  final Duration delay;
  final Color labelColor;

  const _PanelField({
    required this.label,
    required this.child,
    required this.labelColor,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: labelColor)),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    ).animate(delay: delay).fadeIn(duration: 280.ms).slideY(begin: 0.08, end: 0).scale(
          begin: const Offset(0.98, 0.98), end: const Offset(1, 1));
  }
}