import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Dialog.dart';
import 'ProgressIndicator.dart';

class MyProgressDialog {
  BuildContext context;

  bool _isDialogShowing = false;

  MyProgressDialog(this.context);

  void show(bool b) {
    if (b) {
      new Future.delayed(const Duration(milliseconds: 100), () {
        _isDialogShowing = true;
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext bc) {
              return CustomDialog(MyProgressIndicator());
            });
      });
    }
  }

  void dismiss() {
    if (_isDialogShowing) {
      Navigator.of(context).pop();
      _isDialogShowing = false;
    }
  }
}
