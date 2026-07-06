import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../services/offline_cache_service.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/offline_banner.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/skeleton_loader.dart';
import '../../shared/widgets/status_chip.dart';

class RiskScreen extends StatefulWidget {
  const RiskScreen({super.key});

  @override
  State<RiskScreen> createState() => _RiskScreenState();
}

class _RiskScreenState extends State<RiskScreen> {
  static const _cacheKey = 'risk_summary';

  final Dio _dio = Dio();
  List<Map<String, dynamic>> _regions = [];
  bool _loading = true;
  bool _isOffline = false;
  DateTime? _cachedAt;

  @override
  void initState() {
    super.initState();
    _loadRiskData();
  }

  Future<void> _loadRiskData() async {
    if (mounted) setState(() => _loading = true);
    try {
      final response = await _dio.get(
        'https://firewatch-tr-backend.onrender.com/api/risk/summary',
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        final regions = data.map((e) => Map<String, dynamic>.from(e)).toList();
        await OfflineCacheService.instance.save(_cacheKey, regions);
        if (mounted) setState(() {
          _regions = regions;
          _loading = false;
          _isOffline = false;
        });
      }
    } catch (_) {
      final cached = await OfflineCacheService.instance.load(_cacheKey);
      if (mounted) {
        setState(() {
          if (cached != null) {
            final (data, savedAt) = cached;
            _regions = (data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
            _cachedAt = savedAt;
            _isOffline = true;
          }
          _loading = false;
        });
      }
    }
  }

  String _displayName(AppLocalizations l10n, String region) {
    switch (region) {
      case 'Ic Anadolu': return l10n.regionIcAnadolu;
      case 'Dogu Anadolu': return l10n.regionDoguAnadolu;
      case 'Guneydogu Anadolu': return l10n.regionGuneydoguAnadolu;
      case 'Ege': return l10n.regionEge;
      case 'Akdeniz': return l10n.regionAkdeniz;
      case 'Marmara': return l10n.regionMarmara;
      case 'Karadeniz': return l10n.regionKaradeniz;
      default: return region;
    }
  }

  String _riskLevelTr(AppLocalizations l10n, String level) {
    switch (level) {
      case 'Critical': return l10n.commonCritical;
      case 'High': return l10n.commonHigh;
      case 'Medium': return l10n.commonMedium;
      default: return l10n.commonLow;
    }
  }

  String _riskNote(AppLocalizations l10n, Map<String, dynamic> region) {
    final temp = double.tryParse(region['temperature'].toString()) ?? 0;
    final hum = double.tryParse(region['humidity'].toString()) ?? 0;
    final wind = double.tryParse(region['wind_speed'].toString()) ?? 0;

    final parts = <String>[];
    if (temp >= 35) parts.add(l10n.riskNoteHighTemp(temp.toInt()));
    else if (temp >= 25) parts.add(l10n.riskNoteMildTemp(temp.toInt()));
    else parts.add(l10n.riskNoteCoolTemp(temp.toInt()));

    if (hum <= 30) parts.add(l10n.riskNoteLowHumidity(hum.toInt()));
    else if (hum <= 50) parts.add(l10n.riskNoteMediumHumidity(hum.toInt()));
    else parts.add(l10n.riskNoteHighHumidity(hum.toInt()));

    if (wind >= 30) parts.add(l10n.riskNoteStrongWind(wind.toInt()));
    else if (wind >= 15) parts.add(l10n.riskNoteMediumWind(wind.toInt()));

    return parts.join(' • ');
  }

  Map<String, dynamic>? get _highestRisk {
    if (_regions.isEmpty) return null;
    return _regions.reduce((a, b) =>
        (a['general_risk_score'] as int) > (b['general_risk_score'] as int) ? a : b);
  }

  double get _avgRisk {
    if (_regions.isEmpty) return 0;
    final total = _regions.fold<double>(0, (sum, r) => sum + (r['general_risk_score'] as int));
    return total / _regions.length;
  }

  double get _avgTemp {
    if (_regions.isEmpty) return 0;
    final total = _regions.fold<double>(0, (sum, r) => sum + (double.tryParse(r['temperature'].toString()) ?? 0));
    return total / _regions.length;
  }

  double get _avgHumidity {
    if (_regions.isEmpty) return 0;
    final total = _regions.fold<double>(0, (sum, r) => sum + (double.tryParse(r['humidity'].toString()) ?? 0));
    return total / _regions.length;
  }

  double get _avgWind {
    if (_regions.isEmpty) return 0;
    final total = _regions.fold<double>(0, (sum, r) => sum + (double.tryParse(r['wind_speed'].toString()) ?? 0));
    return total / _regions.length;
  }

  double get _avgDryness {
    if (_regions.isEmpty) return 0;
    final total = _regions.fold<double>(0, (sum, r) => sum + (double.tryParse(r['dryness_index'].toString()) ?? 0));
    return total / _regions.length;
  }

  double get _avgVegetation {
    if (_regions.isEmpty) return 0;
    final total = _regions.fold<double>(0, (sum, r) => sum + (double.tryParse(r['vegetation_density'].toString()) ?? 0));
    return total / _regions.length;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = theme.textTheme.titleLarge?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final secondaryTextColor = isDark
        ? AppColors.white.withValues(alpha: 0.74)
        : Colors.black.withValues(alpha: 0.66);
    final mutedTextColor = isDark
        ? AppColors.white.withValues(alpha: 0.58)
        : Colors.black.withValues(alpha: 0.5);

    final topRegion = _highestRisk;
    final avgRiskScore = _avgRisk.toInt();
    final overallLevel = avgRiskScore >= 75 ? l10n.commonCritical :
                         avgRiskScore >= 50 ? l10n.commonHigh :
                         avgRiskScore >= 25 ? l10n.commonMedium : l10n.commonLow;

    final chartSpots = _regions.asMap().entries.map((e) =>
        FlSpot(e.key.toDouble(), (e.value['general_risk_score'] as int).toDouble())
    ).toList();

    DateTime? lastCalculated;
    for (final region in _regions) {
      final parsed = DateTime.tryParse(region['date']?.toString() ?? '');
      if (parsed != null && (lastCalculated == null || parsed.isAfter(lastCalculated))) {
        lastCalculated = parsed;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.riskTitle, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () { setState(() => _loading = true); _loadRiskData(); },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadRiskData,
        color: AppColors.primary,
        child: _loading
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: const [SkeletonMetricGrid(count: 4), SizedBox(height: AppSpacing.xl), SkeletonListLoader(count: 3)],
            )
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isOffline && _cachedAt != null) OfflineBanner(lastUpdated: _cachedAt!),
                  GlassPanel(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatusChip(label: l10n.riskLiveView, icon: Icons.auto_graph_rounded),
                        const SizedBox(height: AppSpacing.lg),
                        Text(l10n.riskSummaryTitle,
                            style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w800, color: titleColor)),
                        if (lastCalculated != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.update_rounded, size: 14, color: mutedTextColor),
                              const SizedBox(width: 4),
                              Text(
                                l10n.fireDetailLastUpdate('${lastCalculated.day.toString().padLeft(2, '0')}.${lastCalculated.month.toString().padLeft(2, '0')}.${lastCalculated.year} ${lastCalculated.hour.toString().padLeft(2, '0')}:${lastCalculated.minute.toString().padLeft(2, '0')}'),
                                style: GoogleFonts.inter(fontSize: 12, color: mutedTextColor),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        Text(l10n.riskSummarySubtitle,
                            style: GoogleFonts.inter(fontSize: 15, height: 1.45, color: secondaryTextColor)),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            StatusChip(label: overallLevel, icon: Icons.warning_amber_rounded),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                topRegion != null
                                    ? l10n.riskHighestRisk(_displayName(l10n, topRegion['region']), topRegion['general_risk_score'])
                                    : l10n.riskDataLoading,
                                style: GoogleFonts.inter(fontSize: 14, color: secondaryTextColor),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 450.ms).scale(
                        begin: const Offset(0.97, 0.97),
                        end: const Offset(1, 1),
                        curve: Curves.easeOutCubic,
                      ).slideY(begin: 0.06, end: 0),

                  const SizedBox(height: AppSpacing.xxl),

                  SectionHeader(
                    title: l10n.riskKeyIndicators,
                    subtitle: l10n.riskTurkeyAverage,
                    icon: Icons.dashboard_rounded,
                  ).animate(delay: 80.ms).fadeIn(duration: 280.ms).slideX(begin: -0.03, end: 0),

                  const SizedBox(height: AppSpacing.md),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 1.15,
                    children: [
                      _RiskMetricCard(
                        title: l10n.riskGeneralRisk,
                        value: '$avgRiskScore',
                        subtitle: l10n.riskOutOf100,
                        icon: Icons.local_fire_department_rounded,
                        accent: avgRiskScore >= 50 ? AppColors.danger : AppColors.warning,
                        delay: const Duration(milliseconds: 140),
                      ),
                      _RiskMetricCard(
                        title: l10n.commonWind,
                        value: '${_avgWind.toInt()} km/h',
                        subtitle: _avgWind >= 30 ? l10n.riskWindIncreasesSpread : l10n.riskWindNormal,
                        icon: Icons.air_rounded,
                        accent: AppColors.warning,
                        delay: const Duration(milliseconds: 220),
                      ),
                      _RiskMetricCard(
                        title: l10n.riskHumidity,
                        value: '%${_avgHumidity.toInt()}',
                        subtitle: _avgHumidity <= 30 ? l10n.riskHumidityLow : _avgHumidity <= 50 ? l10n.riskHumidityMedium : l10n.riskHumidityHigh,
                        icon: Icons.water_drop_outlined,
                        accent: AppColors.primary,
                        delay: const Duration(milliseconds: 300),
                      ),
                      _RiskMetricCard(
                        title: l10n.commonTemperature,
                        value: '${_avgTemp.toInt()}°C',
                        subtitle: _avgTemp >= 35 ? l10n.riskTempCritical : _avgTemp >= 25 ? l10n.commonHigh : l10n.riskTempNormal,
                        icon: Icons.thermostat_rounded,
                        accent: _avgTemp >= 35 ? AppColors.danger : AppColors.warning,
                        delay: const Duration(milliseconds: 380),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xxxl),

                  if (chartSpots.isNotEmpty) ...[
                    SectionHeader(
                      title: l10n.riskRegionalDistribution,
                      subtitle: l10n.riskRegionalDistributionSubtitle,
                      icon: Icons.show_chart_rounded,
                    ).animate(delay: 140.ms).fadeIn(duration: 280.ms).slideX(begin: -0.03, end: 0),

                    const SizedBox(height: AppSpacing.md),

                    GlassPanel(
                      child: SizedBox(
                        height: 260,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.riskScore,
                                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: titleColor)),
                            const SizedBox(height: AppSpacing.lg),
                            Expanded(
                              child: LineChart(
                                LineChartData(
                                  minY: 0,
                                  maxY: 100,
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: 25,
                                    getDrawingHorizontalLine: (value) => FlLine(
                                      color: isDark
                                          ? AppColors.white.withValues(alpha: 0.08)
                                          : Colors.black.withValues(alpha: 0.08),
                                      strokeWidth: 1,
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 25,
                                        reservedSize: 34,
                                        getTitlesWidget: (value, meta) => Text(
                                          value.toInt().toString(),
                                          style: GoogleFonts.inter(fontSize: 11, color: mutedTextColor),
                                        ),
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 28,
                                        getTitlesWidget: (value, meta) {
                                          final idx = value.toInt();
                                          if (idx < 0 || idx >= _regions.length) return const SizedBox.shrink();
                                          final name = _displayName(l10n, _regions[idx]['region']);
                                          final short = name.length > 4 ? name.substring(0, 4) : name;
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(short,
                                                style: GoogleFonts.inter(fontSize: 10, color: mutedTextColor)),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: chartSpots,
                                      isCurved: true,
                                      color: AppColors.primary,
                                      barWidth: 3,
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primary.withValues(alpha: 0.24),
                                            AppColors.primary.withValues(alpha: 0.02),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                      dotData: FlDotData(
                                        show: true,
                                        getDotPainter: (spot, percent, barData, index) =>
                                            FlDotCirclePainter(
                                          radius: 4.5,
                                          color: AppColors.primary,
                                          strokeWidth: 2,
                                          strokeColor: isDark ? AppColors.surface : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate(delay: 220.ms).fadeIn(duration: 500.ms).slideY(begin: 0.08, end: 0),
                            ),
                          ],
                        ),
                      ),
                    ).animate(delay: 180.ms).fadeIn(duration: 380.ms).scale(
                          begin: const Offset(0.98, 0.98),
                          end: const Offset(1, 1),
                        ),

                    const SizedBox(height: AppSpacing.xxxl),
                  ],

                  SectionHeader(
                    title: l10n.riskRegionDetails,
                    subtitle: l10n.riskRegionDetailsSubtitle,
                    icon: Icons.public_rounded,
                  ).animate(delay: 200.ms).fadeIn(duration: 280.ms).slideX(begin: -0.03, end: 0),

                  const SizedBox(height: AppSpacing.md),

                  ..._regions.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final region = entry.value;
                    final score = region['general_risk_score'] as int;
                    final level = region['risk_level'] as String;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _RegionRiskCard(
                        region: _displayName(l10n, region['region']),
                        risk: _riskLevelTr(l10n, level),
                        rawLevel: level,
                        score: score,
                        note: _riskNote(l10n, region),
                        delay: Duration(milliseconds: 240 + (idx * 70)),
                      ),
                    );
                  }),

                  const SizedBox(height: AppSpacing.xxxl),

                  SectionHeader(
                    title: l10n.riskEnvironmentalFactors,
                    subtitle: l10n.riskTurkeyAverage,
                    icon: Icons.eco_outlined,
                  ).animate(delay: 240.ms).fadeIn(duration: 280.ms).slideX(begin: -0.03, end: 0),

                  const SizedBox(height: AppSpacing.md),

                  _ProgressFactorCard(
                    title: l10n.riskDrynessIndex,
                    value: _avgDryness / 100,
                    label: _avgDryness >= 70 ? l10n.riskDrynessVeryHigh : _avgDryness >= 50 ? l10n.commonHigh : l10n.commonMedium,
                    color: AppColors.danger,
                    delay: const Duration(milliseconds: 280),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ProgressFactorCard(
                    title: l10n.riskWindPressure,
                    value: (_avgWind / 80).clamp(0, 1),
                    label: _avgWind >= 50 ? l10n.commonHigh : _avgWind >= 25 ? l10n.commonMedium : l10n.commonLow,
                    color: AppColors.warning,
                    delay: const Duration(milliseconds: 350),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ProgressFactorCard(
                    title: l10n.riskVegetationDensity,
                    value: _avgVegetation / 100,
                    label: _avgVegetation >= 60 ? l10n.riskVegetationMediumHigh : l10n.commonMedium,
                    color: AppColors.primary,
                    delay: const Duration(milliseconds: 420),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ProgressFactorCard(
                    title: l10n.riskHumidityLevel,
                    value: (_avgHumidity / 100).clamp(0, 1),
                    label: _avgHumidity >= 60 ? l10n.commonHigh : _avgHumidity >= 40 ? l10n.commonMedium : l10n.commonLow,
                    color: AppColors.success,
                    delay: const Duration(milliseconds: 490),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
      ),
    );
  }
}

class _RiskMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Duration delay;

  const _RiskMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accent,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final valueColor = Theme.of(context).textTheme.titleLarge?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final titleColor = Theme.of(context).textTheme.titleMedium?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final subtitleColor = isDark
        ? AppColors.white.withValues(alpha: 0.58)
        : Colors.black.withValues(alpha: 0.5);

    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const Spacer(),
          Text(value,
              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: valueColor)),
          const SizedBox(height: AppSpacing.xs),
          Text(title,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: titleColor)),
          const SizedBox(height: 2),
          Text(subtitle,
              style: GoogleFonts.inter(fontSize: 12, color: subtitleColor)),
        ],
      ),
    ).animate(delay: delay).fadeIn(duration: 300.ms).slideY(begin: 0.12, end: 0).scale(
          begin: const Offset(0.97, 0.97),
          end: const Offset(1, 1),
        );
  }
}

class _RegionRiskCard extends StatelessWidget {
  final String region;
  final String risk;
  final String rawLevel;
  final int score;
  final String note;
  final Duration delay;

  const _RegionRiskCard({
    required this.region,
    required this.risk,
    required this.rawLevel,
    required this.score,
    required this.note,
    this.delay = Duration.zero,
  });

  Color get accent {
    switch (rawLevel) {
      case 'Critical': return AppColors.danger;
      case 'High': return AppColors.danger;
      case 'Medium': return AppColors.warning;
      default: return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = Theme.of(context).textTheme.titleMedium?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final noteColor = isDark
        ? AppColors.white.withValues(alpha: 0.58)
        : Colors.black.withValues(alpha: 0.5);

    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(region,
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: titleColor)),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusChip(label: risk, icon: Icons.warning_amber_rounded),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 10,
              backgroundColor: isDark
                  ? AppColors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.riskScoreOutOf100(score),
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: accent)),
          const SizedBox(height: 4),
          Text(note,
              style: GoogleFonts.inter(fontSize: 12, height: 1.35, color: noteColor)),
        ],
      ),
    ).animate(delay: delay).fadeIn(duration: 280.ms).slideX(begin: 0.03, end: 0).scale(
          begin: const Offset(0.98, 0.98),
          end: const Offset(1, 1),
        );
  }
}

class _ProgressFactorCard extends StatelessWidget {
  final String title;
  final double value;
  final String label;
  final Color color;
  final Duration delay;

  const _ProgressFactorCard({
    required this.title,
    required this.value,
    required this.label,
    required this.color,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = Theme.of(context).textTheme.titleMedium?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final labelColor = isDark
        ? AppColors.white.withValues(alpha: 0.62)
        : Colors.black.withValues(alpha: 0.56);

    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: titleColor)),
              ),
              Text('${(value * 100).toInt()}%',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor: isDark
                  ? AppColors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: labelColor)),
        ],
      ),
    ).animate(delay: delay).fadeIn(duration: 280.ms).slideY(begin: 0.12, end: 0).scale(
          begin: const Offset(0.98, 0.98),
          end: const Offset(1, 1),
        );
  }
}