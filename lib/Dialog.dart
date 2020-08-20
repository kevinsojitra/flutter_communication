import 'package:flutter/material.dart';

class CustomDialog extends StatefulWidget {
  Widget child;

  CustomDialog(@required this.child);

  @override
  _CustomDialogState createState() => _CustomDialogState(child);
}

class _CustomDialogState extends State<CustomDialog> {
  Widget child;

  _CustomDialogState(this.child);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0),
      child: Dialog(

        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: child,
      ),
    );
  }
}
