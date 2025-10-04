import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'global variables.dart';

void showLoading(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return  Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(width: width*.01,),
            Text('uploading Image...',style:TextStyle(fontSize:width*.04,color: Colors.white, decoration: TextDecoration.none,),),
          ],
        ),
      );
    },
  );
}
void showLoadings(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return  Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(width: width*.01,),
            Text('adding...',style:TextStyle(fontSize:width*.04,color: Colors.white, decoration: TextDecoration.none,),),
          ],
        ),
      );
    },
  );
}
void hideLoading(BuildContext context) {
  Navigator.pop(context); // Close the dialog
}