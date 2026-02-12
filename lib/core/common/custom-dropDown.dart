import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';

class CustomSearchDropDown extends StatelessWidget {
  const CustomSearchDropDown({super.key,
    required this.dropItemList,
    required this.hint,
    required this.onChange,
    this.prefix,
    this.h,
    this.w,
    this.initialItem,
    this.searchHint,
    this.multiple,
    required InputDecoration decoration,
  });

  final dynamic Function(String?)? onChange;
  final List<String> dropItemList;
  final Widget? prefix;
  final String? searchHint;
  final String? hint;
  final String? initialItem;
  final double? w;
  final double? h;
  final bool? multiple;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: DropdownButtonHideUnderline(
        child: CustomDropdown.search(
          initialItem: initialItem,
          hintText: hint,
          searchHintText: searchHint,
          decoration: CustomDropdownDecoration(
            closedSuffixIcon: Icon(Icons.keyboard_arrow_down_sharp,color: Colors.black54,),
            closedFillColor: Colors.transparent,
            expandedBorderRadius: BorderRadius.circular(20),
            closedErrorBorderRadius: BorderRadius.circular(20),
            closedBorderRadius: BorderRadius.circular(20),
            prefixIcon: prefix,
            headerStyle: TextStyle(color: Colors.black54, fontSize: width * 0.043),
            hintStyle: TextStyle(color: Colors.black54,
              fontSize: width * 0.04,
            ),
            listItemStyle: TextStyle(color: Colors.black54, fontSize: width * 0.04),
            searchFieldDecoration: SearchFieldDecoration(
              hintStyle: TextStyle(color: Colors.black54),
              textStyle: TextStyle(color: Colors.black54),
            ),
          ),
          items: dropItemList,
          onChanged: onChange,
        ),
      ),
    );
  }
}


class CustomSearchDropDowns extends StatelessWidget {
  const CustomSearchDropDowns(
      {super.key,
        required this.dropItemList,
        required this.hint,
        required this.onChange,
        this.prefix,
        this.h,
        this.w,
        this.initialItem,
        this.searchHint,
        this.multiple});
  final dynamic Function(String?)? onChange;
  final List<String> dropItemList;
  final Widget? prefix;
  final String? searchHint;
  final String? hint;
  final String? initialItem;
  final double? w;
  final double? h;
  final bool? multiple;

  @override
  Widget build(BuildContext context) {
    double height=MediaQuery.of(context).size.height;
    double  width=MediaQuery.of(context).size.width;
    return Container(
      // decoration: BoxDecoration(
      //     color: Colors.white,
      //     borderRadius: BorderRadius.circular(20)),
      // height:h?? height * 0.06,
      // width: w??400,
      child: DropdownButtonHideUnderline(
          child: CustomDropdown.search(
            initialItem: initialItem,
            hintText: hint,
            searchHintText: searchHint,
            decoration: CustomDropdownDecoration(
              // closedErrorBorder: Border.all(color:Colors.black),
              // expandedBorder: Border.all(color: Colors.black),
              // closedBorder: Border.all(color: Colors.black),
                closedFillColor: Colors.transparent,
                expandedBorderRadius: BorderRadius.circular(20),
                closedErrorBorderRadius: BorderRadius.circular(20),
                closedBorderRadius: BorderRadius.circular(20),
                prefixIcon: prefix,
                headerStyle: TextStyle(color:Colors.black, fontSize: width * (.04)),
                hintStyle: TextStyle(color: Colors.black, fontSize: width * (.04)),
                // expandedFillColor: Colors.white,
                listItemDecoration: const ListItemDecoration(
                  // selectedColor: Colors.blue,
                ),
                listItemStyle:
                TextStyle(color: Colors.black, fontSize: width * (.04)),
                searchFieldDecoration: const SearchFieldDecoration(
                  hintStyle: TextStyle(color: Colors.black),
                  textStyle: TextStyle(color: Colors.black),
                )),
            items: dropItemList,
            onChanged: onChange,
          )),
    );
  }
}
