import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shooka_flutter/utils/buttons/my_icon_button.dart';
import 'package:dropdown_search/dropdown_search.dart';

/// A model for dropdown items with value and label
class DropdownItemModel {
  final String value;
  final String label;

  DropdownItemModel({required this.value, required this.label});

  @override
  String toString() => label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DropdownItemModel &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class SearchableDropdownWithLabel extends StatefulWidget {
  final String label;
  final String placeholder;
  final String? initialValue;
  final List<DropdownItemModel> items;
  final void Function(String?)? onChanged;
  final GestureTapCallback? iconOnPressed;

  /// When provided, the dropdown performs server-side search instead of
  /// filtering [items] locally. Called with the typed text on every change
  /// (debounced), and must return the matching items.
  final Future<List<DropdownItemModel>> Function(String filter)? loadItems;

  const SearchableDropdownWithLabel({
    super.key,
    this.initialValue,
    required this.items,
    this.onChanged,
    required this.label,
    required this.placeholder,
    this.iconOnPressed,
    this.loadItems,
  });

  @override
  State<SearchableDropdownWithLabel> createState() =>
      _SearchableDropdownWithLabelState();
}

class _SearchableDropdownWithLabelState
    extends State<SearchableDropdownWithLabel> {
  DropdownItemModel? selectedItem;
  int _searchRequestId = 0;

  @override
  void initState() {
    super.initState();
    _updateSelectedItem();
  }

  @override
  void didUpdateWidget(SearchableDropdownWithLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _updateSelectedItem();
    }
  }

  void _updateSelectedItem() {
    if (widget.initialValue != null) {
      selectedItem = widget.items
          .where((item) => item.value == widget.initialValue)
          .firstOrNull;
    } else {
      selectedItem = null;
    }
  }

  /// Debounced server-side fetch. Each typed change bumps [_searchRequestId];
  /// a superseded request returns the static list as a no-op so the popup
  /// never hangs on a stale future.
  Future<List<DropdownItemModel>> _loadItemsDebounced(String filter) async {
    final requestId = ++_searchRequestId;
    await Future.delayed(const Duration(milliseconds: 350));
    if (requestId != _searchRequestId) return widget.items;
    try {
      return await widget.loadItems!(filter);
    } catch (_) {
      return widget.items;
    }
  }

  @override
  Widget build(BuildContext context) {
    final usesServerSearch = widget.loadItems != null;
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
                child: DropdownSearch<DropdownItemModel>(
                  items: (filter, loadProps) => usesServerSearch
                      ? _loadItemsDebounced(filter)
                      : widget.items,
                  selectedItem: selectedItem,
                  compareFn: (item1, item2) => item1.value == item2.value,
                  filterFn: (item, filter) {
                    return item.label.toLowerCase().contains(
                      filter.toLowerCase(),
                    );
                  },
                  onChanged: (item) {
                    setState(() {
                      selectedItem = item;
                    });
                    widget.onChanged?.call(item?.value);
                  },
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    disableFilter: usesServerSearch,
                    fit: FlexFit.loose,
                    constraints: BoxConstraints(maxHeight: 300),
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
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                    itemBuilder: (context, item, isDisabled, isSelected) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1)
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
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 13,
                        horizontal: 10,
                      ),
                      hintText: widget.placeholder,
                      hintStyle: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  dropdownBuilder: (context, selectedItem) {
                    return Text(
                      selectedItem?.label ?? widget.placeholder,
                      textAlign: TextAlign.right,
                      style: selectedItem != null
                          ? Theme.of(context).textTheme.labelMedium
                          : Theme.of(context).textTheme.labelSmall,
                    );
                  },
                ),
              ),
            ),
            if (selectedItem != null)
              MyIconButton(
                onPressed: () {
                  setState(() {
                    selectedItem = null;
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
