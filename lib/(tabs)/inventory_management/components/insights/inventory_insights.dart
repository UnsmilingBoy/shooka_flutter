import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/services/providers/inventory_provider.dart';

/// Second tab of inventory management: server-driven stats & charts.
///
/// Data sources (project: teska-hirkan):
/// - POST /api/wms/stats/summary/  {project_name}
/// - POST /api/wms/stats/chart/    {project_name, mode: month|destination}
///
/// Nothing on this page is derived from locally loaded forms; every number
/// comes from the two endpoints above.
class InventoryInsights extends StatefulWidget {
  const InventoryInsights({super.key});

  @override
  State<InventoryInsights> createState() => _InventoryInsightsState();
}

class _InventoryInsightsState extends State<InventoryInsights> {
  static const _projectName = 'teska-hirkan';

  bool _loading = true;
  String? _error;

  _SummaryData? _summary;
  List<_MonthPoint> _months = [];
  List<_DestPoint> _destinations = [];

  int _touchedMonthBar = -1;
  int _touchedDestBar = -1;
  int _touchedPie = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<InventoryProvider>().api;
      final results = await Future.wait([
        api.fetchInventoryStatsSummary(projectName: _projectName),
        api.fetchInventoryStatsChart(projectName: _projectName, mode: 'month'),
        api.fetchInventoryStatsChart(
          projectName: _projectName,
          mode: 'destination',
        ),
      ]);
      if (!mounted) return;
      final summary = _SummaryData.fromJson(results[0]);
      final months = _parseMonths(results[1]);
      final dests = _parseDestinations(results[2]);
      setState(() {
        _summary = summary;
        _months = months;
        _destinations = dests;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _LoadingState();
    if (_error != null || _summary == null) {
      return _ErrorState(
        message: _error ?? 'خطا در دریافت آمار',
        onRetry: _loadAll,
      );
    }
    final summary = _summary!;
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 900;
                final monthCard = _MonthTrendCard(
                  months: _months,
                  touchedBar: _touchedMonthBar,
                  onBarTouched: (i) => setState(() => _touchedMonthBar = i),
                );
                final destCard = _DestinationTrendCard(
                  destinations: _destinations,
                  touchedBar: _touchedDestBar,
                  onBarTouched: (i) => setState(() => _touchedDestBar = i),
                );
                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: monthCard),
                      const SizedBox(width: 12),
                      Expanded(child: destCard),
                    ],
                  );
                }
                return Column(
                  children: [monthCard, const SizedBox(height: 12), destCard],
                );
              },
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 760;
                final donut = _DeviceStatusCard(
                  summary: summary,
                  touchedIndex: _touchedPie,
                  onPieTouched: (i) => setState(() => _touchedPie = i),
                );
                final topItems = _TopItemsCard(summary: summary);
                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: donut),
                      const SizedBox(width: 12),
                      Expanded(child: topItems),
                    ],
                  );
                }
                return Column(
                  children: [donut, const SizedBox(height: 12), topItems],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data models (parsed defensively; server shapes may evolve)
// ---------------------------------------------------------------------------

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse('$value') ?? 0;
}

List<_MonthPoint> _parseMonths(Map<String, dynamic> payload) {
  final raw = payload['results'];
  if (raw is! List) return [];
  final points = <_MonthPoint>[];
  for (final row in raw) {
    if (row is! Map) continue;
    final map = Map<String, dynamic>.from(row);
    final monthKey = (map['month'] ?? map['label'] ?? map['name'] ?? '')
        .toString();
    final devices = _asInt(map['devices'] ?? map['count'] ?? map['total']);
    if (monthKey.isEmpty) continue;
    points.add(_MonthPoint(key: monthKey, devices: devices));
  }
  points.sort((a, b) => a.key.compareTo(b.key));
  return points;
}

List<_DestPoint> _parseDestinations(Map<String, dynamic> payload) {
  final raw = payload['results'];
  if (raw is! List) return [];
  final points = <_DestPoint>[];
  for (final row in raw) {
    if (row is! Map) continue;
    final map = Map<String, dynamic>.from(row);
    final label =
        (map['destination'] ??
                map['month'] ??
                map['label'] ??
                map['name'] ??
                map['title'] ??
                '')
            .toString()
            .trim();
    final devices = _asInt(map['devices'] ?? map['count'] ?? map['total']);
    if (label.isEmpty) continue;
    points.add(_DestPoint(label: label, devices: devices));
  }
  points.sort((a, b) => b.devices.compareTo(a.devices));
  return points;
}

class _MonthPoint {
  final String key; // e.g. 1405-06
  final int devices;
  const _MonthPoint({required this.key, required this.devices});

  int get monthNumber {
    final parts = key.split('-');
    if (parts.length == 2) return int.tryParse(parts[1]) ?? 0;
    return 0;
  }

  String get year => key.split('-').firstOrNull ?? '';
}

class _DestPoint {
  final String label;
  final int devices;
  const _DestPoint({required this.label, required this.devices});
}

class _DeviceStats {
  final int total;
  final int sent;
  final int installed;
  final int returned;
  final int settled;
  final int representativesSettled;
  final int inStock;

  const _DeviceStats({
    required this.total,
    required this.sent,
    required this.installed,
    required this.returned,
    required this.settled,
    required this.representativesSettled,
    required this.inStock,
  });

  factory _DeviceStats.fromJson(Map<String, dynamic> json) => _DeviceStats(
    total: _asInt(json['total']),
    sent: _asInt(json['sent']),
    installed: _asInt(json['installed']),
    returned: _asInt(json['returned']),
    settled: _asInt(json['settled']),
    representativesSettled: _asInt(json['representatives_settled']),
    inStock: _asInt(json['in_stock']),
  );

  /// Devices sent but neither installed, returned nor in stock.
  int get inCirculation =>
      (total - installed - returned - inStock).clamp(0, 1 << 30);
}

class _DeviceTypeStats extends _DeviceStats {
  final String name;
  final String label;
  const _DeviceTypeStats({
    required this.name,
    required this.label,
    required super.total,
    required super.sent,
    required super.installed,
    required super.returned,
    required super.settled,
    required super.representativesSettled,
    required super.inStock,
  });

  factory _DeviceTypeStats.fromJson(Map<String, dynamic> json) =>
      _DeviceTypeStats(
        name: (json['device_type__name'] ?? '').toString(),
        label: (json['device_type__label'] ?? json['device_type__name'] ?? '')
            .toString(),
        total: _asInt(json['total']),
        sent: _asInt(json['sent']),
        installed: _asInt(json['installed']),
        returned: _asInt(json['returned']),
        settled: _asInt(json['settled']),
        representativesSettled: _asInt(json['representatives_settled']),
        inStock: _asInt(json['in_stock']),
      );
}

class _ItemTypeStats {
  final String name;
  final int sent;
  final int returned;
  final int net;
  const _ItemTypeStats({
    required this.name,
    required this.sent,
    required this.returned,
    required this.net,
  });

  factory _ItemTypeStats.fromJson(Map<String, dynamic> json) {
    final sent = _asInt(json['sent']);
    final returned = _asInt(json['returned']);
    return _ItemTypeStats(
      name: (json['item_type'] ?? json['name'] ?? '—').toString(),
      sent: sent,
      returned: returned,
      net: json.containsKey('net') ? _asInt(json['net']) : sent - returned,
    );
  }
}

class _SummaryData {
  final _DeviceStats devices;
  final List<_DeviceTypeStats> devicesByType;
  final int formsTotal;
  final int formsDispatched;
  final int formsReturned;
  final int itemsSent;
  final int itemsReturned;
  final int itemsNet;
  final List<_ItemTypeStats> itemsByType;
  final int deviceReturns;
  final int settlements;

  const _SummaryData({
    required this.devices,
    required this.devicesByType,
    required this.formsTotal,
    required this.formsDispatched,
    required this.formsReturned,
    required this.itemsSent,
    required this.itemsReturned,
    required this.itemsNet,
    required this.itemsByType,
    required this.deviceReturns,
    required this.settlements,
  });

  factory _SummaryData.fromJson(Map<String, dynamic> json) {
    final devicesJson = json['devices'] is Map
        ? Map<String, dynamic>.from(json['devices'] as Map)
        : <String, dynamic>{};
    final formsJson = json['forms'] is Map
        ? Map<String, dynamic>.from(json['forms'] as Map)
        : <String, dynamic>{};
    final itemsJson = json['items'] is Map
        ? Map<String, dynamic>.from(json['items'] as Map)
        : <String, dynamic>{};
    final byTypeRaw = itemsJson['by_type'];
    return _SummaryData(
      devices: _DeviceStats.fromJson(devicesJson),
      devicesByType: json['devices_by_type'] is List
          ? (json['devices_by_type'] as List)
                .whereType<Map>()
                .map(
                  (e) =>
                      _DeviceTypeStats.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const [],
      formsTotal: _asInt(formsJson['total']),
      formsDispatched: _asInt(formsJson['dispatched']),
      formsReturned: _asInt(formsJson['returned']),
      itemsSent: _asInt(itemsJson['sent']),
      itemsReturned: _asInt(itemsJson['returned']),
      itemsNet: itemsJson.containsKey('net')
          ? _asInt(itemsJson['net'])
          : _asInt(itemsJson['sent']) - _asInt(itemsJson['returned']),
      itemsByType: byTypeRaw is List
          ? (byTypeRaw)
                .whereType<Map>()
                .map(
                  (e) => _ItemTypeStats.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const [],
      deviceReturns: _asInt(json['device_returns']),
      settlements: _asInt(json['settlements']),
    );
  }
}

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

const _kBlue = Color(0xFF2E7CF6);
const _kTeal = Color(0xFF12A48A);
const _kAmber = Color(0xFFC98A0A);
const _kRose = Color(0xFFE05252);
const _kViolet = Color(0xFF7B7CF8);
const _kSlate = Color(0xFF64748B);

const _kMonthNames = <int, String>{
  1: 'فروردین',
  2: 'اردیبهشت',
  3: 'خرداد',
  4: 'تیر',
  5: 'مرداد',
  6: 'شهریور',
  7: 'مهر',
  8: 'آبان',
  9: 'آذر',
  10: 'دی',
  11: 'بهمن',
  12: 'اسفند',
};

const _kMonthShort = <int, String>{
  1: 'فرو',
  2: 'ارد',
  3: 'خرد',
  4: 'تیر',
  5: 'مرد',
  6: 'شهر',
  7: 'مهر',
  8: 'آبا',
  9: 'آذر',
  10: 'دی',
  11: 'بهم',
  12: 'اسف',
};

String _fmt(int value) {
  final negative = value < 0;
  final digits = value.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final pos = digits.length - i;
    buf.write(digits[i]);
    if (pos > 1 && pos % 3 == 1) buf.write(',');
  }
  return negative ? '-${buf.toString()}' : buf.toString();
}

String _pct(int part, int total) {
  if (total <= 0) return '۰٪';
  final p = (part * 100 / total).round().clamp(0, 100);
  return '$p٪';
}

// ---------------------------------------------------------------------------
// Page chrome: loading / error / generic card (borderless, like operations tab)
// ---------------------------------------------------------------------------

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          for (var i = 0; i < 3; i++) ...[
            Container(
              height: i == 1 ? 250 : 120,
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: i == 0
                    ? const SizedBox.square(
                        dimension: 26,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            'در حال دریافت آمار انبار…',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: scheme.error.withValues(alpha: .1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_outlined,
                color: scheme.error,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'دریافت آمار ناموفق بود',
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('تلاش مجدد'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  const _CardHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: .13),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: accent),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: text.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Trend chart cards (month + destination side by side) — fl_chart
// ---------------------------------------------------------------------------

class _MonthTrendCard extends StatelessWidget {
  final List<_MonthPoint> months;
  final int touchedBar;
  final ValueChanged<int> onBarTouched;
  const _MonthTrendCard({
    required this.months,
    required this.touchedBar,
    required this.onBarTouched,
  });

  @override
  Widget build(BuildContext context) {
    final total = months.fold<int>(0, (s, e) => s + e.devices);
    final peak = months.isEmpty
        ? null
        : months.reduce((a, b) => a.devices >= b.devices ? a : b);
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            title: 'روند ارسال دستگاه',
            subtitle: 'به تفکیک ماه سال جاری',
            icon: Icons.bar_chart_rounded,
            accent: _kBlue,
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChipInfo(
                label: 'مجموع',
                value: _fmt(total),
                icon: Icons.functions_rounded,
              ),
              if (peak != null && peak.devices > 0)
                _ChipInfo(
                  label: 'اوج: ${_kMonthNames[peak.monthNumber] ?? peak.key}',
                  value: _fmt(peak.devices),
                  icon: Icons.trending_up_rounded,
                ),
            ],
          ),
          const SizedBox(height: 14),
          _MonthBarChart(
            months: months,
            touchedBar: touchedBar,
            onTouched: onBarTouched,
          ),
        ],
      ),
    );
  }
}

class _DestinationTrendCard extends StatelessWidget {
  final List<_DestPoint> destinations;
  final int touchedBar;
  final ValueChanged<int> onBarTouched;
  const _DestinationTrendCard({
    required this.destinations,
    required this.touchedBar,
    required this.onBarTouched,
  });

  @override
  Widget build(BuildContext context) {
    final total = destinations.fold<int>(0, (s, e) => s + e.devices);
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            title: 'ارسال به تفکیک مقصد',
            subtitle: '۱۰ مقصد اول',
            icon: Icons.location_on_outlined,
            accent: _kTeal,
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChipInfo(
                label: 'مجموع',
                value: _fmt(total),
                icon: Icons.functions_rounded,
              ),
              _ChipInfo(
                label: 'مقصد',
                value: '${destinations.length}',
                icon: Icons.location_on_outlined,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _DestinationBarChart(
            destinations: destinations,
            touchedBar: touchedBar,
            onTouched: onBarTouched,
          ),
        ],
      ),
    );
  }
}

class _ChipInfo extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _ChipInfo({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(label, style: text.labelSmall),
          const SizedBox(width: 6),
          Text(
            value,
            style: text.labelSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

double _niceMax(int maxValue) {
  if (maxValue <= 4) return 4;
  if (maxValue <= 10) return (maxValue + 1).toDouble();
  final step = maxValue <= 30 ? 5 : (maxValue / 5).ceil();
  return ((maxValue + step - 1) ~/ step * step + step).toDouble();
}

double _niceInterval(double maxY) {
  if (maxY <= 6) return 1;
  if (maxY <= 12) return 2;
  if (maxY <= 30) return 5;
  return (maxY / 5).ceilToDouble();
}

class _MonthBarChart extends StatelessWidget {
  final List<_MonthPoint> months;
  final int touchedBar;
  final ValueChanged<int> onTouched;
  const _MonthBarChart({
    required this.months,
    required this.touchedBar,
    required this.onTouched,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    if (months.isEmpty) return const _ChartEmpty();
    final maxValue = months.fold<int>(
      0,
      (m, e) => e.devices > m ? e.devices : m,
    );
    final maxY = _niceMax(maxValue);
    final interval = _niceInterval(maxY);
    final gridColor = scheme.outlineVariant.withValues(alpha: .7);
    final labelColor = scheme.onSurfaceVariant;

    var peakIndex = 0;
    for (var i = 0; i < months.length; i++) {
      if (months[i].devices > months[peakIndex].devices) peakIndex = i;
    }

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (value) => FlLine(
              color: gridColor,
              strokeWidth: 1,
              dashArray: value == 0 ? null : [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: interval,
                getTitlesWidget: (value, meta) {
                  if (value % interval != 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      '${value.toInt()}',
                      textAlign: TextAlign.center,
                      style: text.labelSmall?.copyWith(
                        color: labelColor,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= months.length) {
                    return const SizedBox.shrink();
                  }
                  final m = months[i].monthNumber;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _kMonthShort[m] ?? '$m',
                      style: text.labelSmall?.copyWith(
                        color: i == touchedBar ? scheme.primary : labelColor,
                        fontWeight: i == peakIndex
                            ? FontWeight.w800
                            : FontWeight.w500,
                        fontSize: 10.5,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            enabled: true,
            touchCallback: (event, response) {
              if (event is! FlTapUpEvent) return;
              onTouched(response?.spot?.touchedBarGroupIndex ?? -1);
            },
            touchTooltipData: BarTouchTooltipData(
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final p = months[group.x.toInt()];
                final name = _kMonthNames[p.monthNumber] ?? p.key;
                return BarTooltipItem(
                  '$name ${p.year}\n',
                  const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontFamily: 'Vazirmatn',
                  ),
                  children: [
                    TextSpan(
                      text: '${rod.toY.toInt()} دستگاه',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Vazirmatn',
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          barGroups: [
            for (var i = 0; i < months.length; i++)
              BarChartGroupData(
                x: i,
                showingTooltipIndicators:
                    i == touchedBar ||
                        (touchedBar == -1 &&
                            i == peakIndex &&
                            months[i].devices > 0)
                    ? [0]
                    : [],
                barRods: [
                  BarChartRodData(
                    toY: months[i].devices.toDouble(),
                    width: 20,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                    color: i == peakIndex && months[i].devices > 0
                        ? _kViolet
                        : _kBlue,
                    gradient: i == peakIndex && months[i].devices > 0
                        ? const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [_kViolet, Color(0xFF9DA1FF)],
                          )
                        : LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [_kBlue, _kBlue.withValues(alpha: .65)],
                          ),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY,
                      color: scheme.surfaceContainerHighest.withValues(
                        alpha: .45,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _DestinationBarChart extends StatelessWidget {
  final List<_DestPoint> destinations;
  final int touchedBar;
  final ValueChanged<int> onTouched;
  const _DestinationBarChart({
    required this.destinations,
    required this.touchedBar,
    required this.onTouched,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    if (destinations.isEmpty) {
      return const _ChartEmpty(hint: 'برای این پروژه مقصدی ثبت نشده است');
    }
    final shown = destinations.take(10).toList();
    final maxValue = shown.fold<int>(
      0,
      (m, e) => e.devices > m ? e.devices : m,
    );
    final maxY = _niceMax(maxValue);
    final interval = _niceInterval(maxY);
    final gridColor = scheme.outlineVariant.withValues(alpha: .7);
    final labelColor = scheme.onSurfaceVariant;
    const palette = [_kBlue, _kTeal, _kViolet, _kAmber, _kRose, _kSlate];

    final neededWidth = shown.length * 72.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        // Fill available width when few destinations; scroll only on overflow.
        final width = maxW <= 0
            ? neededWidth
            : (neededWidth < maxW ? maxW : neededWidth);
        final scrollable = maxW > 0 && neededWidth > maxW;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: scrollable ? null : const NeverScrollableScrollPhysics(),
          child: SizedBox(
            width: width,
            height: 250,
            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: maxY,
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: gridColor,
                    strokeWidth: 1,
                    dashArray: value == 0 ? null : [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: interval,
                      getTitlesWidget: (value, meta) {
                        if (value % interval != 0)
                          return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            '${value.toInt()}',
                            style: text.labelSmall?.copyWith(
                              color: labelColor,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= shown.length) {
                          return const SizedBox.shrink();
                        }
                        var label = shown[i].label;
                        if (label.length > 9)
                          label = '${label.substring(0, 9)}…';
                        return Padding(
                          padding: const EdgeInsets.only(
                            top: 8,
                            left: 4,
                            right: 4,
                          ),
                          child: Text(
                            label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: text.labelSmall?.copyWith(
                              color: i == touchedBar
                                  ? scheme.primary
                                  : labelColor,
                              fontSize: 10,
                              fontWeight: i == 0
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchCallback: (event, response) {
                    if (event is! FlTapUpEvent) return;
                    onTouched(response?.spot?.touchedBarGroupIndex ?? -1);
                  },
                  touchTooltipData: BarTouchTooltipData(
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final p = shown[group.x.toInt()];
                      return BarTooltipItem(
                        '${p.label}\n',
                        const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontFamily: 'Vazirmatn',
                        ),
                        children: [
                          TextSpan(
                            text: '${rod.toY.toInt()} دستگاه',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Vazirmatn',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < shown.length; i++)
                    BarChartGroupData(
                      x: i,
                      showingTooltipIndicators: i == touchedBar ? [0] : [],
                      barRods: [
                        BarChartRodData(
                          toY: shown[i].devices.toDouble(),
                          width: 30,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(7),
                          ),
                          color: palette[i % palette.length],
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              palette[i % palette.length],
                              palette[i % palette.length].withValues(alpha: .6),
                            ],
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxY,
                            color: scheme.surfaceContainerHighest.withValues(
                              alpha: .45,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChartEmpty extends StatelessWidget {
  final String hint;
  const _ChartEmpty({this.hint = 'داده‌ای برای نمایش وجود ندارد'});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 30,
              color: scheme.onSurfaceVariant.withValues(alpha: .6),
            ),
            const SizedBox(height: 8),
            Text(
              hint,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Device status donut (fl_chart PieChart) + settlement progress
// ---------------------------------------------------------------------------

class _DeviceStatusCard extends StatelessWidget {
  final _SummaryData summary;
  final int touchedIndex;
  final ValueChanged<int> onPieTouched;
  const _DeviceStatusCard({
    required this.summary,
    required this.touchedIndex,
    required this.onPieTouched,
  });

  @override
  Widget build(BuildContext context) {
    final d = summary.devices;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final segments = [
      _PieSlice('نصب‌شده', d.installed, _kTeal),
      _PieSlice('برگشتی', d.returned, _kRose),
      _PieSlice('در گردش', d.inCirculation, _kBlue),
      if (d.inStock > 0) _PieSlice('موجود در انبار', d.inStock, _kSlate),
    ];
    final total = segments.fold<int>(0, (s, e) => s + e.value);
    final surface = scheme.surface;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            title: 'وضعیت دستگاه‌ها',
            subtitle: 'تفکیک وضعیت فعلی',
            icon: Icons.pie_chart_outline_rounded,
            accent: _kTeal,
          ),
          const SizedBox(height: 8),
          if (total == 0)
            const _ChartEmpty()
          else
            SizedBox(
              height: 190,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 46,
                  sectionsSpace: 2,
                  startDegreeOffset: -90,
                  pieTouchData: PieTouchData(
                    enabled: true,
                    touchCallback: (event, response) {
                      if (event is! FlTapUpEvent) return;
                      onPieTouched(
                        response?.touchedSection?.touchedSectionIndex ?? -1,
                      );
                    },
                  ),
                  sections: [
                    for (var i = 0; i < segments.length; i++)
                      PieChartSectionData(
                        value: segments[i].value.toDouble(),
                        color: segments[i].color,
                        radius: touchedIndex == i ? 30 : 24,
                        showTitle: false,
                        borderSide: BorderSide(color: surface, width: 2),
                      ),
                  ],
                ),
                duration: const Duration(milliseconds: 350),
              ),
            ),
          if (total > 0) ...[
            const SizedBox(height: 4),
            Center(
              child: Text.rich(
                TextSpan(
                  text: _fmt(total),
                  style: text.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                  children: [
                    TextSpan(
                      text: '  دستگاه',
                      style: text.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < segments.length; i++) ...[
              _PieLegendRow(
                slice: segments[i],
                total: total,
                highlighted: touchedIndex == i,
              ),
              if (i < segments.length - 1) const SizedBox(height: 9),
            ],
          ],
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: .5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _SettlementRow(
                  label: 'تسویه دستگاه',
                  value: d.settled,
                  total: d.total,
                  color: _kAmber,
                ),
                const SizedBox(height: 10),
                _SettlementRow(
                  label: 'تسویه نمایندگان',
                  value: d.representativesSettled,
                  total: d.total,
                  color: _kViolet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PieSlice {
  final String label;
  final int value;
  final Color color;
  const _PieSlice(this.label, this.value, this.color);
}

class _PieLegendRow extends StatelessWidget {
  final _PieSlice slice;
  final int total;
  final bool highlighted;
  const _PieLegendRow({
    required this.slice,
    required this.total,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final share = total == 0 ? 0.0 : slice.value / total;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: slice.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            slice.label,
            style: text.labelMedium?.copyWith(
              fontWeight: highlighted ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          _pct(slice.value, total),
          style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(width: 8),
        Text(
          _fmt(slice.value),
          style: text.labelMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 74,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: share.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(slice.color),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettlementRow extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final Color color;
  const _SettlementRow({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final share = total == 0 ? 0.0 : (value / total).clamp(0.0, 1.0);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(label, style: text.labelMedium)),
                  Text(
                    '${_fmt(value)} از ${_fmt(total)}',
                    style: text.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: share,
                  minHeight: 7,
                  backgroundColor: scheme.surface.withValues(alpha: .9),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Top items + full items table
// ---------------------------------------------------------------------------

class _TopItemsCard extends StatelessWidget {
  final _SummaryData summary;
  const _TopItemsCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final sorted = [...summary.itemsByType]
      ..sort((a, b) => b.net.compareTo(a.net));
    final top = sorted.take(7).toList();
    final maxNet = top.isEmpty
        ? 1
        : top.fold<int>(1, (m, e) => e.net > m ? e.net : m);
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            title: 'پرمصرف‌ترین اقلام',
            subtitle: 'براساس خالص مصرف',
            icon: Icons.format_list_numbered_rounded,
            accent: _kViolet,
          ),
          const SizedBox(height: 14),
          if (top.isEmpty)
            const _ChartEmpty()
          else
            for (var i = 0; i < top.length; i++) ...[
              _ItemBarRank(rank: i + 1, item: top[i], maxNet: maxNet),
              if (i < top.length - 1) const SizedBox(height: 11),
            ],
        ],
      ),
    );
  }
}

class _ItemBarRank extends StatelessWidget {
  final int rank;
  final _ItemTypeStats item;
  final int maxNet;
  const _ItemBarRank({
    required this.rank,
    required this.item,
    required this.maxNet,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final share = maxNet == 0 ? 0.0 : (item.net / maxNet).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: rank <= 3
                    ? _kBlue.withValues(alpha: .13)
                    : scheme.surfaceContainerHighest.withValues(alpha: .7),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                '$rank',
                style: text.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: rank <= 3 ? _kBlue : scheme.onSurfaceVariant,
                  fontSize: 10.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.labelMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _fmt(item.net),
              style: text.labelMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(right: 28),
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: SizedBox(
                    height: 7,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerRight,
                      widthFactor: share == 0 ? 0.015 : share,
                      child: Container(
                        decoration: BoxDecoration(
                          color: rank <= 3
                              ? _kBlue
                              : _kSlate.withValues(alpha: .75),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              if (item.returned > 0) ...[
                Text(
                  '  •  برگشت ${_fmt(item.returned)}',
                  style: text.labelSmall?.copyWith(color: _kRose, fontSize: 10),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
