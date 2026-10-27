import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/models/app_panel.dart';
import 'package:shooka_flutter/models/device_flowchart_step_data_class.dart';
import 'package:shooka_flutter/models/flowchart_item_data_class.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/services/providers/user_provider.dart';
import 'package:shooka_flutter/utils/expansion%20tile/my_expansion_tile.dart';
import 'package:shooka_flutter/utils/toastifications/toasts.dart';

/// Flowchart / process-steps section of the device page.
///
/// Permission-gated by [AppPanel.flowchart]. When the user has no access,
/// renders nothing ([SizedBox.shrink]).
///
/// Shows **per-device progress** from
/// `POST /api/shouka/objects/flowchart/retrieve/` (`is_done`, `done_at`,
/// `done_by`, `note`) with a progress summary + vertical timeline. The current
/// (first pending) step can be completed in one tap, or completed with an
/// optional note; the most recent completed step can be reverted. Both go
/// through `POST /api/shouka/device/edit-info/` (`object_type: flowchart`,
/// `is_done`). Plus an in-place **template reorder** sheet backed by
/// `list/ordered/` + `edit/order/`.
///
/// Works for both mobile ([device_page.dart]) and desktop
/// ([device_detail_panel.dart]).
///
/// ## Layout
///
/// ```
///  ◔ 43%   3 از 7 مرحله انجام شده            ⋮
///          مرحله بعدی: «نصب دستگاه»
///  ─────────────────────────────────────────
///  ✓   اشتراک
///  │   1403/05/12 · علی رضایی
///  ●   نصب دستگاه                    [مرحله جاری]
///  │   [ تکمیل مرحله ]  [ یادداشت ]
///  ○   مستندات
///  ── تسویه حساب ────────────────────────────
///  ▣   تسویه حساب                [در انتظار تسویه]
/// ```
///
/// Design notes:
/// * Passive rows (done / pending) are flat so the eye lands on the single
///   actionable step, which is the only row drawn as a card.
/// * The step node itself carries the status (number, check, filled accent),
///   so no status chip is repeated on every row.
/// * Actions are reversible: completing a step is one tap and can be undone,
///   which is why there is no confirmation dialog on the happy path.
/// * All sizes/colours resolve from the theme ([_Skin]) so light and dark
///   themes keep their contrast.
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
    final hasAccess = context.read<UserProvider>().accessControl.hasAccessTo(
      AppPanel.flowchart,
    );
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
    provider.loadDeviceFlowchart(deviceId: widget.deviceId, forceRefresh: true);
    provider.loadFlowchartOrderedItems(forceRefresh: true);
  }

  void _refresh() {
    context.read<DeviceProvider>().loadDeviceFlowchart(
      deviceId: widget.deviceId,
      forceRefresh: true,
    );
  }

  /// Marks [step] done right away (no dialog): the provider flips the cached
  /// step optimistically and rolls back on failure, so the UI stays honest.
  Future<void> _completeStep(DeviceFlowchartStep step) async {
    final provider = context.read<DeviceProvider>();
    try {
      final status = await provider.completeFlowchartStep(
        deviceId: widget.deviceId,
        flowchartItemId: step.flowchartItemId,
      );
      if (!mounted) return;
      if (status == 200) {
        filledSuccessToast(title: "مرحله «${step.label}» تکمیل شد");
      } else if (status == -1) {
        flatErrorToast(
          title: "ارتباط با سرور برقرار نشد",
          description: "تغییری ثبت نشد؛ دوباره تلاش کنید.",
        );
      } else {
        flatErrorToast(
          title: "ثبت مرحله ناموفق بود",
          description: "کد وضعیت: $status",
        );
      }
    } catch (e) {
      if (!mounted) return;
      flatErrorToast(title: "خطا در ثبت مرحله", description: e.toString());
    }
  }

  Future<void> _completeStepWithNote(DeviceFlowchartStep step) async {
    await _showFlowModal<void>(
      context,
      (_) => _NoteSheet(
        deviceId: widget.deviceId,
        step: step,
        isSettlement: _isSettlementStep(step),
      ),
    );
  }

  Future<void> _revertStep(DeviceFlowchartStep step) async {
    final isSettlement = _isSettlementStep(step);
    final confirmed = await _showFlowModal<bool>(
      context,
      (_) => _RevertDialog(step: step, isSettlement: isSettlement),
    );
    if (confirmed != true || !mounted) return;

    final provider = context.read<DeviceProvider>();
    try {
      final status = await provider.completeFlowchartStep(
        deviceId: widget.deviceId,
        flowchartItemId: step.flowchartItemId,
        isDone: false,
      );
      if (!mounted) return;
      if (status == 200) {
        filledSuccessToast(title: "مرحله «${step.label}» بازگردانده شد");
      } else if (status == -1) {
        flatErrorToast(
          title: "ارتباط با سرور برقرار نشد",
          description: "تغییری ثبت نشد؛ دوباره تلاش کنید.",
        );
      } else {
        flatErrorToast(
          title: "بازگردانی مرحله ناموفق بود",
          description: "کد وضعیت: $status",
        );
      }
    } catch (e) {
      if (!mounted) return;
      flatErrorToast(
        title: "خطا در بازگردانی مرحله",
        description: e.toString(),
      );
    }
  }

  Future<void> _openReorderSheet() async {
    final provider = context.read<DeviceProvider>();
    if (provider.flowchartOrderedItems.isEmpty) {
      await provider.loadFlowchartOrderedItems(forceRefresh: true);
    }
    if (!mounted) return;
    await _showFlowModal<void>(
      context,
      (_) => _ReorderSheet(initial: provider.flowchartOrderedItems),
    );
    // Device steps keep their own `order`; re-sort view by re-reading.
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasAccess = context.watch<UserProvider>().accessControl.hasAccessTo(
      AppPanel.flowchart,
    );
    if (!hasAccess) return const SizedBox.shrink();

    final provider = context.watch<DeviceProvider>();
    final steps = provider.deviceFlowchart(widget.deviceId);
    final loading = provider.deviceFlowchartLoading(widget.deviceId);
    final error = provider.deviceFlowchartError(widget.deviceId);
    final model = steps == null ? null : _FlowModel.from(steps);

    return MyExpansionTile(
      initiallyExpanded: false,
      title: "مراحل انجام کار",
      titleTrailing: _HeaderBadge(model: model, hasError: error != null),
      children: [
        _buildBody(
          model: model,
          loading: loading,
          error: error,
          submittingId: (step) => provider.isFlowchartStepSubmitting(
            widget.deviceId,
            step.flowchartItemId,
          ),
        ),
      ],
    );
  }

  Widget _buildBody({
    required _FlowModel? model,
    required bool loading,
    required String? error,
    required bool Function(DeviceFlowchartStep) submittingId,
  }) {
    if (model == null) {
      if (loading) return const _FlowSkeleton();
      if (error != null) {
        return _MessageState(
          icon: Icons.cloud_off_rounded,
          title: "دریافت پیشرفت مراحل ناموفق بود",
          message: "اتصال به سرور برقرار نشد. لطفاً دوباره تلاش کنید.",
          actionLabel: "تلاش مجدد",
          onAction: _retry,
        );
      }
      return const _FlowSkeleton();
    }

    if (model.isEmpty) {
      return _TemplatePreview(onRetry: _retry, onReorder: _openReorderSheet);
    }

    // One width probe for the whole section: rows pick their action layout
    // from the real available width (a desktop panel is often much narrower
    // than the screen). It also has to live above the timeline, because a
    // [LayoutBuilder] nested inside the rows would break the intrinsic
    // measurement the connectors rely on.
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 420;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SummaryCard(
              model: model,
              onRefresh: _refresh,
              onReorder: _openReorderSheet,
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < model.ordered.length; i++)
              _StepRow(
                key: ValueKey("fc_step_${model.ordered[i].flowchartItemId}"),
                step: model.ordered[i],
                number: i + 1,
                status: model.ordered[i].isDone
                    ? _StepStatus.done
                    : (i == model.currentIndex
                          ? _StepStatus.current
                          : _StepStatus.pending),
                connector: i < model.ordered.length - 1,
                isLast: i == model.ordered.length - 1,
                canRevert: model.ordered[i].isDone && i == model.undoIndex,
                wide: wide,
                submitting: submittingId(model.ordered[i]),
                onComplete: i == model.currentIndex
                    ? () => _completeStep(model.ordered[i])
                    : null,
                onCompleteWithNote: i == model.currentIndex
                    ? () => _completeStepWithNote(model.ordered[i])
                    : null,
                onRevert: model.ordered[i].isDone && i == model.undoIndex
                    ? () => _revertStep(model.ordered[i])
                    : null,
              ),
            if (model.settlement.isNotEmpty) ...[
              _SettlementHeader(hasOrdered: model.ordered.isNotEmpty),
              for (var i = 0; i < model.settlement.length; i++)
                _StepRow(
                  key: ValueKey(
                    "fc_settlement_${model.settlement[i].flowchartItemId}",
                  ),
                  step: model.settlement[i],
                  isSettlement: true,
                  status: model.settlement[i].isDone
                      ? _StepStatus.done
                      : _StepStatus.pending,
                  isLast: i == model.settlement.length - 1,
                  canRevert: model.settlement[i].isDone,
                  wide: wide,
                  submitting: submittingId(model.settlement[i]),
                  onComplete: model.settlement[i].isDone
                      ? null
                      : () => _completeStep(model.settlement[i]),
                  onCompleteWithNote: model.settlement[i].isDone
                      ? null
                      : () => _completeStepWithNote(model.settlement[i]),
                  onRevert: model.settlement[i].isDone
                      ? () => _revertStep(model.settlement[i])
                      : null,
                ),
            ],
            if (error != null) _StaleBanner(onRetry: _retry),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Section header badge (collapsed tile)
// ---------------------------------------------------------------------------

/// Compact "how far along" pill shown beside the collapsed section title.
///
/// Always visible (unlike the old behaviour, which hid the status until a
/// first step was approved) so the section answers "is this device done?"
/// without being opened.
class _HeaderBadge extends StatelessWidget {
  final _FlowModel? model;
  final bool hasError;

  const _HeaderBadge({required this.model, required this.hasError});

  @override
  Widget build(BuildContext context) {
    final skin = _Skin.of(context);
    final m = model;

    if (m == null) {
      if (!hasError) return const SizedBox.shrink();
      return _Pill(
        text: "خطا",
        tone: skin.danger,
        icon: Icons.error_outline_rounded,
      );
    }
    if (m.isEmpty) return const SizedBox.shrink();

    final tone = m.isComplete ? skin.success : skin.accent;
    return Container(
      padding: const EdgeInsets.fromLTRB(7, 3, 9, 3),
      decoration: BoxDecoration(
        color: tone.tint,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tone.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: 13,
            child: CircularProgressIndicator(
              value: m.progress,
              strokeWidth: 2.4,
              strokeCap: StrokeCap.round,
              backgroundColor: tone.fill.withValues(alpha: .18),
              valueColor: AlwaysStoppedAnimation(tone.ink),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            m.isComplete ? "کامل" : "${m.doneCount}/${m.total}",
            style: _text(
              context,
              size: 11,
              weight: FontWeight.w700,
              color: tone.ink,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary card
// ---------------------------------------------------------------------------

enum _SummaryAction { refresh, reorder }

/// Progress summary: percentage ring, "X of Y" and what comes next.
class _SummaryCard extends StatelessWidget {
  final _FlowModel model;
  final VoidCallback onRefresh;
  final VoidCallback onReorder;

  const _SummaryCard({
    required this.model,
    required this.onRefresh,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final skin = _Skin.of(context);
    final tone = model.isComplete ? skin.success : skin.accent;
    final next = model.nextStep;

    final String subtitle;
    if (model.isComplete) {
      subtitle = "همه مراحل انجام شده است";
    } else if (next != null) {
      subtitle = "مرحله بعدی: «${next.label}»";
    } else {
      subtitle = "هنوز مرحله‌ای ثبت نشده است";
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          tone.fill.withValues(alpha: .055),
          skin.surface,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tone.fill.withValues(alpha: .18)),
      ),
      child: Row(
        children: [
          _ProgressRing(
            value: model.progress,
            percent: model.percent,
            tone: tone,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${model.doneCount} از ${model.total} مرحله انجام شده",
                  style: _text(
                    context,
                    size: 13,
                    weight: FontWeight.w700,
                    color: skin.ink,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _text(
                    context,
                    size: 11.5,
                    color: model.isComplete ? tone.ink : skin.inkMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<_SummaryAction>(
            tooltip: "گزینه‌های بیشتر",
            icon: Icon(Icons.more_vert_rounded, size: 20, color: skin.inkMuted),
            onSelected: (action) {
              if (action == _SummaryAction.refresh) {
                onRefresh();
              } else {
                onReorder();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _SummaryAction.refresh,
                child: _MenuRow(
                  icon: Icons.refresh_rounded,
                  label: "به‌روزرسانی وضعیت",
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: _SummaryAction.reorder,
                child: _MenuRow(
                  icon: Icons.reorder_rounded,
                  label: "ویرایش ترتیب مراحل",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MenuRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final skin = _Skin.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: skin.inkMuted),
        const SizedBox(width: 10),
        Text(label, style: _text(context, size: 12.5, color: skin.ink)),
      ],
    );
  }
}

/// Circular percentage gauge. Animates between values so a step completion
/// reads as progress rather than a jump.
class _ProgressRing extends StatelessWidget {
  final double value;
  final int percent;
  final _Tone tone;

  const _ProgressRing({
    required this.value,
    required this.percent,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: "$percent درصد تکمیل شده",
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: 48,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value.clamp(0, 1)),
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeOutCubic,
          builder: (context, animated, _) => Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.square(
                dimension: 48,
                child: CircularProgressIndicator(
                  value: animated,
                  strokeWidth: 4.5,
                  strokeCap: StrokeCap.round,
                  backgroundColor: tone.fill.withValues(alpha: .16),
                  valueColor: AlwaysStoppedAnimation(tone.fill),
                ),
              ),
              Text(
                "$percent٪",
                style: _text(
                  context,
                  size: 11,
                  weight: FontWeight.w700,
                  color: tone.ink,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Timeline rows
// ---------------------------------------------------------------------------

enum _StepStatus { done, current, pending }

const double _kGutter = 40;
const double _kNodeSize = 32;
const double _kNodeTop = 2;

/// One step of the timeline.
///
/// Passive rows (done / pending) are flat; rows that carry actions are drawn
/// as cards so the single actionable step is unmistakable.
class _StepRow extends StatelessWidget {
  final DeviceFlowchartStep step;
  final int? number;
  final _StepStatus status;
  final bool connector;
  final bool isLast;
  final bool isSettlement;
  final bool canRevert;
  final bool wide;
  final bool submitting;
  final VoidCallback? onComplete;
  final VoidCallback? onCompleteWithNote;
  final VoidCallback? onRevert;

  const _StepRow({
    super.key,
    required this.step,
    this.number,
    required this.status,
    this.connector = false,
    this.isLast = false,
    this.isSettlement = false,
    this.canRevert = false,
    this.wide = true,
    this.submitting = false,
    this.onComplete,
    this.onCompleteWithNote,
    this.onRevert,
  });

  bool get _actionable => onComplete != null || onCompleteWithNote != null;

  @override
  Widget build(BuildContext context) {
    final skin = _Skin.of(context);
    final tone = isSettlement ? skin.warning : skin.accent;

    // [IntrinsicHeight] lets the connector fill whatever height the step
    // content ends up needing (notes, actions, wrapped titles). It is the only
    // reliable way to do this without a manual height pass; the list is short
    // enough for the extra measurement to be free.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _kGutter,
            child: Column(
              children: [
                const SizedBox(height: _kNodeTop),
                _StepNode(
                  status: status,
                  number: number,
                  isSettlement: isSettlement,
                  tone: tone,
                  skin: skin,
                ),
                if (connector)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.only(top: 5),
                      decoration: BoxDecoration(
                        color: status == _StepStatus.done
                            ? skin.success.fill.withValues(alpha: .32)
                            : skin.line,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: _actionable
                    ? const EdgeInsets.fromLTRB(12, 11, 12, 12)
                    : const EdgeInsets.symmetric(vertical: 9),
                decoration: _actionable
                    ? BoxDecoration(
                        color: Color.alphaBlend(
                          tone.fill.withValues(alpha: .05),
                          skin.surface,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: tone.fill.withValues(alpha: .34),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: tone.fill.withValues(alpha: .07),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      )
                    : null,
                child: _content(context, skin, tone),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, _Skin skin, _Tone tone) {
    final done = status == _StepStatus.done;
    final stamp = _stampLabel(step.doneAt);
    final person = _personLabel(step.doneBy);
    final note = step.note.trim();
    final hasMeta = done && (stamp != null || person != null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                step.label,
                style: _text(
                  context,
                  size: 13,
                  weight: done ? FontWeight.w500 : FontWeight.w700,
                  color: status == _StepStatus.pending
                      ? skin.inkMuted
                      : skin.ink,
                  height: 1.45,
                ),
              ),
            ),
            if (isSettlement) ...[
              const SizedBox(width: 8),
              _Pill(
                text: done ? "تسویه شده" : "در انتظار تسویه",
                tone: done ? skin.success : skin.warning,
              ),
            ] else if (status == _StepStatus.current) ...[
              const SizedBox(width: 8),
              _Pill(text: "مرحله جاری", tone: skin.accent),
            ],
            if (canRevert) ...[
              const SizedBox(width: 4),
              _RevertButton(
                tone: done && isSettlement ? skin.warning : skin.neutral,
                tooltip: isSettlement ? "لغو تسویه" : "بازگردانی این مرحله",
                onPressed: submitting ? null : onRevert,
              ),
            ],
          ],
        ),
        if (hasMeta) ...[
          const SizedBox(height: 5),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (stamp != null)
                _MetaItem(icon: Icons.event_available_rounded, text: stamp),
              if (person != null)
                _MetaItem(icon: Icons.person_outline_rounded, text: person),
            ],
          ),
        ],
        if (note.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsetsDirectional.fromSTEB(10, 7, 10, 8),
            decoration: BoxDecoration(
              color: skin.ink.withValues(alpha: .035),
              borderRadius: BorderRadius.circular(8),
              border: BorderDirectional(
                start: BorderSide(
                  color: done
                      ? skin.success.fill.withValues(alpha: .45)
                      : skin.lineStrong,
                  width: 2.5,
                ),
              ),
            ),
            child: Text(
              note,
              style: _text(
                context,
                size: 11.5,
                color: skin.inkMuted,
                height: 1.6,
              ),
            ),
          ),
        ],
        if (_actionable) ...[
          const SizedBox(height: 11),
          _ActionsRow(
            tone: tone,
            skin: skin,
            wide: wide,
            submitting: submitting,
            primaryLabel: isSettlement ? "ثبت تسویه" : "تکمیل مرحله",
            onComplete: onComplete,
            onCompleteWithNote: onCompleteWithNote,
          ),
        ],
      ],
    );
  }
}

/// Status node in the timeline gutter: numbered when pending, checked when
/// done, filled with the accent when it is the current step.
class _StepNode extends StatelessWidget {
  final _StepStatus status;
  final int? number;
  final bool isSettlement;
  final _Tone tone;
  final _Skin skin;

  const _StepNode({
    required this.status,
    required this.number,
    required this.isSettlement,
    required this.tone,
    required this.skin,
  });

  @override
  Widget build(BuildContext context) {
    final done = status == _StepStatus.done;
    final current = status == _StepStatus.current;

    final Color background;
    final Color border;
    final Color foreground;
    if (done) {
      background = skin.success.tint;
      border = skin.success.fill.withValues(alpha: .45);
      foreground = skin.success.ink;
    } else if (current) {
      background = tone.fill;
      border = tone.fill;
      foreground = Colors.white;
    } else if (isSettlement) {
      background = tone.tint;
      border = tone.fill.withValues(alpha: .40);
      foreground = tone.ink;
    } else {
      background = skin.surface;
      border = skin.lineStrong;
      foreground = skin.inkFaint;
    }

    final Widget child;
    if (done) {
      child = Icon(Icons.check_rounded, size: 17, color: foreground);
    } else if (isSettlement) {
      child = Icon(Icons.payments_outlined, size: 15, color: foreground);
    } else {
      child = Text(
        "${number ?? ''}",
        style: _text(
          context,
          size: 12,
          weight: FontWeight.w700,
          color: foreground,
          height: 1,
        ),
      );
    }

    return Semantics(
      label: done
          ? "انجام شده"
          : current
          ? "مرحله جاری"
          : "در انتظار انجام",
      excludeSemantics: true,
      child: Container(
        width: _kNodeSize,
        height: _kNodeSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          shape: isSettlement ? BoxShape.rectangle : BoxShape.circle,
          borderRadius: isSettlement ? BorderRadius.circular(10) : null,
          border: Border.all(color: border, width: current ? 1.5 : 1.2),
          boxShadow: current
              ? [
                  BoxShadow(
                    color: tone.fill.withValues(alpha: .26),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final skin = _Skin.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: skin.inkFaint),
        const SizedBox(width: 4),
        Text(
          text,
          style: _text(context, size: 11, color: skin.inkMuted, height: 1.4),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final _Tone tone;
  final IconData? icon;

  const _Pill({required this.text, required this.tone, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tone.tint,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tone.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: tone.ink),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            maxLines: 1,
            style: _text(
              context,
              size: 10.5,
              weight: FontWeight.w700,
              color: tone.ink,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _RevertButton extends StatelessWidget {
  final _Tone tone;
  final String tooltip;
  final VoidCallback? onPressed;

  const _RevertButton({
    required this.tone,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      iconSize: 17,
      style: IconButton.styleFrom(
        foregroundColor: tone.ink,
        backgroundColor: tone.fill.withValues(alpha: .07),
        hoverColor: tone.fill.withValues(alpha: .14),
        minimumSize: const Size.square(36),
        maximumSize: const Size.square(36),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: const Icon(Icons.undo_rounded),
    );
  }
}

/// Primary + optional-note actions of an actionable step.
class _ActionsRow extends StatelessWidget {
  final _Tone tone;
  final _Skin skin;
  final bool wide;
  final bool submitting;
  final String primaryLabel;
  final VoidCallback? onComplete;
  final VoidCallback? onCompleteWithNote;

  const _ActionsRow({
    required this.tone,
    required this.skin,
    required this.wide,
    required this.submitting,
    required this.primaryLabel,
    required this.onComplete,
    required this.onCompleteWithNote,
  });

  @override
  Widget build(BuildContext context) {
    final primary = FilledButton.icon(
      onPressed: submitting ? null : onComplete,
      icon: submitting
          ? const SizedBox.square(
              dimension: 15,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.check_rounded, size: 18),
      label: Text(submitting ? "در حال ثبت..." : primaryLabel),
      style: FilledButton.styleFrom(
        backgroundColor: tone.fill,
        foregroundColor: Colors.white,
        disabledBackgroundColor: tone.fill.withValues(alpha: .40),
        disabledForegroundColor: Colors.white.withValues(alpha: .85),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: _text(
          context,
          size: 12.5,
          weight: FontWeight.w700,
          height: 1.3,
        ),
      ),
    );

    if (!wide) {
      return Row(
        children: [
          Expanded(child: primary),
          const SizedBox(width: 8),
          IconButton.outlined(
            onPressed: submitting ? null : onCompleteWithNote,
            tooltip: "تکمیل با یادداشت",
            iconSize: 19,
            style: IconButton.styleFrom(
              foregroundColor: skin.inkMuted,
              side: BorderSide(color: skin.lineStrong),
              minimumSize: const Size.square(44),
              maximumSize: const Size.square(44),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.edit_note_rounded),
          ),
        ],
      );
    }

    return Row(
      children: [
        primary,
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: submitting ? null : onCompleteWithNote,
          icon: const Icon(Icons.edit_note_rounded, size: 18),
          label: const Text("یادداشت"),
          style: OutlinedButton.styleFrom(
            foregroundColor: skin.inkMuted,
            side: BorderSide(color: skin.lineStrong),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: _text(
              context,
              size: 12.5,
              weight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

/// Header separating the unordered settlement steps from the ordered flow.
class _SettlementHeader extends StatelessWidget {
  final bool hasOrdered;

  const _SettlementHeader({required this.hasOrdered});

  @override
  Widget build(BuildContext context) {
    final skin = _Skin.of(context);
    return Container(
      margin: EdgeInsets.only(top: hasOrdered ? 10 : 0, bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: skin.warning.tint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: skin.warning.fill.withValues(alpha: .22)),
      ),
      child: Row(
        children: [
          Icon(Icons.payments_outlined, size: 16, color: skin.warning.ink),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "تسویه حساب",
                  style: _text(
                    context,
                    size: 12,
                    weight: FontWeight.w700,
                    color: skin.warning.ink,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  "مستقل از ترتیب مراحل — هر زمان قابل ثبت یا لغو",
                  style: _text(
                    context,
                    size: 10.5,
                    color: skin.inkMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// States: skeleton / error / empty / template preview
// ---------------------------------------------------------------------------

/// Pulsing placeholder that mirrors the real layout, so the section does not
/// jump in height when data arrives.
class _FlowSkeleton extends StatefulWidget {
  const _FlowSkeleton();

  @override
  State<_FlowSkeleton> createState() => _FlowSkeletonState();
}

class _FlowSkeletonState extends State<_FlowSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curve;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _opacity = Tween<double>(begin: .45, end: 1).animate(_curve);
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skin = _Skin.of(context);
    final bone = skin.ink.withValues(alpha: .07);

    return FadeTransition(
      opacity: _opacity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 76,
            decoration: BoxDecoration(
              color: bone,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Container(
                    width: _kNodeSize,
                    height: _kNodeSize,
                    decoration: BoxDecoration(
                      color: bone,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: i.isEven ? 150 : 110,
                          height: 11,
                          decoration: BoxDecoration(
                            color: bone,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Container(
                          width: i.isEven ? 90 : 130,
                          height: 9,
                          decoration: BoxDecoration(
                            color: bone,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Centred icon + copy + single action, used for the error and empty states.
class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final skin = _Skin.of(context);
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 18, 8, 10),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: skin.ink.withValues(alpha: .05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: skin.inkFaint),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: _text(
                context,
                size: 13,
                weight: FontWeight.w700,
                color: skin.ink,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: _text(
                context,
                size: 11.5,
                color: skin.inkMuted,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.tonalIcon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(actionLabel),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: _text(
                  context,
                  size: 12.5,
                  weight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when `retrieve/` returns nothing: fall back to the global template
/// so the section is never blank, with the same reorder entry point.
class _TemplatePreview extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onReorder;

  const _TemplatePreview({required this.onRetry, required this.onReorder});

  @override
  Widget build(BuildContext context) {
    final skin = _Skin.of(context);
    final provider = context.watch<DeviceProvider>();
    final items = provider.flowchartOrderedItems.isNotEmpty
        ? provider.flowchartOrderedItems
        : provider.flowchartItems;
    final loading =
        provider.flowchartOrderedLoading || provider.flowchartLoading;

    if (loading && items.isEmpty) return const _FlowSkeleton();

    if (items.isEmpty) {
      return _MessageState(
        icon: Icons.route_outlined,
        title: "مرحله‌ای برای این دستگاه تعریف نشده است",
        message:
            "پس از تعریف قالب مراحل، پیشرفت این دستگاه اینجا نمایش داده می‌شود.",
        actionLabel: "تلاش مجدد",
        onAction: onRetry,
      );
    }

    final sorted = List<FlowchartItem>.from(items)
      ..sort((a, b) => a.order.compareTo(b.order));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: skin.ink.withValues(alpha: .035),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: skin.line),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: skin.inkFaint),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "برای این دستگاه هنوز پیشرفتی ثبت نشده است. مراحل قالب به این ترتیب است:",
                  style: _text(
                    context,
                    size: 11,
                    color: skin.inkMuted,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < sorted.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: skin.ink.withValues(alpha: .05),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    "${i + 1}",
                    style: _text(
                      context,
                      size: 10.5,
                      weight: FontWeight.w700,
                      color: skin.inkFaint,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    sorted[i].label,
                    style: _text(
                      context,
                      size: 12,
                      color: skin.inkMuted,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: onReorder,
            icon: const Icon(Icons.reorder_rounded, size: 17),
            label: const Text("ویرایش ترتیب مراحل"),
            style: TextButton.styleFrom(
              foregroundColor: skin.accent.ink,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              textStyle: _text(
                context,
                size: 12,
                weight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Slim notice shown when a refresh failed but cached data is still on screen.
class _StaleBanner extends StatelessWidget {
  final VoidCallback onRetry;

  const _StaleBanner({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final skin = _Skin.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsetsDirectional.fromSTEB(10, 4, 4, 4),
      decoration: BoxDecoration(
        color: skin.warning.tint,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: skin.warning.fill.withValues(alpha: .22)),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, size: 15, color: skin.warning.ink),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "آخرین اطلاعات ذخیره‌شده نمایش داده می‌شود.",
              style: _text(
                context,
                size: 10.5,
                color: skin.inkMuted,
                height: 1.5,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: skin.warning.ink,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              textStyle: _text(
                context,
                size: 11,
                weight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            child: const Text("به‌روزرسانی"),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Modals
// ---------------------------------------------------------------------------

/// Shared modal shell: a centred dialog on wide screens, a bottom sheet on
/// phones — same content, correct ergonomics for each.
Future<T?> _showFlowModal<T>(BuildContext context, WidgetBuilder builder) {
  final scheme = Theme.of(context).colorScheme;
  final wide = MediaQuery.sizeOf(context).width >= 720;

  if (wide) {
    return showDialog<T>(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          backgroundColor: scheme.surface,
          surfaceTintColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 470),
            child: builder(context),
          ),
        ),
      ),
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: scheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: SingleChildScrollView(child: builder(sheetContext)),
      ),
    ),
  );
}

/// Header used by every modal in this file.
class _ModalHeader extends StatelessWidget {
  final IconData icon;
  final _Tone tone;
  final String title;
  final String? subtitle;
  final VoidCallback? onClose;

  const _ModalHeader({
    required this.icon,
    required this.tone,
    required this.title,
    this.subtitle,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final skin = _Skin.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: tone.tint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: tone.ink),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: _text(
                  context,
                  size: 14,
                  weight: FontWeight.w700,
                  color: skin.ink,
                  height: 1.4,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _text(
                    context,
                    size: 11.5,
                    color: skin.inkMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (onClose != null)
          IconButton(
            onPressed: onClose,
            tooltip: "بستن",
            iconSize: 20,
            visualDensity: VisualDensity.compact,
            color: skin.inkMuted,
            icon: const Icon(Icons.close_rounded),
          ),
      ],
    );
  }
}

/// Completes a step together with an optional note.
class _NoteSheet extends StatefulWidget {
  final int deviceId;
  final DeviceFlowchartStep step;
  final bool isSettlement;

  const _NoteSheet({
    required this.deviceId,
    required this.step,
    required this.isSettlement,
  });

  @override
  State<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<_NoteSheet> {
  final _note = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final status = await context.read<DeviceProvider>().completeFlowchartStep(
        deviceId: widget.deviceId,
        flowchartItemId: widget.step.flowchartItemId,
        note: _note.text.trim(),
      );
      if (!mounted) return;
      if (status == 200) {
        filledSuccessToast(title: "مرحله «${widget.step.label}» تکمیل شد");
        Navigator.pop(context);
      } else if (status == -1) {
        setState(() {
          _saving = false;
          _error = "ارتباط با سرور برقرار نشد. دوباره تلاش کنید.";
        });
      } else {
        setState(() {
          _saving = false;
          _error = "ثبت مرحله ناموفق بود (کد $status). دوباره تلاش کنید.";
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = "خطا در ارتباط با سرور. دوباره تلاش کنید.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final skin = _Skin.of(context);
    final tone = widget.isSettlement ? skin.warning : skin.accent;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: skin.lineStrong),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ModalHeader(
            icon: Icons.edit_note_rounded,
            tone: tone,
            title: widget.isSettlement
                ? "ثبت تسویه با یادداشت"
                : "تکمیل با یادداشت",
            subtitle: "«${widget.step.label}»",
            onClose: _saving ? null : () => Navigator.pop(context),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _note,
            autofocus: true,
            minLines: 3,
            maxLines: 5,
            textInputAction: TextInputAction.newline,
            style: _text(context, size: 13, color: skin.ink, height: 1.6),
            decoration: InputDecoration(
              hintText: "توضیح کوتاه درباره این مرحله (اختیاری)",
              hintStyle: _text(
                context,
                size: 12,
                color: skin.inkFaint,
                height: 1.6,
              ),
              filled: true,
              fillColor: skin.ink.withValues(alpha: .03),
              contentPadding: const EdgeInsets.all(12),
              border: border,
              enabledBorder: border,
              focusedBorder: border.copyWith(
                borderSide: BorderSide(color: tone.fill, width: 1.4),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 15,
                  color: skin.danger.ink,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _error!,
                    style: _text(
                      context,
                      size: 11,
                      color: skin.danger.ink,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _saving ? null : _submit,
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 18),
                  label: Text(_saving ? "در حال ثبت..." : "ثبت و تکمیل"),
                  style: FilledButton.styleFrom(
                    backgroundColor: tone.fill,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: tone.fill.withValues(alpha: .40),
                    disabledForegroundColor: Colors.white.withValues(
                      alpha: .85,
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: _text(
                      context,
                      size: 12.5,
                      weight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _saving ? null : () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: skin.inkMuted,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  textStyle: _text(
                    context,
                    size: 12.5,
                    weight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                child: const Text("انصراف"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Confirms reverting a completed step. Resolves to `true` when confirmed.
class _RevertDialog extends StatelessWidget {
  final DeviceFlowchartStep step;
  final bool isSettlement;

  const _RevertDialog({required this.step, required this.isSettlement});

  @override
  Widget build(BuildContext context) {
    final skin = _Skin.of(context);
    final tone = isSettlement ? skin.warning : skin.danger;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ModalHeader(
            icon: Icons.undo_rounded,
            tone: tone,
            title: isSettlement ? "لغو تسویه" : "بازگردانی مرحله",
            onClose: () => Navigator.pop(context, false),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: skin.ink.withValues(alpha: .035),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: skin.line),
            ),
            child: Text(
              isSettlement
                  ? "«${step.label}» از حالت تسویه‌شده خارج می‌شود و باید دوباره ثبت شود."
                  : "«${step.label}» به حالت ناتمام برمی‌گردد و باید دوباره تکمیل شود.",
              style: _text(
                context,
                size: 12,
                color: skin.inkMuted,
                height: 1.7,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.undo_rounded, size: 18),
                  label: Text(isSettlement ? "لغو تسویه" : "بازگردانی"),
                  style: FilledButton.styleFrom(
                    backgroundColor: tone.fill,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: _text(
                      context,
                      size: 12.5,
                      weight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(
                  foregroundColor: skin.inkMuted,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  textStyle: _text(
                    context,
                    size: 12.5,
                    weight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                child: const Text("انصراف"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Drag-to-reorder editor for the global step template.
class _ReorderSheet extends StatefulWidget {
  final List<FlowchartItem> initial;

  const _ReorderSheet({required this.initial});

  @override
  State<_ReorderSheet> createState() => _ReorderSheetState();
}

class _ReorderSheetState extends State<_ReorderSheet> {
  late List<FlowchartItem> _rows;
  late List<String> _initialOrder;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _rows = List<FlowchartItem>.from(widget.initial)
      ..sort((a, b) => a.order.compareTo(b.order));
    _initialOrder = _rows.map(_rowKey).toList();
  }

  String _rowKey(FlowchartItem item) =>
      "${item.itemId ?? 'x'}|${item.label}|${item.order}";

  bool get _dirty {
    if (_rows.length != _initialOrder.length) return true;
    for (var i = 0; i < _rows.length; i++) {
      if (_rowKey(_rows[i]) != _initialOrder[i]) return true;
    }
    return false;
  }

  bool get _hasMissingIds => _rows.any((row) => row.itemId == null);

  Future<void> _save() async {
    if (_saving || !_dirty || _hasMissingIds) return;
    setState(() => _saving = true);
    try {
      await context.read<DeviceProvider>().reorderFlowchartItems(_rows);
      if (!mounted) return;
      filledSuccessToast(title: "ترتیب مراحل ذخیره شد");
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      flatErrorToast(
        title: "ذخیره ترتیب ناموفق بود",
        description: e.toString(),
      );
    }
  }

  void _reset() {
    setState(() {
      _rows = List<FlowchartItem>.from(widget.initial)
        ..sort((a, b) => a.order.compareTo(b.order));
    });
  }

  @override
  Widget build(BuildContext context) {
    final skin = _Skin.of(context);

    if (_rows.length < 2) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ModalHeader(
              icon: Icons.reorder_rounded,
              tone: skin.accent,
              title: "ترتیب مراحل",
              subtitle: "برای جابه‌جایی حداقل دو مرحله لازم است.",
              onClose: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () => Navigator.pop(context),
              child: const Text("بستن"),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ModalHeader(
            icon: Icons.reorder_rounded,
            tone: skin.accent,
            title: "ترتیب مراحل",
            subtitle: "این ترتیب برای همه دستگاه‌های پروژه اعمال می‌شود.",
            onClose: _saving ? null : () => Navigator.pop(context),
          ),
          const SizedBox(height: 14),
          if (_hasMissingIds) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: skin.warning.tint,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: skin.warning.fill.withValues(alpha: .22),
                ),
              ),
              child: Text(
                "برخی مراحل شناسه ندارند و ذخیره ممکن نیست.",
                style: _text(
                  context,
                  size: 11,
                  color: skin.warning.ink,
                  height: 1.5,
                ),
              ),
            ),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: (MediaQuery.sizeOf(context).height * .5).clamp(
                180.0,
                380.0,
              ),
            ),
            child: ReorderableListView.builder(
              shrinkWrap: true,
              buildDefaultDragHandles: false,
              itemCount: _rows.length,
              onReorderItem: (oldIndex, newIndex) {
                setState(() {
                  final moved = _rows.removeAt(oldIndex);
                  _rows.insert(newIndex, moved);
                });
              },
              proxyDecorator: (child, index, animation) => Material(
                elevation: 6,
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: child,
              ),
              itemBuilder: (context, index) {
                final item = _rows[index];
                return Container(
                  key: ObjectKey(item),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
                  decoration: BoxDecoration(
                    color: skin.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: skin.line),
                  ),
                  child: Row(
                    children: [
                      ReorderableDragStartListener(
                        index: index,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.grab,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              Icons.drag_indicator_rounded,
                              size: 20,
                              color: skin.inkFaint,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: skin.accent.tint,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          "${index + 1}",
                          style: _text(
                            context,
                            size: 10.5,
                            weight: FontWeight.w700,
                            color: skin.accent.ink,
                            height: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _text(
                                context,
                                size: 12.5,
                                weight: FontWeight.w600,
                                color: skin.ink,
                                height: 1.5,
                              ),
                            ),
                            if (item.description.trim().isNotEmpty)
                              Text(
                                item.description.trim(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _text(
                                  context,
                                  size: 10.5,
                                  color: skin.inkFaint,
                                  height: 1.5,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (_dirty)
                TextButton(
                  onPressed: _saving ? null : _reset,
                  style: TextButton.styleFrom(
                    foregroundColor: skin.inkMuted,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 13,
                    ),
                    textStyle: _text(
                      context,
                      size: 12,
                      weight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  child: const Text("بازگردانی"),
                ),
              const Spacer(),
              FilledButton.icon(
                onPressed: (_saving || !_dirty || _hasMissingIds)
                    ? null
                    : _save,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded, size: 18),
                label: Text(_saving ? "در حال ذخیره..." : "ذخیره ترتیب"),
                style: FilledButton.styleFrom(
                  backgroundColor: skin.accent.fill,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: skin.accent.fill.withValues(
                    alpha: .35,
                  ),
                  disabledForegroundColor: Colors.white.withValues(alpha: .85),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: _text(
                    context,
                    size: 12.5,
                    weight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Model + helpers
// ---------------------------------------------------------------------------

/// Display model: ordered steps (sequential) and settlement steps
/// (independent), plus the derived positions the UI needs.
class _FlowModel {
  final List<DeviceFlowchartStep> ordered;
  final List<DeviceFlowchartStep> settlement;
  final int doneCount;
  final int total;

  /// Index in [ordered] of the first pending step — the only actionable one.
  final int? currentIndex;

  /// Index in [ordered] of the most recent completed step, which is the only
  /// ordered step that may be reverted.
  final int? undoIndex;

  const _FlowModel({
    required this.ordered,
    required this.settlement,
    required this.doneCount,
    required this.total,
    required this.currentIndex,
    required this.undoIndex,
  });

  bool get isEmpty => ordered.isEmpty && settlement.isEmpty;
  bool get isComplete => total > 0 && doneCount == total;
  double get progress => total == 0 ? 0 : doneCount / total;
  int get percent => (progress * 100).round();

  /// First step still waiting for action, ordered steps first.
  DeviceFlowchartStep? get nextStep {
    final index = currentIndex;
    if (index != null) return ordered[index];
    for (final step in settlement) {
      if (!step.isDone) return step;
    }
    return null;
  }

  factory _FlowModel.from(List<DeviceFlowchartStep> steps) {
    final ordered = <DeviceFlowchartStep>[];
    final settlement = <DeviceFlowchartStep>[];
    for (final step in steps) {
      if (_isSettlementStep(step) || step.order <= 0) {
        settlement.add(step);
      } else {
        ordered.add(step);
      }
    }
    ordered.sort((a, b) => a.order.compareTo(b.order));

    var done = 0;
    for (final step in steps) {
      if (step.isDone) done++;
    }

    final currentIndex = ordered.indexWhere((step) => !step.isDone);
    final undoIndex = ordered.lastIndexWhere((step) => step.isDone);

    return _FlowModel(
      ordered: ordered,
      settlement: settlement,
      doneCount: done,
      total: steps.length,
      currentIndex: currentIndex < 0 ? null : currentIndex,
      undoIndex: undoIndex < 0 ? null : undoIndex,
    );
  }
}

/// Settlement steps ("تسویه حساب" / "تسویه حساب با نماینده") are detected by
/// their label — the backend creates them without a usable `order`, and they
/// are actioned independently of the ordered steps.
bool _isSettlementStep(DeviceFlowchartStep step) =>
    step.label.contains('تسویه');

/// Human-readable completion stamp. The API sends Jalali strings such as
/// `1403/05/12 14:22:31`; normalise padding and drop the seconds.
String? _stampLabel(String? raw) {
  final text = (raw ?? '').trim();
  if (text.isEmpty || text == 'null') return null;
  final match = RegExp(
    r'^(\d{4})[/-](\d{1,2})[/-](\d{1,2})(?:[T ](\d{1,2}):(\d{2}))?',
  ).firstMatch(text);
  if (match == null) return text;
  final date =
      "${match[1]}/${match[2]!.padLeft(2, '0')}/${match[3]!.padLeft(2, '0')}";
  if (match[4] == null) return date;
  return "$date - ${match[4]!.padLeft(2, '0')}:${match[5]}";
}

/// `done_by` arrives either as a display name or as an object; both resolve to
/// something readable, and never to the literal "null".
String? _personLabel(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    final text = value.trim();
    return (text.isEmpty || text == 'null') ? null : text;
  }
  if (value is Map) {
    for (final key in const [
      'full_name',
      'name',
      'display_name',
      'username',
      'phone',
    ]) {
      final candidate = value[key];
      if (candidate == null) continue;
      final text = candidate.toString().trim();
      if (text.isNotEmpty && text != 'null') return text;
    }
    final id = value['id'];
    return id == null ? null : "#$id";
  }
  final text = value.toString().trim();
  return (text.isEmpty || text == 'null') ? null : text;
}

/// Shared text style helper: the app uses Vazirmatn with no tracking, and
/// explicit sizes here keep the dense timeline readable.
TextStyle _text(
  BuildContext context, {
  double size = 13,
  FontWeight weight = FontWeight.w500,
  Color? color,
  double height = 1.5,
}) {
  final base = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
  return base.copyWith(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: 0,
  );
}

// ---------------------------------------------------------------------------
// Colour system
// ---------------------------------------------------------------------------

/// A semantic colour set: a solid fill (buttons), a readable ink (text/icons
/// on the surface) and a translucent tint (backgrounds/borders).
@immutable
class _Tone {
  final Color fill;
  final Color ink;
  final Color tint;

  const _Tone({required this.fill, required this.ink, required this.tint});

  Color get border => ink.withValues(alpha: .30);
}

/// Theme-derived palette. Explicit values (instead of the M3 baseline
/// `surfaceContainer*` greys) keep light and dark surfaces neutral rather than
/// purple-tinted, and guarantee readable contrast for the small type used in
/// the timeline.
@immutable
class _Skin {
  final Color surface;
  final Color ink;
  final Color inkMuted;
  final Color inkFaint;
  final Color line;
  final Color lineStrong;
  final _Tone accent;
  final _Tone success;
  final _Tone warning;
  final _Tone danger;
  final _Tone neutral;

  const _Skin({
    required this.surface,
    required this.ink,
    required this.inkMuted,
    required this.inkFaint,
    required this.line,
    required this.lineStrong,
    required this.accent,
    required this.success,
    required this.warning,
    required this.danger,
    required this.neutral,
  });

  static _Skin of(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final on = scheme.onSurface;

    if (theme.brightness == Brightness.dark) {
      return _Skin(
        surface: scheme.surface,
        ink: on,
        inkMuted: on.withValues(alpha: .70),
        inkFaint: on.withValues(alpha: .48),
        line: on.withValues(alpha: .10),
        lineStrong: on.withValues(alpha: .20),
        accent: _Tone(
          fill: const Color(0xFF1976D2),
          ink: const Color(0xFF90CAF9),
          tint: const Color(0xFF90CAF9).withValues(alpha: .14),
        ),
        success: _Tone(
          fill: const Color(0xFF2E7D32),
          ink: const Color(0xFF81C784),
          tint: const Color(0xFF81C784).withValues(alpha: .14),
        ),
        warning: _Tone(
          fill: const Color(0xFFB26A00),
          ink: const Color(0xFFFFB74D),
          tint: const Color(0xFFFFB74D).withValues(alpha: .14),
        ),
        danger: _Tone(
          fill: const Color(0xFFC62828),
          ink: const Color(0xFFFF8A80),
          tint: const Color(0xFFFF8A80).withValues(alpha: .12),
        ),
        neutral: _Tone(
          fill: on,
          ink: on.withValues(alpha: .72),
          tint: on.withValues(alpha: .08),
        ),
      );
    }

    return _Skin(
      surface: scheme.surface,
      ink: on,
      inkMuted: on.withValues(alpha: .62),
      inkFaint: on.withValues(alpha: .42),
      line: on.withValues(alpha: .09),
      lineStrong: on.withValues(alpha: .16),
      accent: _Tone(
        fill: Color.lerp(scheme.primary, Colors.black, .18)!,
        ink: Color.lerp(scheme.primary, Colors.black, .34)!,
        tint: scheme.primary.withValues(alpha: .09),
      ),
      success: _Tone(
        fill: const Color(0xFF2E7D32),
        ink: const Color(0xFF2E7D32),
        tint: const Color(0xFF2E7D32).withValues(alpha: .09),
      ),
      warning: _Tone(
        fill: const Color(0xFFB26A00),
        ink: const Color(0xFFA15C00),
        tint: const Color(0xFFB26A00).withValues(alpha: .09),
      ),
      danger: _Tone(
        fill: const Color(0xFFB3261E),
        ink: const Color(0xFFB3261E),
        tint: const Color(0xFFB3261E).withValues(alpha: .08),
      ),
      neutral: _Tone(
        fill: on,
        ink: on.withValues(alpha: .58),
        tint: on.withValues(alpha: .06),
      ),
    );
  }
}
