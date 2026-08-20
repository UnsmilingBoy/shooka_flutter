import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/providers/event_provider.dart';
import 'package:shooka_flutter/utils/toastifications/toasts.dart';

class ExportEventsModal extends StatefulWidget {
  const ExportEventsModal({super.key});

  @override
  State<ExportEventsModal> createState() => _ExportEventsModalState();
}

class _ExportEventsModalState extends State<ExportEventsModal> {
  bool _isDeviceEvents = false;
  bool _isSoftwareEvents = false;
  bool _exportLoading = false;

  bool get _hasSelection => _isDeviceEvents || _isSoftwareEvents;

  Future<void> _export() async {
    if (!_hasSelection) return;
    setState(() => _exportLoading = true);
    try {
      await context.read<EventProvider>().exportEventsToWord(
            isDeviceEvents: _isDeviceEvents,
            isSoftwareEvents: _isSoftwareEvents,
          );
      if (!mounted) return;
      Navigator.pop(context);
      filledSuccessToast(title: 'فایل ورد با موفقیت دانلود شد');
    } catch (e) {
      if (!mounted) return;
      setState(() => _exportLoading = false);
      flatErrorToast(
        title: 'خطا در دانلود فایل ورد',
        description: e.toString(),
      );
    }
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required VoidCallback onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: value ? 1 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: value
              ? Theme.of(context).colorScheme.primary.withOpacity(0.6)
              : Theme.of(context).colorScheme.outlineVariant.withOpacity(0.2),
          width: value ? 1.5 : 1,
        ),
      ),
      color: value
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.15)
          : Theme.of(context).colorScheme.surface,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onChanged,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: value,
                onChanged: (_) => onChanged(),
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomModalTemplate(
      title: "خروجی رویدادها",
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(
            "نوع رویدادهای مورد نظر برای خروجی را انتخاب کنید",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        _buildOption(
          icon: Icons.devices_other_rounded,
          title: "رویداد های نصاب ها",
          subtitle: "رویدادهای ثبت شده توسط نصاب ها",
          value: _isDeviceEvents,
          onChanged: () => setState(() => _isDeviceEvents = !_isDeviceEvents),
        ),
        _buildOption(
          icon: Icons.support_agent_rounded,
          title: "پشتیبانی نرم افزاری",
          subtitle: "رویدادهای پشتیبانی نرم افزاری",
          value: _isSoftwareEvents,
          onChanged: () =>
              setState(() => _isSoftwareEvents = !_isSoftwareEvents),
        ),
        ModalBottomButtons(
          saveText: "دانلود فایل ورد",
          isLoading: _exportLoading,
          onSave: (_hasSelection && !_exportLoading) ? _export : null,
        ),
      ],
    );
  }
}
