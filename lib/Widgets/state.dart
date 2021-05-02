import 'package:flutter/material.dart';

abstract class CoreCommonState {
  void showLongToast(String message);
  void showShortToast(String message);

  void showSnackBar(String message);
  void showSuccessSnackBar(String message);
  void showErrorSnackBar(String message);

  void showAlertDialog(String message);
  void showSuccessDialog(String message);
  void showErrorDialog(String message);
}

abstract class CoreState<T extends StatefulWidget> extends State implements CoreCommonState {}

abstract class CoreStatelessWidget extends StatelessWidget implements CoreCommonState {}
