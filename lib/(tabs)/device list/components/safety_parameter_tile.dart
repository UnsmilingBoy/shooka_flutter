import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/buttons/my_icon_button.dart';

class SafetyParameterTile extends StatelessWidget {
  final String label;
  final String description;
  final String? selectedValue;
  final TextEditingController? rejectionNoteController;
  final Function(String?) onChanged;

  const SafetyParameterTile({
    super.key,
    required this.label,
    required this.description,
    required this.selectedValue,
    this.rejectionNoteController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Single row with label, info button, and approve/reject buttons
        Row(
          children: [
            Text(label),
            MyIconButton(
              padding: EdgeInsets.all(5),
              child: const Icon(Icons.info_outline, size: 20),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => Directionality(
                    textDirection: TextDirection.rtl,
                    child: AlertDialog(
                      title: Text(label),
                      content: Text(description),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('متوجه شدم'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Spacer(),
            // Approve button
            MyIconButton(
              onPressed: () => onChanged('approved'),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: Border.all(
                color: selectedValue == 'approved'
                    ? Colors.green
                    : Colors.grey.shade700,
                width: 1,
              ),
              color: selectedValue == 'approved'
                  ? Colors.green.withOpacity(0.2)
                  : Colors.transparent,
              child: Row(
                spacing: 4,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: selectedValue == 'approved'
                        ? Colors.green
                        : Colors.grey,
                  ),
                  if (MediaQuery.sizeOf(context).width > 380)
                    Text(
                      'تایید',
                      style: TextStyle(
                        fontSize: 13,
                        color: selectedValue == 'approved'
                            ? Colors.green
                            : Colors.grey,
                        fontWeight: selectedValue == 'approved'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Reject button
            MyIconButton(
              onPressed: () => onChanged('rejected'),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: Border.all(
                color: selectedValue == 'rejected'
                    ? Colors.red
                    : Colors.grey.shade700,
                width: 1,
              ),
              color: selectedValue == 'rejected'
                  ? Colors.red.withOpacity(0.2)
                  : Colors.transparent,
              child: Row(
                spacing: 4,
                children: [
                  Icon(
                    Icons.cancel_outlined,
                    size: 18,
                    color: selectedValue == 'rejected'
                        ? Colors.red
                        : Colors.grey,
                  ),
                  if (MediaQuery.sizeOf(context).width > 380)
                    Text(
                      'رد',
                      style: TextStyle(
                        fontSize: 13,
                        color: selectedValue == 'rejected'
                            ? Colors.red
                            : Colors.grey,
                        fontWeight: selectedValue == 'rejected'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        // Conditional rejection note textarea
        if (selectedValue == 'rejected' && rejectionNoteController != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('دلیل رد*'),
              const SizedBox(height: 3),
              TextFormField(
                controller: rejectionNoteController,
                maxLines: 3,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.labelMedium,
                decoration: InputDecoration(
                  hintText: 'توضیحات دلیل رد...',
                  hintStyle: Theme.of(context).textTheme.labelSmall,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 13,
                    horizontal: 5,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade700,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}
