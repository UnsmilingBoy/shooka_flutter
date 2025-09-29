import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';
import 'package:shooka_flutter/utils/loadings/loading.dart';

class ModalBottomButtons extends StatefulWidget {
  final VoidCallback? onSave;
  final String saveText;
  final bool? loading;
  const ModalBottomButtons({
    super.key,
    this.onSave,
    required this.saveText,
    this.loading,
  });

  @override
  State<ModalBottomButtons> createState() => _ModalBottomButtonsState();
}

class _ModalBottomButtonsState extends State<ModalBottomButtons> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        spacing: 10,
        children: [
          //Close button
          Expanded(
            child: ContainerButton(
              padding: EdgeInsets.all(14),
              color: Theme.of(context).colorScheme.errorContainer,
              child: Text(
                "بستن",
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.apply(color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          //Save button
          Expanded(
            child: ContainerButton(
              padding: EdgeInsets.all(14),
              color: Theme.of(context).primaryColor,
              onPressed: widget.onSave,
              child: widget.loading == true
                  ? Loading()
                  : Text(
                      widget.saveText,
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.apply(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
