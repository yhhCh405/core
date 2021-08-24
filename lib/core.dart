library core;

import 'package:core/global/config.dart';
import 'package:flutter/material.dart';

class Core {
  final Color themeColor;
  Core.initialize({this.themeColor}) {
    CoreConfig.themeColor = this.themeColor;
  }
}
