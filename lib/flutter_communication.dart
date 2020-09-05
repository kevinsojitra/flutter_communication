library flutter_communication;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

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



  post(String url, Object object,
      {Map<String, String> param,
      bool showProgress = true,
      String token = ""}) async {
    _dialog.show(showProgress);
    var request = new http.Request("POST", Uri.parse(url));
    if (param != null) {
      request.bodyFields = param;
    }
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
      _setFailed(request, error.toString(), object);
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

  _setFailed(Request request, String value, Object object) {
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
            FlatButton(
              child: Text('Retry'),
              onPressed: () {
                _retry(request, object);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _setFailedMultiPart(MultipartRequest request, String value, Object object) {
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
            FlatButton(
              child: Text('Retry'),
              onPressed: () {
                _retryMultiPart(request, object);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }



  get(String url, Object object,
      {Map<String, String> param,
      bool showProgress = true,
      String token = ""}) async {
    _dialog.show(showProgress);
    var request = new http.Request("GET", Uri.parse(url));
    if (param != null) {
      request.bodyFields = param;
    }
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
      _setFailed(request, error.toString(), object);
    });
  }



  part(String url, File file, Object object,
      {Map<String, String> param,
      bool showProgress = true,
      String token = ""}) async {
    _dialog.show(showProgress);
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    if (param != null) {
      request.fields.addAll(param);
    }
    request.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    request.files.add(
        new http.MultipartFile.fromBytes('file', await file.readAsBytes()));
    request
        .send()
        .then((response) => response.stream.bytesToString().then((value) {
              _setSuccess(value, object);
            }))
        .catchError((error) {
      _setFailedMultiPart(request, error.toString(), object);
    });
  }



  partList(String url, String key, List<File> fileList, Object object,
      {Map<String, String> param,
      bool showProgress = true,
      String token = ""}) async {
    _dialog.show(showProgress);
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    request.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (param != null) {
      request.fields.addAll(param);
    }
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
      _setFailedMultiPart(request, error.toString(), object);
    });
  }

  _retry(request, object) {
    _copyRequest(request)
        .send()
        .then((response) => response.stream.bytesToString().then((value) {
              _setSuccess(value, object);
            }))
        .catchError((error) {
      _setFailed(request, error.toString(), object);
    });
  }

  _retryMultiPart(request, object) {
    _copyRequest(request)
        .send()
        .then((response) => response.stream.bytesToString().then((value) {
              _setSuccess(value, object);
            }))
        .catchError((error) {
      _setFailed(request, error.toString(), object);
    });
  }

  http.BaseRequest _copyRequest(http.BaseRequest request) {
    http.BaseRequest requestCopy;

    if(request is http.Request) {
      requestCopy = http.Request(request.method, request.url)
        ..encoding = request.encoding
        ..bodyBytes = request.bodyBytes;
    }
    else if(request is http.MultipartRequest) {
      requestCopy = http.MultipartRequest(request.method, request.url)
        ..fields.addAll(request.fields)
        ..files.addAll(request.files);
    }
    else if(request is http.StreamedRequest) {
      throw Exception('copying streamed requests is not supported');
    }
    else {
      throw Exception('request type is unknown, cannot copy');
    }

    requestCopy
      ..persistentConnection = request.persistentConnection
      ..followRedirects = request.followRedirects
      ..maxRedirects = request.maxRedirects
      ..headers.addAll(request.headers);

    return requestCopy;
  }

/*Download(String url, File file) {
    HttpClient client = new HttpClient();
    client
        .getUrl(Uri.parse(
            "https://fluttermaster.com/wp-content/uploads/2018/08/fluttermaster.com-logo-web-header.png"))
        .then((HttpClientRequest request) {
      return request.close();
    }).then((HttpClientResponse response) {
      response.pipe(file.openWrite());
    });
  }*/
}

abstract class OnCommunicationListener {
  void onCallBackSuccess(String response, Object tag);

  void onCallBackFail(String error, Object tag);
}
