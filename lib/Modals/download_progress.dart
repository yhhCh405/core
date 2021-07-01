import 'package:flutter_downloader/flutter_downloader.dart';

class DownloadProgress {
  String id;
  DownloadTaskStatus status;
  int progress;

  DownloadProgress({this.id, this.progress, this.status});
}