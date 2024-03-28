import 'dart:io';
import 'package:driverflow/constant/color_constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

void showOkCancelAlertDialog({
  required BuildContext context,
  String? message,
  String? okButtonTitle,
  String? cancelButtonTitle,
  Function? cancelButtonAction,
  Function? okButtonAction,
  bool isCancelEnable = true,
}) {
  showDialog(
    barrierDismissible: isCancelEnable,
    context: context,
    builder: (context) {
      if (Platform.isIOS) {
        return _showOkCancelCupertinoAlertDialog(
            context,
            message!,
            okButtonTitle,
            cancelButtonTitle,
            okButtonAction,
            isCancelEnable,
            cancelButtonAction);
      } else {
        return _showOkCancelMaterialAlertDialog(
            context,
            message!,
            okButtonTitle,
            cancelButtonTitle,
            okButtonAction,
            isCancelEnable,
            cancelButtonAction);
      }
    },
  );
}

void showAlertDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) {
      if (Platform.isIOS) {
        return _showCupertinoAlertDialog(context, message);
      } else {
        return _showMaterialAlertDialog(context, message);
      }
    },
  );
}

CupertinoAlertDialog _showCupertinoAlertDialog(
    BuildContext context, String message) {
  return CupertinoAlertDialog(
    title: Text("DriverFlow"),
    content: Text(
      message,
      style: TextStyle(color: Colors.black12.withOpacity(0.6)),
    ),
    actions: _actions(context),
  );
}

AlertDialog _showMaterialAlertDialog(BuildContext context, String message) {
  return AlertDialog(
    title: Text("DriverFlow"),
    content: Text(
      message,
      style: TextStyle(color: Colors.black12.withOpacity(0.6)),
    ),
    actions: _actions(context),
  );
}

AlertDialog _showOkCancelMaterialAlertDialog(
    BuildContext context,
    String message,
    String? okButtonTitle,
    String? cancelButtonTitle,
    Function? okButtonAction,
    bool isCancelEnable,
    Function? cancelButtonAction) {
  return AlertDialog(
    title: Text("DriverFlow"),
    content: Text(message),
    actions: isCancelEnable
        ? _okCancelActions(
            context: context,
            okButtonTitle: okButtonTitle,
            cancelButtonTitle: cancelButtonTitle,
            okButtonAction: okButtonAction,
            isCancelEnable: isCancelEnable,
            cancelButtonAction: cancelButtonAction,
          )
        : _okAction(
            context: context,
            okButtonAction: okButtonAction,
            okButtonTitle: okButtonTitle),
  );
}

CupertinoAlertDialog _showOkCancelCupertinoAlertDialog(
  BuildContext context,
  String message,
  String? okButtonTitle,
  String? cancelButtonTitle,
  Function? okButtonAction,
  bool isCancelEnable,
  Function? cancelButtonAction,
) {
  return CupertinoAlertDialog(
      title: Text("DriverFlow"),
      content: Text(message),
      actions: isCancelEnable
          ? _okCancelActions(
              context: context,
              okButtonTitle: okButtonTitle,
              cancelButtonTitle: cancelButtonTitle,
              okButtonAction: okButtonAction,
              isCancelEnable: isCancelEnable,
              cancelButtonAction: cancelButtonAction,
            )
          : _okAction(
              context: context,
              okButtonAction: okButtonAction,
              okButtonTitle: okButtonTitle));
}

List<Widget> _actions(BuildContext context) {
  return <Widget>[
    Platform.isIOS
        ? CupertinoDialogAction(
            child: Text(
              "ok",
              style: TextStyle(color: Colors.pink),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        : TextButton(
            child: Text(
              "ok",
              style: TextStyle(color: Colors.pink),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
  ];
}

List<Widget> _okCancelActions({
  BuildContext? context,
  String? okButtonTitle,
  String? cancelButtonTitle,
  Function? okButtonAction,
  bool? isCancelEnable,
  Function? cancelButtonAction,
}) {
  return <Widget>[
    Platform.isIOS
        ? CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(
              cancelButtonTitle ?? "",
              style: TextStyle(color: Colors.pink),
            ),
            onPressed: cancelButtonAction == null
                ? () {
                    Navigator.of(context!).pop();
                  }
                : () {
                    Navigator.of(context!).pop();
                    cancelButtonAction();
                  },
          )
        : TextButton(
            child: Text(
              cancelButtonTitle ?? "",
              style: TextStyle(color: Colors.pink),
            ),
            onPressed: cancelButtonAction == null
                ? () {
                    Navigator.of(context!).pop();
                  }
                : () {
                    Navigator.of(context!).pop();
                    cancelButtonAction();
                  },
          ),
    Platform.isIOS
        ? CupertinoDialogAction(
            child: Text(
              okButtonTitle!,
              style: TextStyle(color: Colors.pink),
            ),
            onPressed: () {
              Navigator.of(context!).pop();
              okButtonAction!();
            },
          )
        : TextButton(
            child: Text(
              okButtonTitle!,
              style: TextStyle(color: Colors.pink),
            ),
            onPressed: () {
              Navigator.of(context!).pop();
              okButtonAction!();
            },
          ),
  ];
}

List<Widget> _okAction(
    {BuildContext? context, String? okButtonTitle, Function? okButtonAction}) {
  return <Widget>[
    Platform.isIOS
        ? CupertinoDialogAction(
            child: Text(okButtonTitle!),
            onPressed: () {
              Navigator.of(context!).pop();
              okButtonAction!();
            },
          )
        : TextButton(
            child: Text(okButtonTitle!),
            onPressed: () {
              Navigator.of(context!).pop();
              okButtonAction!();
            },
          ),
  ];
}

Future<bool?> displayToast(String message) {
  return Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.pink,
      textColor: Colors.white,
      fontSize: 14);
}

SnackBar displaySnackBar({required String message}) {
  return SnackBar(
    content: Text(
      message,
      style: TextStyle(color: Colors.white, fontSize: 14),
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.pink,
  );
}

Alert vapeAlertDialogue({
  required BuildContext context,
  bool onWillPopActive = true,
  AlertType type = AlertType.error,
  required String? desc,
  required void Function()? onPressed,
  String buttonTitle = 'Ok',
}) {
  return Alert(
    onWillPopActive: onWillPopActive,
    closeIcon: const Text(''),
    closeFunction: () {},
    context: context,
    type: type,
    desc: desc,
    buttons: [
      DialogButton(
        onPressed: onPressed,
        //  ()  Navigator.pop(context),
        width: 120,
        color: greencolor,
        child: Text(
          buttonTitle,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      )
    ],
  );
}
