import 'package:flutter/material.dart';

abstract class CoreState<T extends StatefulWidget> extends State {
  void showLongToast(String message);
  void showShortToast(String message);

  void showSnackBar(String message);
  void showSuccessSnackBar(String message);
  void showErrorSnackBar(String message);
  
  void showAlertDialog(String message);
  void showSuccessDialog(String message);
  void showErrorDialog(String message);
}