import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/(tabs)/profile/components/modal_template.dart';
import 'package:shooka_flutter/components/modal_bottom_buttons.dart';
import 'package:shooka_flutter/services/providers/accounting_provider.dart';
import 'package:shooka_flutter/utils/textfields/outline_textformfield.dart';
import 'package:shooka_flutter/utils/toastifications/toasts.dart';

class SetFactorIdModal extends StatefulWidget {
  final int factorId;
  final String? currentFactorNumber;
  final String? currentNote;
  final bool isPrinted;

  const SetFactorIdModal({
    super.key,
    required this.factorId,
    this.currentFactorNumber,
    this.currentNote,
    this.isPrinted = false,
  });

  @override
  State<SetFactorIdModal> createState() => _SetFactorIdModalState();
}

class _SetFactorIdModalState extends State<SetFactorIdModal> {
  late final TextEditingController _numberController;
  late final TextEditingController _noteController;
  late bool _isPrinted;

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController(
      text: widget.currentFactorNumber ?? '',
    );
    _noteController = TextEditingController(text: widget.currentNote ?? '');
    _isPrinted = widget.isPrinted;
  }

  @override
  void dispose() {
    _numberController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountingProvider = context.watch<AccountingProvider>();

    return BottomModalTemplate(
      title: 'ویرایش فاکتور',
      children: [
        //
        // Factor number input
        //
        OutlineTextformfield(
          controller: _numberController,
          placeholder: 'شماره فاکتور را وارد کنید...',
          keyboardType: TextInputType.text,
          maxLines: 1,
        ),
        const SizedBox(height: 8),

        //
        // Note input
        //
        OutlineTextformfield(
          controller: _noteController,
          placeholder: 'یادداشت...',
          keyboardType: TextInputType.text,
          maxLines: 3,
        ),
        const SizedBox(height: 8),

        //
        // Is Printed toggle
        //
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('وضعیت چاپ:', style: Theme.of(context).textTheme.bodyMedium),
            Switch(
              value: _isPrinted,
              onChanged: (value) => setState(() => _isPrinted = value),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 8),

        //
        // Save Button
        //
        ModalBottomButtons(
          saveText: 'ثبت تغییرات',
          loading: accountingProvider.actionLoading,
          onSave: () async {
            final number = _numberController.text.trim();
            if (number.isEmpty) {
              flatErrorToast(title: 'شماره فاکتور نمی\u200cتواند خالی باشد.');
              return;
            }

            final note = _noteController.text.trim();

            final result = await accountingProvider.completeFactor(
              factorId: widget.factorId,
              factorNumber: number,
              note: note.isNotEmpty ? note : null,
              isPrinted: _isPrinted,
            );

            if (result != null && result['result'] == 'ok') {
              filledSuccessToast(title: 'فاکتور با موفقیت ثبت شد.');
            } else {
              filledErrorToast(title: 'خطایی در ثبت فاکتور رخ داده است.');
            }
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
