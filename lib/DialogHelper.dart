import 'package:flutter/material.dart';

import 'Dialog.dart';

class DialogHelper {
  static void showBottomSheet(BuildContext context, Widget child) {
    showModalBottomSheet(
        context: context,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        clipBehavior: Clip.hardEdge,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        builder: (BuildContext bc) {
          return child;
        });
  }

  static void show(BuildContext context, Widget child) {
    showDialog(
        context: context,
        builder: (BuildContext bc) {
          return CustomDialog(child);
        });
  }

  static void showFullScreen(BuildContext context, Widget child) {
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return child;
        },
        fullscreenDialog: false));
  }
}
