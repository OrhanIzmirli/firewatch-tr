import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../services/report_spam_guard.dart';
import 'glass_panel.dart';
import 'status_chip.dart';

const int _maxPhotos = 3;

/// Presents the fire report form as a draggable, scrollable modal bottom
/// sheet anchored to the bottom of the screen (rather than a side panel),
/// so it works the same way on narrow phones as it does on tablets.
Future<void> showReportFirePanel(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => ReportFirePanel(onClose: () => Navigator.of(ctx).pop()),
  );
}

class ReportFirePanel extends StatefulWidget {
  final VoidCallback onClose;

  const ReportFirePanel({super.key, required this.onClose});

  @override
  State<ReportFirePanel> createState() => _ReportFirePanelState();
}

enum _Stage { form, success }

class _ReportFirePanelState extends State<ReportFirePanel> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final Dio _dio = Dio();
  final ImagePicker _imagePicker = ImagePicker();

  String _selectedSeverity = 'Orta';
  bool _smokeVisible = true;
  bool _windStrong = false;
  bool _nearSettlement = false;
  bool _isAnonymous = true;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;
  bool _isEncodingPhotos = false;
  double? _uploadProgress;

  double? _latitude;
  double? _longitude;
  String? _detectedCity;
  String? _detectedRegion;
  final List<XFile> _photos = [];

  _Stage _stage = _Stage.form;
  Map<String, dynamic>? _result;

  static const String _backendUrl = 'https://firewatch-tr-backend.onrender.com';

  @override
  void dispose() {
    _noteController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoadingLocation = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack(l10n.reportPanelLocationServiceOff);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showSnack(l10n.reportPanelLocationPermissionDenied);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
      await _lookupCity(position.latitude, position.longitude);
    } catch (e) {
      if (mounted) {
        _showSnack(AppLocalizations.of(context)!.reportPanelLocationError(e.toString().substring(0, 40)));
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _lookupCity(double lat, double lng) async {
    try {
      final response = await _dio.get(
        '$_backendUrl/api/fires/nearest-city',
        queryParameters: {'lat': lat, 'lng': lng},
      );
      if (response.statusCode == 200 && mounted) {
        final data = response.data['data'];
        setState(() {
          _detectedCity = data['city'];
          _detectedRegion = data['region'];
        });
      }
    } catch (_) {
      // Best-effort reverse lookup — keep whatever city/region we already had.
    }
  }

  void _onMapAdjust(LatLng point) {
    setState(() {
      _latitude = point.latitude;
      _longitude = point.longitude;
    });
    _lookupCity(point.latitude, point.longitude);
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final photo = await _imagePicker.pickImage(source: source, imageQuality: 70, maxWidth: 1600);
    if (photo != null && mounted) {
      setState(() => _photos.add(photo));
    }
  }

  void _showPhotoSourceSheet() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: Text(l10n.reportPanelPhotoSourceCamera),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(l10n.reportPanelPhotoSourceGallery),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _severityLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'Düşük': return l10n.commonLow;
      case 'Yüksek': return l10n.commonHigh;
      default: return l10n.commonMedium;
    }
  }

  Future<void> _submitReport() async {
    final l10n = AppLocalizations.of(context)!;
    if (_latitude == null || _longitude == null) {
      _showSnack(l10n.reportPanelNeedLocationFirst);
      return;
    }

    final spamCheck = await ReportSpamGuard.instance.checkBeforeSubmit(_latitude!, _longitude!);
    if (spamCheck.isBlocked) {
      _showSnack(
        spamCheck.reason == ReportBlockReason.duplicateLocation
            ? l10n.reportPanelDuplicateLocationBlocked
            : l10n.reportPanelDailyLimitReached,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final extraDetails = <String>[];
      if (_smokeVisible) extraDetails.add(l10n.reportPanelSmokeObserved);
      if (_windStrong) extraDetails.add(l10n.reportPanelStrongWindPresent);
      if (_nearSettlement) extraDetails.add(l10n.reportPanelNearSettlementNote);
      if (_photos.isNotEmpty) extraDetails.add('${_photos.length} ${l10n.reportPanelPhotosLabel}');

      final description = [
        if (_noteController.text.isNotEmpty) _noteController.text,
        if (extraDetails.isNotEmpty) extraDetails.join(', '),
        l10n.reportPanelRiskLevelLine(_severityLabel(l10n, _selectedSeverity)),
      ].join('\n');

      final reporterName = !_isAnonymous && _nameController.text.isNotEmpty
          ? _nameController.text
          : l10n.commonAnonymous;

      List<String>? photosBase64;
      if (_photos.isNotEmpty) {
        setState(() => _isEncodingPhotos = true);
        photosBase64 = [
          for (final photo in _photos) base64Encode(await photo.readAsBytes()),
        ];
        if (mounted) setState(() => _isEncodingPhotos = false);
      }

      final response = await _dio.post(
        '$_backendUrl/api/fires/report',
        data: {
          'latitude': _latitude,
          'longitude': _longitude,
          'title': _detectedCity != null
              ? l10n.reportPanelCityFireReport(_detectedCity!)
              : l10n.reportPanelFireReport,
          'description': description,
          'reporter_name': reporterName,
          if (photosBase64 != null) 'photos': photosBase64,
        },
        onSendProgress: (sent, total) {
          if (total > 0 && mounted) {
            setState(() => _uploadProgress = sent / total);
          }
        },
      );

      if (response.statusCode == 200) {
        await ReportSpamGuard.instance.recordReport(_latitude!, _longitude!);
        if (mounted) {
          setState(() {
            _result = Map<String, dynamic>.from(response.data['data']);
            _stage = _Stage.success;
          });
        }
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 429) {
        _showSnack(l10n.reportPanelDuplicateLocationBlocked);
      } else {
        _showSnack(l10n.reportPanelSubmitFailed);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isEncodingPhotos = false;
          _uploadProgress = null;
        });
      }
    }
  }

  void _shareResult() {
    final l10n = AppLocalizations.of(context)!;
    final result = _result;
    if (result == null) return;
    final verified = result['verified'] as bool? ?? false;
    final text = l10n.reportPanelShareText(
      (result['city'] as String?) ?? '-',
      (result['region'] as String?) ?? '-',
      '${result['id']}',
      verified ? l10n.reportPanelSuccessVerifiedTitle : l10n.reportPanelSuccessReceivedTitle,
    );
    Share.share(text);
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final dividerColor = isDark
        ? AppColors.white.withValues(alpha: 0.14)
        : Colors.black.withValues(alpha: 0.12);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: dividerColor, borderRadius: BorderRadius.circular(2)),
                  ),
                  Expanded(
                    child: _stage == _Stage.form
                        ? _buildForm(context, scrollController, isDark)
                        : _buildSuccess(context, scrollController, isDark),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, ScrollController scrollController, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.lg, 0),
          child: Row(
            children: [
              Expanded(
                child: StatusChip(label: l10n.reportPanelNewReport, icon: Icons.edit_location_alt_rounded),
              ),
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(onPressed: widget.onClose, icon: const Icon(Icons.close_rounded)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.xl),
            children: [
              Text(l10n.reportPanelTitle,
                  style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: titleColor)),
              const SizedBox(height: AppSpacing.sm),
              Text(l10n.reportPanelSubtitle,
                  style: GoogleFonts.inter(fontSize: 14, height: 1.45, color: secondaryTextColor)),
              const SizedBox(height: AppSpacing.xl),

              // ── Konum + harita önizleme ──────────────────────────
              GlassPanel(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.reportPanelLocation, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: fieldLabelColor)),
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
                                    _detectedCity != null ? '$_detectedCity, $_detectedRegion' : l10n.reportPanelLocationObtained,
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
                      Text(l10n.reportPanelNoLocationYet, style: GoogleFonts.inter(fontSize: 13, color: secondaryTextColor)),
                    if (_latitude != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 160,
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(_latitude!, _longitude!),
                              initialZoom: 14,
                              onTap: (_, point) => _onMapAdjust(point),
                            ),
                            children: [
                              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.firewatchtr.app'),
                              MarkerLayer(markers: [
                                Marker(
                                  point: LatLng(_latitude!, _longitude!),
                                  width: 40,
                                  height: 40,
                                  child: const Icon(Icons.location_pin, color: AppColors.primary, size: 40),
                                ),
                              ]),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(l10n.reportPanelMapAdjustHint, style: GoogleFonts.inter(fontSize: 12, color: secondaryTextColor)),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _isLoadingLocation ? null : _getLocation,
                        icon: _isLoadingLocation
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.my_location_rounded),
                        label: Text(_latitude != null ? l10n.reportPanelRefreshLocation : l10n.reportPanelGetGpsLocation),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 120.ms).fadeIn(duration: 260.ms).slideY(begin: 0.06, end: 0),

              const SizedBox(height: AppSpacing.lg),

              // ── Anonim gönderim ────────────────────────────────
              GlassPanel(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isAnonymous,
                  onChanged: (v) => setState(() => _isAnonymous = v),
                  title: Text(l10n.reportPanelAnonymousToggle,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: titleColor)),
                  subtitle: Text(l10n.reportPanelAnonymousToggleSubtitle,
                      style: GoogleFonts.inter(fontSize: 12, color: secondaryTextColor)),
                ),
              ).animate(delay: 160.ms).fadeIn(duration: 260.ms).slideY(begin: 0.06, end: 0),

              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                child: !_isAnonymous
                    ? Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.lg),
                        child: _PanelField(
                          label: l10n.reportPanelYourName,
                          labelColor: fieldLabelColor,
                          child: TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: l10n.reportPanelAnonymousHint,
                              prefixIcon: const Icon(Icons.person_outline_rounded),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── Risk seviyesi (segmented) ──────────────────────
              _PanelField(
                label: l10n.reportPanelRiskLevel,
                labelColor: fieldLabelColor,
                delay: 220.ms,
                child: SizedBox(
                  height: 48,
                  child: SegmentedButton<String>(
                    segments: [
                      ButtonSegment(value: 'Düşük', label: Text(l10n.commonLow)),
                      ButtonSegment(value: 'Orta', label: Text(l10n.commonMedium)),
                      ButtonSegment(value: 'Yüksek', label: Text(l10n.commonHigh)),
                    ],
                    selected: {_selectedSeverity},
                    onSelectionChanged: (selection) => setState(() => _selectedSeverity = selection.first),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── Not (otomatik genişleyen) ───────────────────────
              _PanelField(
                label: l10n.reportPanelExtraNote,
                labelColor: fieldLabelColor,
                delay: 260.ms,
                child: TextField(
                  controller: _noteController,
                  minLines: 2,
                  maxLines: 8,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: l10n.reportPanelNoteHint,
                    alignLabelWithHint: true,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── Fotoğraflar ─────────────────────────────────────
              _PanelField(
                label: l10n.reportPanelPhotosLabel,
                labelColor: fieldLabelColor,
                delay: 300.ms,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.reportPanelPhotosHint, style: GoogleFonts.inter(fontSize: 12, color: secondaryTextColor)),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      height: 72,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (final photo in _photos)
                            Padding(
                              padding: const EdgeInsets.only(right: AppSpacing.sm),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(File(photo.path), width: 72, height: 72, fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    top: -6,
                                    right: -6,
                                    child: SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        tooltip: l10n.reportPanelRemovePhoto,
                                        icon: const Icon(Icons.cancel_rounded, size: 20),
                                        color: AppColors.danger,
                                        onPressed: () => setState(() => _photos.remove(photo)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_photos.length < _maxPhotos)
                            SizedBox(
                              width: 72,
                              height: 72,
                              child: OutlinedButton(
                                onPressed: _showPhotoSourceSheet,
                                style: OutlinedButton.styleFrom(padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                child: const Icon(Icons.add_a_photo_rounded),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── Ekstra bilgiler ──────────────────────────────────
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
                      title: Text(l10n.reportPanelSmokeSwitch,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: titleColor)),
                    ),
                    Divider(color: dividerColor),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _windStrong,
                      onChanged: (v) => setState(() => _windStrong = v),
                      title: Text(l10n.reportPanelWindSwitch,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: titleColor)),
                    ),
                    Divider(color: dividerColor),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _nearSettlement,
                      onChanged: (v) => setState(() => _nearSettlement = v),
                      title: Text(l10n.reportPanelSettlementSwitch,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: titleColor)),
                    ),
                  ],
                ),
              ).animate(delay: 340.ms).fadeIn(duration: 300.ms).slideY(begin: 0.06, end: 0),

              if (_isSubmitting && _photos.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  _isEncodingPhotos || _uploadProgress == null
                      ? l10n.reportPanelUploadingPhotos
                      : '${l10n.reportPanelUploadingPhotos} ${(_uploadProgress! * 100).round()}%',
                  style: GoogleFonts.inter(fontSize: 12, color: secondaryTextColor),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _isEncodingPhotos ? null : _uploadProgress,
                    minHeight: 6,
                    backgroundColor: dividerColor,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _isSubmitting ? null : _submitReport,
                  icon: _isSubmitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded),
                  label: Text(_isSubmitting ? l10n.reportPanelSubmitting : l10n.reportPanelSubmit),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(onPressed: widget.onClose, child: Text(l10n.commonCancel)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess(BuildContext context, ScrollController scrollController, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final titleColor = theme.textTheme.titleLarge?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final secondaryTextColor = isDark
        ? AppColors.white.withValues(alpha: 0.72)
        : Colors.black.withValues(alpha: 0.62);

    final result = _result!;
    final verified = result['verified'] as bool? ?? false;
    final id = '${result['id']}';
    final city = (result['city'] as String?) ?? '-';
    final region = (result['region'] as String?) ?? '-';
    final createdAtRaw = result['created_at'] as String?;
    String createdAtLabel = '';
    if (createdAtRaw != null) {
      final parsed = DateTime.tryParse(createdAtRaw)?.toLocal();
      if (parsed != null) {
        // Avoid DateFormat's locale-name constructor (e.g. 'tr_TR') since it
        // requires initializeDateFormatting() to have run first, which this
        // app never calls — that would throw at runtime. Plain digits need
        // no locale data.
        String two(int n) => n.toString().padLeft(2, '0');
        createdAtLabel = '${two(parsed.day)}.${two(parsed.month)} ${two(parsed.hour)}:${two(parsed.minute)}';
      }
    }

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.xl),
      children: [
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: (verified ? AppColors.success : AppColors.warning).withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              verified ? Icons.verified_rounded : Icons.hourglass_top_rounded,
              color: verified ? AppColors.success : AppColors.warning,
              size: 40,
            ),
          ),
        ).animate().scale(begin: const Offset(0.6, 0.6), end: const Offset(1, 1), curve: Curves.easeOutBack, duration: 420.ms),
        const SizedBox(height: AppSpacing.lg),
        Text(
          verified ? l10n.reportPanelSuccessVerifiedTitle : l10n.reportPanelSuccessReceivedTitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: titleColor),
        ).animate(delay: 100.ms).fadeIn(duration: 260.ms).slideY(begin: 0.08, end: 0),
        const SizedBox(height: AppSpacing.sm),
        Text(
          verified ? l10n.reportPanelSuccessVerifiedBody : l10n.reportPanelSuccessReceivedBody,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 14, height: 1.45, color: secondaryTextColor),
        ).animate(delay: 140.ms).fadeIn(duration: 260.ms).slideY(begin: 0.08, end: 0),
        const SizedBox(height: AppSpacing.xl),
        GlassPanel(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.reportPanelReportIdLabel(id), style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: titleColor)),
              const SizedBox(height: 6),
              Text('$city, $region', style: GoogleFonts.inter(fontSize: 13, color: secondaryTextColor)),
              if (createdAtLabel.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(l10n.reportPanelReportedAtLabel(createdAtLabel), style: GoogleFonts.inter(fontSize: 13, color: secondaryTextColor)),
              ],
              if ((result['photo_count'] as int? ?? 0) > 0) ...[
                const SizedBox(height: 6),
                Text(
                  l10n.reportPanelPhotosUploaded(result['photo_count'] as int),
                  style: GoogleFonts.inter(fontSize: 13, color: secondaryTextColor),
                ),
              ],
            ],
          ),
        ).animate(delay: 200.ms).fadeIn(duration: 280.ms).slideY(begin: 0.06, end: 0),
        const SizedBox(height: AppSpacing.lg),
        Text(
          verified ? l10n.reportPanelResponseTimeVerified : l10n.reportPanelResponseTimeReceived,
          style: GoogleFonts.inter(fontSize: 13, height: 1.4, color: secondaryTextColor),
        ).animate(delay: 240.ms).fadeIn(duration: 280.ms),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _shareResult,
                  icon: const Icon(Icons.share_rounded),
                  label: Text(l10n.reportPanelShare),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: SizedBox(
                height: 48,
                child: FilledButton(onPressed: widget.onClose, child: Text(l10n.reportPanelDone)),
              ),
            ),
          ],
        ).animate(delay: 280.ms).fadeIn(duration: 280.ms).slideY(begin: 0.1, end: 0),
      ],
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
