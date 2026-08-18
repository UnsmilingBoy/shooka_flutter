import 'package:flutter/material.dart';
import 'package:shooka_flutter/models/software_support_data_class.dart';
import 'package:shooka_flutter/utils/dropdowns/searchable_dropdown_with_label.dart';
import 'package:shooka_flutter/utils/textfields/outline_textfield_with_label.dart';

/// Shared fields for choosing the requester of a support event.
/// Supports the three `requester_phone_type` options:
/// - profile_phone : use the phone number stored on the user profile
/// - custom_phone  : use a custom phone number for a registered user
/// - external      : use a name + phone number of an external requester
class SupportRequesterFields extends StatefulWidget {
  final String? initialType;
  final int? initialUserId;
  final List<SupportEventUser> users;
  final TextEditingController phoneController;
  final TextEditingController externalNameController;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<int?> onUserIdChanged;

  /// Server-side search for the user dropdown. Receives the typed text and
  /// must return the matching users.
  final Future<List<SupportEventUser>> Function(String filter)? searchUsers;

  const SupportRequesterFields({
    super.key,
    this.initialType = 'profile_phone',
    this.initialUserId,
    required this.users,
    required this.phoneController,
    required this.externalNameController,
    required this.onTypeChanged,
    required this.onUserIdChanged,
    this.searchUsers,
  });

  @override
  State<SupportRequesterFields> createState() =>
      _SupportRequesterFieldsState();
}

class _SupportRequesterFieldsState extends State<SupportRequesterFields> {
  late String _type;
  String? _selectedUserId;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? 'profile_phone';
    _selectedUserId = widget.initialUserId?.toString();
  }

  @override
  void didUpdateWidget(SupportRequesterFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialUserId != widget.initialUserId) {
      _selectedUserId = widget.initialUserId?.toString();
    }
  }

  void _setType(String type) {
    setState(() {
      _type = type;
    });
    widget.onTypeChanged(type);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("نوع شماره تماس درخواست‌دهنده"),
        SizedBox(height: 5),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTypeChip('profile_phone', 'شماره پروفایل'),
            _buildTypeChip('custom_phone', 'شماره جدید'),
            _buildTypeChip('external', 'کاربر خارجی'),
          ],
        ),
        SizedBox(height: 10),
        if (_type == 'profile_phone' || _type == 'custom_phone')
          SearchableDropdownWithLabel(
            initialValue: _selectedUserId,
            iconOnPressed: () => setState(() {
              _selectedUserId = null;
              widget.onUserIdChanged(null);
            }),
            items: widget.users
                .map<DropdownItemModel>(
                  (user) => DropdownItemModel(
                    value: user.id.toString(),
                    label: user.fullName,
                  ),
                )
                .toList(),
            loadItems: widget.searchUsers == null
                ? null
                : (filter) async {
                    final users = await widget.searchUsers!(filter);
                    return users
                        .map<DropdownItemModel>(
                          (user) => DropdownItemModel(
                            value: user.id.toString(),
                            label: user.fullName,
                          ),
                        )
                        .toList();
                  },
            onChanged: (value) {
              setState(() {
                _selectedUserId = value;
              });
              widget.onUserIdChanged(
                value != null ? int.tryParse(value) : null,
              );
            },
            label: "کاربر",
            placeholder: "انتخاب کاربر...",
          ),
        if (_type == 'custom_phone' || _type == 'external')
          Outlinetextfieldwithlabel(
            label: "شماره تلفن",
            controller: widget.phoneController,
            placeHolder: "شماره تلفن...",
            isSerialNumber: true,
          ),
        if (_type == 'external')
          Outlinetextfieldwithlabel(
            label: "نام درخواست‌دهنده",
            controller: widget.externalNameController,
            placeHolder: "نام و نام خانوادگی...",
          ),
      ],
    );
  }

  Widget _buildTypeChip(String type, String label) {
    final selected = _type == type;
    return InkWell(
      onTap: () => _setType(type),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: selected ? Colors.white : null,
          ),
        ),
      ),
    );
  }
}
