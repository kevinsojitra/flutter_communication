library flutter_communication;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'MyProgressDialog.dart';

class Communication {
  OnCommunicationListener listener;
  BuildContext context;

  MyProgressDialog _dialog;

  Communication(context, listener) {
    this.listener = listener;
    this.context = context;
    _dialog = MyProgressDialog(context);
  }

  Post(String url, Map<String, String> param, Object object,
      {bool showProgress = true, token = ""}) async {
    _dialog.show(showProgress);

    var request = new http.Request("POST", Uri.parse(url));
    request.bodyFields = param;
    request.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    request
        .send()
        .then((response) => response.stream.bytesToString().then((value) {
              _setSuccess(value, object);
            }))
        .catchError((error) {
      _setFailed(error.toString(), object);
    });
  }

  _setSuccess(String value, Object object) {
    _dialog.dismiss();
    listener.onCallBackSuccess(value, object);
    Map data = json.decode(value);
    if (!data["success"]) {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(data['message']),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  _setFailed(String value, Object object) {
    _dialog.dismiss();
    listener.onCallBackFail(value, object);

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(value),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Get(String url, Map<String, String> param, Object object,
      {showProgress = true, token = ""}) async {
    _dialog.show(showProgress);
    var request = new http.Request("GET", Uri.parse(url));
    request.bodyFields = param;
    request.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    request
        .send()
        .then((response) => response.stream.bytesToString().then((value) {
              _setSuccess(value, object);
            }))
        .catchError((error) {
      _setFailed(error.toString(), object);
    });
  }

  Part(String url, Map<String, String> param, File file, Object object) async {
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    request.fields.addAll(param);
    request.headers.addAll({'api-key': 'WLJGDnxq9u5bvYjzurmo1N2q8ljDki84'});
    request.files.add(
        new http.MultipartFile.fromBytes('file', await file.readAsBytes()));
    request
        .send()
        .then((response) => response.stream.bytesToString().then((value) {
              _setSuccess(value, object);
            }))
        .catchError((error) {
      _setFailed(error.toString(), object);
    });
  }

  PartList(String url, Map<String, String> param, String key,
      List<File> fileList, Object object) async {
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    request.fields.addAll(param);
    var i = 0;
    for (File file in fileList) {
      request.files.add(new http.MultipartFile.fromBytes(
          key + '[${i}]', await file.readAsBytes()));
    }
    request
        .send()
        .then((response) => response.stream.bytesToString().then((value) {
              _setSuccess(value, object);
            }))
        .catchError((error) {
      _setFailed(error.toString(), object);
    });
  }
}

abstract class OnCommunicationListener {
  void onCallBackSuccess(String response, Object tag);

  void onCallBackFail(String error, Object tag);
}
