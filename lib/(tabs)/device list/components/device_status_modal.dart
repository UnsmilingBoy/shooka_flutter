import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/providers/device_provider.dart';
import 'package:shooka_flutter/utils/textfields/outline_textfield.dart';
import 'package:shooka_flutter/utils/toastifications/toasts.dart';

class DeviceStatusModal extends StatefulWidget {
  final int deviceId;
  final String deviceName;
  final bool?
  currentStatus; // true = approved, false = rejected, null = pending

  const DeviceStatusModal({
    super.key,
    required this.deviceId,
    required this.deviceName,
    this.currentStatus,
  });

  @override
  State<DeviceStatusModal> createState() => _DeviceStatusModalState();
}

class _DeviceStatusModalState extends State<DeviceStatusModal> {
  final TextEditingController _rejectionNoteController =
      TextEditingController();
  bool _isLoading = false;
  bool?
  _selectedStatus; // null = not selected yet, true = approve, false = reject

  @override
  void dispose() {
    _rejectionNoteController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_selectedStatus == null) {
      flatErrorToast(title: 'لطفا یک وضعیت را انتخاب کنید');
      return;
    }

    // For rejection, note is required
    if (_selectedStatus == false &&
        _rejectionNoteController.text.trim().isEmpty) {
      flatErrorToast(title: 'لطفا دلیل رد را وارد کنید');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final deviceProvider = context.read<DeviceProvider>();
      final result = await deviceProvider.updateDeviceStatus(
        deviceId: widget.deviceId,
        status: _selectedStatus!,
        rejectionNote: _selectedStatus == true
            ? null
            : _rejectionNoteController.text.trim(),
      );

      if (result == 200) {
        filledSuccessToast(
          title: _selectedStatus == true
              ? 'دستگاه با موفقیت تایید شد'
              : 'دستگاه با موفقیت رد شد',
        );
        if (mounted) Navigator.pop(context);
      } else {
        flatErrorToast(title: 'خطا در بروزرسانی وضعیت دستگاه');
      }
    } catch (e) {
      flatErrorToast(title: 'خطا: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildStatusOption({
    required String label,
    required bool? value,
    required Color color,
    required IconData icon,
  }) {
    final isSelected = _selectedStatus == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: isSelected ? color : null,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomModalTemplate(
      title: 'تغییر وضعیت دستگاه',
      children: [
        // Device name
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Text('دستگاه: ', style: Theme.of(context).textTheme.labelMedium),
              Expanded(
                child: Text(
                  widget.deviceName,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
        ),

        // Current status info
        if (widget.currentStatus != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Text(
                  'وضعیت فعلی: ',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.currentStatus == true
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: widget.currentStatus == true
                          ? Colors.green
                          : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    widget.currentStatus == true ? 'تأیید شده' : 'رد شده',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: widget.currentStatus == true
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Status options
        Text(
          'وضعیت جدید را انتخاب کنید:',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        SizedBox(height: 12),
        _buildStatusOption(
          label: 'تأیید',
          value: true,
          color: Colors.green,
          icon: Icons.check_circle_outline,
        ),
        SizedBox(height: 8),
        _buildStatusOption(
          label: 'رد',
          value: false,
          color: Colors.red,
          icon: Icons.cancel_outlined,
        ),
        SizedBox(height: 16),

        // Rejection note field (only visible when reject is selected)
        if (_selectedStatus == false) ...[
          Text(
            'دلیل رد دستگاه:',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          SizedBox(height: 8),
          Outlinetextfield(
            controller: _rejectionNoteController,
            placeholder: 'دلیل رد را وارد کنید...',
          ),
          SizedBox(height: 16),
        ],

        // Buttons
        ModalBottomButtons(
          saveText: 'ذخیره',
          isLoading: _isLoading,
          onSave: _handleSubmit,
          saveColor: _selectedStatus == true
              ? Colors.green
              : _selectedStatus == false
              ? Colors.red
              : null,
        ),
      ],
    );
  }
}
