import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/models/app_panel.dart';
import 'package:shooka_flutter/models/device_flowchart_step_data_class.dart';
import 'package:shooka_flutter/models/flowchart_item_data_class.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/services/providers/user_provider.dart';
import 'package:shooka_flutter/utils/expansion%20tile/my_expansion_tile.dart';
import 'package:shooka_flutter/utils/loadings/loading.dart';
import 'package:shooka_flutter/utils/toastifications/toasts.dart';

/// Flowchart / process-steps section of the device page.
///
/// Permission-gated by [AppPanel.flowchart]. When the user has no access,
/// renders nothing ([SizedBox.shrink]).
///
/// Shows **per-device progress** from
/// `POST /api/shouka/objects/flowchart/retrieve/` (`is_done`, `done_at`,
/// `done_by`, `note`) with a progress header + vertical timeline. The current
/// (first pending) step can be marked done — with an optional note — and the
/// last completed step can be reverted back to incomplete, both via
/// `POST /api/shouka/device/edit-info/` (`object_type: flowchart`, `is_done`).
/// Plus an in-place **template reorder** sheet backed by
/// `list/ordered/` + `edit/order/`.
///
/// Works for both mobile ([device_page.dart]) and desktop
/// ([device_detail_panel.dart]).
class DpFlowchart extends StatefulWidget {
  final int deviceId;

  const DpFlowchart({super.key, required this.deviceId});

  @override
  State<DpFlowchart> createState() => _DpFlowchartState();
}

class _DpFlowchartState extends State<DpFlowchart> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void didUpdateWidget(DpFlowchart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deviceId != widget.deviceId) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }
  }

  void _load() {
    if (!mounted) return;
    final hasAccess = context
        .read<UserProvider>()
        .accessControl
        .hasAccessTo(AppPanel.flowchart);
    if (!hasAccess) return;
    final provider = context.read<DeviceProvider>();
    provider.loadDeviceFlowchart(deviceId: widget.deviceId);
    if (provider.flowchartOrderedItems.isEmpty &&
        !provider.flowchartOrderedLoading) {
      provider.loadFlowchartOrderedItems();
    }
    // Legacy unordered template as a last-resort fallback reference.
    if (provider.flowchartItems.isEmpty && !provider.flowchartLoading) {
      provider.loadFlowchartItems();
    }
  }

  void _retry() {
    final provider = context.read<DeviceProvider>();
    provider.loadDeviceFlowchart(
      deviceId: widget.deviceId,
      forceRefresh: true,
    );
    provider.loadFlowchartOrderedItems(forceRefresh: true);
  }

  Future<void> _openReorderSheet() async {
    final provider = context.read<DeviceProvider>();
    if (provider.flowchartOrderedItems.isEmpty) {
      await provider.loadFlowchartOrderedItems(forceRefresh: true);
    }
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => _ReorderSheet(
        initial: context.read<DeviceProvider>().flowchartOrderedItems,
      ),
    );
    // Device steps keep their own `order`; re-sort view by re-reading.
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasAccess = context
        .watch<UserProvider>()
        .accessControl
        .hasAccessTo(AppPanel.flowchart);
    if (!hasAccess) return const SizedBox.shrink();

    final provider = context.watch<DeviceProvider>();
    final steps = provider.deviceFlowchart(widget.deviceId);
    final loading = provider.deviceFlowchartLoading(widget.deviceId);
    final error = provider.deviceFlowchartError(widget.deviceId);

    // Current flowchart status shown beside the (collapsed) title:
    // the first pending step's label, or "تکمیل شده" when all are done.
    String? statusText;
    Color statusColor = Theme.of(context).colorScheme.primary;
    if (loading && steps == null) {
      statusText = "در حال بارگذاری...";
      statusColor = Theme.of(context).hintColor;
    } else if (error != null && steps == null) {
      statusText = "خطا در دریافت وضعیت";
      statusColor = Theme.of(context).colorScheme.error;
    } else if (steps != null && steps.isNotEmpty) {
      final sorted = List<DeviceFlowchartStep>.from(steps)
        ..sort((a, b) => a.order.compareTo(b.order));
      final firstPending = sorted.indexWhere((s) => !s.isDone);
      if (firstPending == -1) {
        statusText = "تکمیل شده";
        statusColor = Colors.green;
      } else {
        statusText = sorted[firstPending].label;
      }
    }

    return MyExpansionTile(
      initiallyExpanded: false,
      title: "مراحل انجام کار",
      titleTrailing: statusText == null
          ? null
          : _TitleStatusPill(text: statusText, color: statusColor),
      children: [
        if (loading && steps == null)
          const Padding(
            padding: EdgeInsets.all(40.0),
            child: Loading(),
          )
        else if (error != null && steps == null)
          _ErrorBox(message: "خطا در دریافت پیشرفت دستگاه.", onRetry: _retry)
        else if (steps == null || steps.isEmpty)
          _FallbackTemplate(
            onRetry: _retry,
            onReorder: _openReorderSheet,
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProgressHeader(
                steps: steps,
                reorderLoading: provider.flowchartReorderLoading,
                onReorder: _openReorderSheet,
                onRefresh: () => provider.loadDeviceFlowchart(
                  deviceId: widget.deviceId,
                  forceRefresh: true,
                ),
              ),
              const SizedBox(height: 12),
              _DeviceTimeline(deviceId: widget.deviceId, steps: steps),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(
                  "به‌روزرسانی ناموفق بود؛ آخرین داده ذخیره‌شده نمایش داده می‌شود.",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
      ],
    );
  }
}

/// Summary card: `X از Y`, animated bar, % badge, refresh + reorder actions.
class _ProgressHeader extends StatelessWidget {
  final List<DeviceFlowchartStep> steps;
  final bool reorderLoading;
  final VoidCallback onReorder;
  final VoidCallback onRefresh;

  const _ProgressHeader({
    required this.steps,
    required this.reorderLoading,
    required this.onReorder,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final done = steps.where((s) => s.isDone).length;
    final total = steps.length;
    final progress = total == 0 ? 0.0 : done / total;
    final percent = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.primary.withValues(alpha: .25)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  percent == 100
                      ? Icons.verified_rounded
                      : Icons.timeline_rounded,
                  color: scheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$done از $total مرحله انجام شده",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      percent == 100
                          ? "فرایند این دستگاه کامل شده است"
                          : "مراحل به ترتیب قالب چیدمان نمایش داده می‌شوند",
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: percent == 100
                      ? Colors.green.withValues(alpha: .15)
                      : scheme.primary.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$percent٪",
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: percent == 100 ? Colors.green : scheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: scheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(
                  percent == 100 ? Colors.green : scheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text("به‌روزرسانی"),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: reorderLoading ? null : onReorder,
                icon: reorderLoading
                    ? const SizedBox.square(
                        dimension: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.reorder_rounded, size: 16),
                label: const Text("ویرایش ترتیب قالب"),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Vertical timeline of per-device steps: done / current / pending.
///
/// Only the current (first pending) step is actionable — completing steps in
/// order keeps the flowchart sequential.
class _DeviceTimeline extends StatelessWidget {
  final int deviceId;
  final List<DeviceFlowchartStep> steps;

  const _DeviceTimeline({required this.deviceId, required this.steps});

  @override
  Widget build(BuildContext context) {
    final sorted = List<DeviceFlowchartStep>.from(steps)
      ..sort((a, b) => a.order.compareTo(b.order));
    final firstPending = sorted.indexWhere((s) => !s.isDone);
    // Only the most recent done step can be reverted — keeps the flowchart
    // sequential (no holes in the middle).
    final lastDone = firstPending == -1
        ? sorted.length - 1
        : firstPending - 1;

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final step = sorted[index];
        final isLast = index == sorted.length - 1;
        final isCurrent = index == firstPending;
        return _StepRow(
          deviceId: deviceId,
          step: step,
          isLast: isLast,
          isCurrent: isCurrent,
          canRevert: step.isDone && index == lastDone,
        );
      },
    );
  }
}

class _StepRow extends StatelessWidget {
  final int deviceId;
  final DeviceFlowchartStep step;
  final bool isLast;
  final bool isCurrent;
  final bool canRevert;

  const _StepRow({
    required this.deviceId,
    required this.step,
    required this.isLast,
    required this.isCurrent,
    this.canRevert = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final showRevert = canRevert && !isCurrent && !_isSettlementStep(step);
    final Color ring;
    final Color fill;
    if (step.isDone) {
      ring = Colors.green;
      fill = Colors.green.withValues(alpha: .15);
    } else if (isCurrent) {
      ring = scheme.primary;
      fill = scheme.primary.withValues(alpha: .12);
    } else {
      ring = scheme.outline.withValues(alpha: .6);
      fill = scheme.surfaceContainerHighest;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: fill,
                  border: Border.all(color: ring, width: isCurrent ? 2 : 1.5),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: ring.withValues(alpha: .3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: step.isDone
                      ? const Icon(
                          Icons.check_rounded,
                          size: 17,
                          color: Colors.green,
                        )
                      : Icon(
                          _iconFor(step.label),
                          size: 15,
                          color: ring,
                        ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: step.isDone
                        ? Colors.green.withValues(alpha: .5)
                        : ring.withValues(alpha: .35),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? scheme.primary.withValues(alpha: .05)
                      : scheme.surfaceContainerLow.withValues(alpha: .6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCurrent
                        ? scheme.primary.withValues(alpha: .35)
                        : scheme.outline.withValues(alpha: .25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            step.label,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IntrinsicWidth(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _StatusChip(
                                done: step.isDone,
                                current: isCurrent,
                              ),
                              if (showRevert) ...[
                                const SizedBox(height: 6),
                                _RevertStepButton(
                                  deviceId: deviceId,
                                  step: step,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _MetaPill(
                          icon: Icons.format_list_numbered_rounded,
                          text: "مرحله ${step.order}",
                        ),
                        if (step.doneAt != null)
                          _MetaPill(
                            icon: Icons.event_available_outlined,
                            text: step.doneAt!,
                            highlight: true,
                          ),
                        if (_doneByText(step) != null)
                          _MetaPill(
                            icon: Icons.person_outline_rounded,
                            text: _doneByText(step)!,
                          ),
                      ],
                    ),
                    if (step.note.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: scheme.outline.withValues(alpha: .25),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.notes_rounded,
                              size: 14,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                step.note.trim(),
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // Only the current step can be completed — keeps the
                    // flowchart sequential. Settlement steps are settled via
                    // the inventory forms, so they never show actions.
                    // (Revert lives beside the status chip above.)
                    if (isCurrent && !_isSettlementStep(step)) ...[
                      const SizedBox(height: 8),
                      _CompleteStepButton(
                        deviceId: deviceId,
                        step: step,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _doneByText(DeviceFlowchartStep step) {
    final by = step.doneBy;
    if (by == null) return null;
    final text = by.toString().trim();
    if (text.isEmpty || text == "null") return null;
    return text;
  }
}

/// Action button on the current step. Opens a confirm dialog with an optional
/// note field, then marks the step done via the provider.
///
/// On wide screens (desktop) the confirm UI is a centered window; on compact
/// screens it stays a bottom sheet — same breakpoint convention as the rest
/// of the app (`width >= 900`).
class _CompleteStepButton extends StatelessWidget {
  final int deviceId;
  final DeviceFlowchartStep step;

  const _CompleteStepButton({required this.deviceId, required this.step});

  Future<void> _openSheet(BuildContext context) async {
    final content = _CompleteStepSheet(deviceId: deviceId, step: step);
    if (MediaQuery.sizeOf(context).width >= 900) {
      await showDialog<void>(context: context, builder: (_) => content);
    } else {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => content,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitting = context
        .watch<DeviceProvider>()
        .isFlowchartStepSubmitting(deviceId, step.flowchartItemId);
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: submitting ? null : () => _openSheet(context),
        icon: submitting
            ? const SizedBox.square(
                dimension: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check_circle_outline_rounded, size: 17),
        label: Text(submitting ? "در حال ثبت..." : "تکمیل این مرحله"),
        style:
            FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
              textStyle: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.green.withValues(alpha: .35),
              disabledForegroundColor: Colors.white.withValues(alpha: .9),
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) return null;
                if (states.contains(WidgetState.pressed)) {
                  return Colors.white.withValues(alpha: .24);
                }
                if (states.contains(WidgetState.hovered)) {
                  return Colors.white.withValues(alpha: .14);
                }
                if (states.contains(WidgetState.focused)) {
                  return Colors.white.withValues(alpha: .12);
                }
                return null;
              }),
            ),
      ),
    );
  }
}

/// Revert button on the last done step. Opens a confirm dialog, then flips
/// the step back to incomplete (`is_done: false`) via the provider.
class _RevertStepButton extends StatelessWidget {
  final int deviceId;
  final DeviceFlowchartStep step;

  const _RevertStepButton({required this.deviceId, required this.step});

  Future<void> _openSheet(BuildContext context) async {
    final content = _CompleteStepSheet(
      deviceId: deviceId,
      step: step,
      isDone: false,
    );
    if (MediaQuery.sizeOf(context).width >= 900) {
      await showDialog<void>(context: context, builder: (_) => content);
    } else {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => content,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitting = context
        .watch<DeviceProvider>()
        .isFlowchartStepSubmitting(deviceId, step.flowchartItemId);
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: "بازگردانی به ناتمام",
      child: OutlinedButton.icon(
        onPressed: submitting ? null : () => _openSheet(context),
        icon: submitting
            ? const SizedBox.square(
                dimension: 13,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.undo_rounded, size: 15),
        label: Text(submitting ? "..." : "بازگردانی"),
        style: OutlinedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 11.5,
          ),
          foregroundColor: scheme.error,
          backgroundColor: scheme.error.withValues(alpha: .12),
          side: BorderSide(
            color: scheme.error.withValues(alpha: .8),
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return null;
            if (states.contains(WidgetState.pressed)) {
              return scheme.error.withValues(alpha: .25);
            }
            if (states.contains(WidgetState.hovered)) {
              return scheme.error.withValues(alpha: .18);
            }
            return null;
          }),
        ),
      ),
    );
  }
}

/// Confirm form: shows the step, takes an optional note, submits.
///
/// Renders as a centered window on desktop and as bottom-sheet content on
/// mobile (decided by the caller via `showDialog` / `showModalBottomSheet`).
class _CompleteStepSheet extends StatefulWidget {
  final int deviceId;
  final DeviceFlowchartStep step;
  final bool isDone;

  const _CompleteStepSheet({
    required this.deviceId,
    required this.step,
    this.isDone = true,
  });

  @override
  State<_CompleteStepSheet> createState() => _CompleteStepSheetState();
}

class _CompleteStepSheetState extends State<_CompleteStepSheet> {
  final _note = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final status = await context.read<DeviceProvider>().completeFlowchartStep(
        deviceId: widget.deviceId,
        flowchartItemId: widget.step.flowchartItemId,
        note: _note.text.trim(),
        isDone: widget.isDone,
      );
      if (!mounted) return;
      if (status == 200) {
        filledSuccessToast(
          title: widget.isDone
              ? "مرحله «${widget.step.label}» انجام شد"
              : "مرحله «${widget.step.label}» به ناتمام برگشت",
        );
        Navigator.pop(context);
      } else {
        flatErrorToast(
          title: widget.isDone
              ? "ثبت مرحله ناموفق بود"
              : "بازگردانی مرحله ناموفق بود",
          description: "کد وضعیت: $status",
        );
      }
    } catch (e) {
      flatErrorToast(
        title: widget.isDone ? "خطا در ثبت مرحله" : "خطا در بازگردانی مرحله",
        description: e.toString(),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;
    if (isDesktop) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 24,
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 460),
          padding: const EdgeInsets.all(20),
          child: _form(context, autofocusNote: true),
        ),
      );
    }
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
          left: 16,
          right: 16,
          top: 12,
        ),
        child: _form(context, autofocusNote: false),
      ),
    );
  }

  Widget _form(BuildContext context, {required bool autofocusNote}) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDone = widget.isDone;
    final accent = isDone ? Colors.green : scheme.error;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: scheme.outline.withValues(alpha: .45)),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDone ? Icons.task_alt_rounded : Icons.undo_rounded,
                color: accent,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isDone ? "تکمیل مرحله" : "بازگردانی مرحله",
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isDone
                        ? "«${widget.step.label}» به‌عنوان انجام‌شده ثبت می‌شود"
                        : "«${widget.step.label}» به حالت ناتمام برمی‌گردد",
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "مرحله ${widget.step.order}",
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: _saving ? null : () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded),
              tooltip: "بستن",
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _note,
          autofocus: autofocusNote,
          maxLines: 4,
          minLines: 2,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          style: textTheme.bodyMedium,
          decoration: InputDecoration(
            labelText: "یادداشت",
            hintText: isDone
                ? "توضیح کوتاه درباره انجام این مرحله (اختیاری)..."
                : "دلیل بازگردانی این مرحله (اختیاری)...",
            prefixIcon: const Icon(Icons.edit_note_rounded, size: 20),
            isDense: true,
            filled: true,
            fillColor: scheme.surfaceContainerLow,
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: BorderSide(color: scheme.primary, width: 1.4),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        isDone ? Icons.check_rounded : Icons.undo_rounded,
                        size: 18,
                      ),
                label: Text(
                  _saving
                      ? "در حال ثبت..."
                      : (isDone ? "ثبت انجام مرحله" : "ثبت بازگردانی"),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: isDone ? Colors.green : scheme.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: _saving ? null : () => Navigator.pop(context),
              child: const Text("انصراف"),
            ),
          ],
        ),
      ],
    );
  }
}

/// Settlement steps ("تسویه حساب" / "تسویه حساب با نماینده") are settled
/// through the inventory settlement forms, not from the flowchart — so they
/// never show complete / revert actions here.
bool _isSettlementStep(DeviceFlowchartStep step) {
  final label = step.label;
  return label.contains('تسویه') ||
      label.contains('توسعه') ||
      label.contains('توسه');
}

IconData _iconFor(String label) {  if (label.contains("اشتراک")) return Icons.card_membership_outlined;
  if (label.contains("نصب")) return Icons.build_outlined;
  if (label.contains("مستند")) return Icons.upload_file_outlined;
  if (label.contains("ناظر")) return Icons.verified_outlined;
  if (label.contains("فاکتور")) return Icons.receipt_long_outlined;
  if (label.contains("نماینده")) return Icons.badge_outlined;
  if (label.contains("تسویه")) return Icons.payments_outlined;
  return Icons.circle_outlined;
}

/// Small pill shown beside the collapsed tile title with the current
/// flowchart status (first pending step label, or "تکمیل شده").
class _TitleStatusPill extends StatelessWidget {
  final String text;
  final Color color;

  const _TitleStatusPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool done;
  final bool current;

  const _StatusChip({required this.done, required this.current});

  @override
  Widget build(BuildContext context) {
    final String text;
    final Color color;
    if (done) {
      text = "انجام شده";
      color = Colors.green;
    } else if (current) {
      text = "مرحله جاری";
      color = Theme.of(context).colorScheme.primary;
    } else {
      text = "در انتظار";
      color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool highlight;

  const _MetaPill({
    required this.icon,
    required this.text,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: highlight
            ? Colors.green.withValues(alpha: .1)
            : scheme.surfaceContainerHighest.withValues(alpha: .7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: highlight ? Colors.green : scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: highlight ? Colors.green : scheme.onSurfaceVariant,
              fontWeight: highlight ? FontWeight.w800 : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBox({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(message),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text("تلاش مجدد")),
        ],
      ),
    );
  }
}

/// Shown when retrieve/ returns nothing: fall back to the global template
/// so the section is never blank, with the same reorder entry point.
class _FallbackTemplate extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onReorder;

  const _FallbackTemplate({required this.onRetry, required this.onReorder});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeviceProvider>();
    final ordered = provider.flowchartOrderedItems;
    final items = ordered.isNotEmpty ? ordered : provider.flowchartItems;
    final loading =
        provider.flowchartOrderedLoading || provider.flowchartLoading;

    if (loading && items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Loading(),
      );
    }
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text(
              "پیشرفتی برای این دستگاه ثبت نشده و قالبی یافت نشد.",
              style: Theme.of(context).textTheme.labelSmall,
            ),
            TextButton(onPressed: onRetry, child: const Text("تلاش مجدد")),
          ],
        ),
      );
    }
    final sorted = List<FlowchartItem>.from(items)
      ..sort((a, b) => a.order.compareTo(b.order));
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerLow.withValues(alpha: .7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "پیشرفتی برای این دستگاه ثبت نشده؛ قالب کلی مراحل نمایش داده می‌شود.",
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).hintColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        ...sorted.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: .5),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "${item.order == 0 ? sorted.indexOf(item) + 1 : item.order}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onReorder,
            icon: const Icon(Icons.reorder_rounded, size: 16),
            label: const Text("ویرایش ترتیب قالب"),
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet with drag-to-reorder for the global template.
class _ReorderSheet extends StatefulWidget {
  final List<FlowchartItem> initial;

  const _ReorderSheet({required this.initial});

  @override
  State<_ReorderSheet> createState() => _ReorderSheetState();
}

class _ReorderSheetState extends State<_ReorderSheet> {
  late List<FlowchartItem> _rows;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _rows = List<FlowchartItem>.from(widget.initial)
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<void> _save() async {
    if (_saving) return;
    final missingId = _rows.any((r) => r.itemId == null);
    if (missingId) {
      flatErrorToast(title: "شناسه برخی مراحل نامشخص است؛ ذخیره ممکن نیست");
      return;
    }
    setState(() => _saving = true);
    try {
      await context.read<DeviceProvider>().reorderFlowchartItems(_rows);
      if (!mounted) return;
      filledSuccessToast(title: "ترتیب مراحل با موفقیت ذخیره شد");
      Navigator.pop(context);
    } catch (e) {
      flatErrorToast(title: "خطا در ذخیره ترتیب", description: e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
          left: 16,
          right: 16,
          top: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.reorder_rounded,
                    color: scheme.primary,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ویرایش ترتیب قالب",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        "ردیف‌ها را بکشید و رها کنید؛ ترتیب جدید برای همه دستگاه‌ها اعمال می‌شود",
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.55,
                ),
                child: ReorderableListView.builder(
                  shrinkWrap: true,
                  itemCount: _rows.length,
                  onReorderItem: (oldIndex, newIndex) {
                    setState(() {
                      final moved = _rows.removeAt(oldIndex);
                      _rows.insert(newIndex, moved);
                    });
                  },
                  proxyDecorator: (child, _, __) => Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(10),
                    child: child,
                  ),
                  itemBuilder: (context, index) {
                    final item = _rows[index];
                    return Container(
                      key: ValueKey(
                        "flowchart_order_${item.itemId ?? item.label}_$index",
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: scheme.outline.withValues(alpha: .3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                "${index + 1}",
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: scheme.primary,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                if (item.description.trim().isNotEmpty)
                                  Text(
                                    item.description.trim(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.labelSmall
                                        ?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.drag_handle_rounded,
                            color: scheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded, size: 18),
              label: Text(_saving ? "در حال ذخیره..." : "ذخیره ترتیب"),
            ),
          ],
        ),
      ),
    );
  }
}
