import 'package:flutter/material.dart';

class DropdownLocation<T> extends StatelessWidget {
  const DropdownLocation(
      {Key key,
      this.dropdownItemList,
      this.hint,
      @required this.onChanged,
      this.selectedLocation})
      : super(key: key);

  final String hint;
  final List<DropdownMenuItem<T>> dropdownItemList;
  final ValueChanged<T> onChanged;
  final T selectedLocation;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
        isExpanded: true,
        icon: Icon(Icons.location_city),
        hint: Text(hint),
        items: dropdownItemList == null ? [] : dropdownItemList,
        onChanged: onChanged,
        value: selectedLocation);
  }
}
