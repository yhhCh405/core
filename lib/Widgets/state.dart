import 'package:flutter/material.dart';

abstract class _CoreCommonState {
  void showLongToast(String message);
  void showShortToast(String message);

  void showSnackBar(String message);
  void showSuccessSnackBar(String message);
  void showErrorSnackBar(String message);

  void showAlertDialog(String message);
  void showSuccessDialog(String message);
  void showErrorDialog(String message);
}

abstract class CoreState<T extends StatefulWidget> extends State<T> implements _CoreCommonState{}

abstract class CoreStatelessWidget extends StatelessWidget implements _CoreCommonState {}
