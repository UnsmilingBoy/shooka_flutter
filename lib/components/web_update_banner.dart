import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shooka_flutter/services/web_update_service.dart';

/// Global banner shown on web when a newer `flutter build web` is detected.
///
/// Place once near the root (e.g. inside MaterialApp.builder) so it is
/// visible on every route. Does nothing on non-web platforms.
///
/// Polls `app_build.json` on mount + every [pollInterval] and compares its
/// `build_id` against the BUILD_ID baked in via --dart-define
/// (see tool/build_web.dart). On mismatch shows a persistent banner with
/// a one-click hard-reload ("به‌روزرسانی") that clears CacheStorage /
/// ServiceWorkers and navigates with a cache-busting query.
class WebUpdateBanner extends StatefulWidget {
  const WebUpdateBanner({
    super.key,
    this.pollInterval = const Duration(minutes: 15),
    this.checkOnStart = true,
  });

  final Duration pollInterval;
  final bool checkOnStart;

  @override
  State<WebUpdateBanner> createState() => _WebUpdateBannerState();
}

class _WebUpdateBannerState extends State<WebUpdateBanner> {
  Timer? _timer;
  bool _updateAvailable = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) return;
    if (widget.checkOnStart) {
      // Let first frame settle before network check.
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) _check();
      });
    }
    _timer = Timer.periodic(widget.pollInterval, (_) => _check());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    if (!mounted || _checking || _updateAvailable) return;
    // Don't pile up checks: skip while an update is already shown.
    _checking = true;
    try {
      final available = await WebUpdateService.instance.isNewBuildAvailable();
      if (!mounted) return;
      if (available) {
        setState(() => _updateAvailable = true);
      }
    } finally {
      _checking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || !_updateAvailable) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          border: Border(
            bottom: BorderSide(color: scheme.primary.withOpacity(0.3)),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              Icon(
                Icons.system_update_rounded,
                size: 20,
                color: scheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'نسخه جدید منتشر شده است. برای دریافت آخرین تغییرات به‌روزرسانی کنید.',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: () {
                  WebUpdateService.instance.applyUpdate();
                },
                child: const Text('به‌روزرسانی'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
