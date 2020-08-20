import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_communication/Dialog.dart';

import 'ProgressIndicator.dart';

class MyProgressDialog {
  BuildContext context;

  Future result;

  MyProgressDialog(this.context);

  void show() {
    new Future.delayed(const Duration(milliseconds: 100), () {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext bc) {
            return CustomDialog(MyProgressIndicator());
          });
    });

  }

  void dismiss() {
    Navigator.of(context).pop();
  }
}
