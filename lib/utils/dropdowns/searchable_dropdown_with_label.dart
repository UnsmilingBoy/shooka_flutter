import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/buttons/my_icon_button.dart';
import 'package:dropdown_search/dropdown_search.dart';

class SearchableDropdownWithLabel extends StatefulWidget {
  final String label;
  final String placeholder;
  final String? initialValue;
  final List<DropdownMenuItem<String>> items;
  final void Function(String?)? onChanged;
  final GestureTapCallback? iconOnPressed;

  const SearchableDropdownWithLabel({
    super.key,
    this.initialValue,
    required this.items,
    this.onChanged,
    required this.label,
    required this.placeholder,
    this.iconOnPressed,
  });

  @override
  State<SearchableDropdownWithLabel> createState() =>
      _SearchableDropdownWithLabelState();
}

class _SearchableDropdownWithLabelState
    extends State<SearchableDropdownWithLabel> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  // Extract the string values from DropdownMenuItem for the dropdown_search
  List<String> get itemValues {
    return widget.items.map((item) => item.value ?? '').toList();
  }

  // Get display text for a value
  String getDisplayText(String value) {
    final item = widget.items.firstWhere(
      (item) => item.value == value,
      orElse: () => widget.items.first,
    );
    if (item.child is Text) {
      return (item.child as Text).data ?? value;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 3,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label),
        Row(
          spacing: 5,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: DropdownSearch<String>(
                  items: (filter, infiniteScrollProps) => itemValues,
                  selectedItem: selectedValue,
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        hintText: 'جستجو...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                      ),
                    ),
                    menuProps: MenuProps(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  decoratorProps: DropDownDecoratorProps(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey.shade700,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey.shade700,
                          width: 1,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 13,
                        horizontal: 5,
                      ),
                      hintText: widget.placeholder,
                      hintStyle: Theme.of(context).textTheme.labelSmall,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  itemAsString: (item) => getDisplayText(item),
                  onChanged: (value) {
                    setState(() {
                      selectedValue = value;
                    });
                    widget.onChanged?.call(value);
                  },
                  dropdownBuilder: (context, selectedItem) {
                    return Text(
                      selectedItem != null
                          ? getDisplayText(selectedItem)
                          : widget.placeholder,
                      style: selectedItem != null
                          ? Theme.of(context).textTheme.labelMedium
                          : Theme.of(context).textTheme.labelSmall,
                    );
                  },
                ),
              ),
            ),
            if (selectedValue != null)
              MyIconButton(
                onPressed: () {
                  setState(() {
                    selectedValue = null;
                  });
                  widget.iconOnPressed?.call();
                  widget.onChanged?.call(null);
                },
                padding: EdgeInsets.all(5),
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
