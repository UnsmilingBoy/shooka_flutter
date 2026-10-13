import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';
import 'package:shooka_flutter/utils/buttons/my_icon_button.dart';
import 'package:shooka_flutter/utils/dropdowns/searchable_dropdown_with_label.dart';

/// Multi-select version of [SearchableDropdownWithLabel].
///
/// Keeps the same look & feel (RTL, search box, borders) but allows picking
/// multiple items at once via checkboxes inside the popup instead of
/// picking one item at a time.
class MultiSelectSearchableDropdownWithLabel extends StatefulWidget {
  final String label;
  final String placeholder;
  final List<String> initialValues;
  final List<DropdownItemModel> items;
  final void Function(List<String>)? onChanged;
  final GestureTapCallback? iconOnPressed;

  const MultiSelectSearchableDropdownWithLabel({
    super.key,
    required this.label,
    required this.placeholder,
    this.initialValues = const [],
    required this.items,
    this.onChanged,
    this.iconOnPressed,
  });

  @override
  State<MultiSelectSearchableDropdownWithLabel> createState() =>
      _MultiSelectSearchableDropdownWithLabelState();
}

class _MultiSelectSearchableDropdownWithLabelState
    extends State<MultiSelectSearchableDropdownWithLabel> {
  List<DropdownItemModel> selectedItems = [];

  @override
  void initState() {
    super.initState();
    _updateSelectedItems();
  }

  @override
  void didUpdateWidget(MultiSelectSearchableDropdownWithLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValues != widget.initialValues ||
        oldWidget.items != widget.items) {
      _updateSelectedItems();
    }
  }

  void _updateSelectedItems() {
    selectedItems = widget.initialValues.map((value) {
      return widget.items
          .where((item) => item.value == value)
          .firstOrNull;
    }).whereType<DropdownItemModel>().toList();
  }

  void _clear() {
    setState(() {
      selectedItems = [];
    });
    widget.iconOnPressed?.call();
    widget.onChanged?.call(const []);
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
                child: DropdownSearch<DropdownItemModel>.multiSelection(
                  items: (filter, loadProps) => widget.items,
                  selectedItems: selectedItems,
                  compareFn: (item1, item2) => item1.value == item2.value,
                  filterFn: (item, filter) {
                    return item.label.toLowerCase().contains(
                      filter.toLowerCase(),
                    );
                  },
                  onChanged: (items) {
                    setState(() {
                      selectedItems = List.from(items);
                    });
                    widget.onChanged?.call(
                      items.map((e) => e.value).toList(),
                    );
                  },
                  popupProps: PopupPropsMultiSelection.menu(
                    showSearchBox: true,
                    showSelectedItems: true,
                    textDirection: TextDirection.rtl,
                    fit: FlexFit.loose,
                    constraints: const BoxConstraints(maxHeight: 300),
                    menuProps: MenuProps(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade700),
                      ),
                    ),
                    searchFieldProps: TextFieldProps(
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.labelMedium,
                      decoration: InputDecoration(
                        hintText: "جستجو...",
                        hintStyle: Theme.of(context).textTheme.labelSmall,
                        prefixIcon: Icon(
                          Icons.search,
                          color: Theme.of(context).hintColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade700),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade700),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                    itemBuilder: (context, item, isDisabled, isSelected) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.label,
                                textAlign: TextAlign.right,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: isSelected
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : null,
                                    ),
                              ),
                            ),
                            if (isSelected)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                    emptyBuilder: (context, searchEntry) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          "موردی یافت نشد",
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ),
                    validationBuilder: (context, selectedItems) => Builder(
                      builder: (innerContext) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ContainerButton(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 8,
                            ),
                            borderRadius: 8,
                            color: Theme.of(innerContext).primaryColor,
                            onPressed: () {
                              // Commit the checked items (same as the default
                              // OK button does) instead of just popping.
                              // NOTE: must use innerContext (a descendant of
                              // the popup) — the `context` passed to
                              // validationBuilder is the popup's own context,
                              // whose ancestors don't include its state.
                              innerContext
                                  .findAncestorStateOfType<
                                    DropdownSearchPopupState<
                                      DropdownItemModel
                                    >
                                  >()
                                  ?.onValidate();
                            },
                            child: Text(
                              "تایید",
                              style: Theme.of(innerContext)
                                  .textTheme
                                  .labelMedium
                                  ?.apply(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  decoratorProps: DropDownDecoratorProps(
                    textAlign: TextAlign.right,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(
                          color: Colors.grey.shade700,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(
                          color: Colors.grey.shade700,
                          width: 1,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 13,
                        horizontal: 10,
                      ),
                      hintText: widget.placeholder,
                      hintStyle: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  dropdownBuilder: (context, selectedItems) {
                    if (selectedItems.isEmpty) {
                      return Text(
                        widget.placeholder,
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.labelSmall,
                      );
                    }
                    return Text(
                      selectedItems.map((e) => e.label).join('، '),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium,
                    );
                  },
                ),
              ),
            ),
            if (selectedItems.isNotEmpty)
              MyIconButton(
                onPressed: _clear,
                padding: const EdgeInsets.all(5),
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
