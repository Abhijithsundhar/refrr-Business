import 'package:flutter/material.dart';

class MultiSelectDropdown extends StatefulWidget {
  final List<String> dropItemList;
  final String hint;
  final double w;
  final Function(List<String>) onChange;
  final InputDecoration decoration;

  const MultiSelectDropdown({
    Key? key,
    required this.dropItemList,
    required this.hint,
    required this.w,
    required this.onChange,
    required this.decoration,
  }) : super(key: key);

  @override
  _MultiSelectDropdownState createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  List<String> selectedItems = [];

  void _showMultiSelectDialog() async {
    final List<String>? result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return _MultiSelectDialog(
          items: widget.dropItemList,
          selectedItems: selectedItems,
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedItems = result;
      });
      widget.onChange(selectedItems);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showMultiSelectDialog,
      child: AbsorbPointer(
        child: TextField(
          controller: TextEditingController(
            text: selectedItems.isNotEmpty ? selectedItems.join(', ') : '',
          ),
          decoration: widget.decoration.copyWith(
            hintText: widget.hint,
          ),
          readOnly: true,
          style: TextStyle(color: Colors.black87),
        ),
      ),
    );
  }
}

class _MultiSelectDialog extends StatefulWidget {
  final List<String> items;
  final List<String> selectedItems;

  const _MultiSelectDialog({
    Key? key,
    required this.items,
    required this.selectedItems,
  }) : super(key: key);

  @override
  State<_MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<_MultiSelectDialog> {
  late List<String> _tempSelected;
  TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.selectedItems);

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = widget.items
        .where((item) => item.toLowerCase().contains(_searchText))
        .toList();

    return AlertDialog(
      backgroundColor: Colors.white,
      contentPadding: EdgeInsets.all(16),
      title: Text('Select Services'),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search services...',
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ...filteredItems.map((item) {
                final isSelected = _tempSelected.contains(item);
                return CheckboxListTile(
                  value: isSelected,
                  title: Text(item),
                  onChanged: (bool? selected) {
                    setState(() {
                      if (selected == true) {
                        _tempSelected.add(item);
                      } else {
                        _tempSelected.remove(item);
                      }
                    });
                  },
                );
              }).toList(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, _tempSelected),
          child: Text('OK'),
        ),
      ],
    );
  }
}


//----------------------------------------------

class SingleSelectDropdown extends StatefulWidget {
  final List<String> itemList;
  final String hint;
  final double w;
  final Function(String) onChange;
  final InputDecoration decoration;

  const SingleSelectDropdown({
    Key? key,
    required this.itemList,
    required this.hint,
    required this.w,
    required this.onChange,
    required this.decoration,
  }) : super(key: key);

  @override
  State<SingleSelectDropdown> createState() => _SingleSelectDropdownState();
}

class _SingleSelectDropdownState extends State<SingleSelectDropdown> {
  String? selectedItem;

  void _showSelectDialog() async {
    TextEditingController _searchController = TextEditingController();
    List<String> filteredList = List.from(widget.itemList);

    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Select Industry Type'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setStateDialog(() {
                          filteredList = widget.itemList
                              .where((item) =>
                              item.toLowerCase().contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 250),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final item = filteredList[index];
                          return ListTile(
                            title: Text(item),
                            onTap: () => Navigator.pop(context, item),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedItem = result;
      });
      widget.onChange(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showSelectDialog,
      child: AbsorbPointer(
        child: TextField(
          controller: TextEditingController(text: selectedItem ?? ''),
          decoration: widget.decoration.copyWith(
            hintText: widget.hint,
            suffixIcon: Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          ),
          readOnly: true,
          style: TextStyle(color: Colors.black54),
        ),
      ),
    );
  }
}

