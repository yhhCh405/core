import 'package:core/Modals/download_progress.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class StreamedProgress<T> {
  double oneBasedProgress;
  bool get progressAvailable => this.oneBasedProgress != null;
  String message;
  bool finished;
  bool hasError;
  String errorMessage;
  T data;
  DownloadProgress downloadProgress;

  StreamedProgress(
      {this.message,
      this.oneBasedProgress,
      this.hasError = false,
      this.errorMessage,
      this.finished = false,
      this.data,
      this.downloadProgress});

  StreamedProgress.progress(this.oneBasedProgress,
      {this.message, this.data, this.downloadProgress}) {
    this.finished = false;
    this.hasError = false;
    this.errorMessage = null;
  }

  StreamedProgress.noProgress(
      {this.message, this.data, this.downloadProgress}) {
    this.oneBasedProgress = null;
    this.finished = false;
    this.hasError = false;
    this.errorMessage = null;
  }

  StreamedProgress.success({this.message, this.data, this.downloadProgress}) {
    this.oneBasedProgress = null;
    this.finished = true;
    this.errorMessage = null;
    this.hasError = false;
  }

  StreamedProgress.error(
      {this.errorMessage, this.data, this.downloadProgress}) {
    this.oneBasedProgress = null;
    this.finished = true;
    this.message = null;
    this.hasError = true;
  }

  StreamedProgress.downloadProgress(this.downloadProgress) {
    if (downloadProgress.progress != null) {
      this.oneBasedProgress = downloadProgress.progress / 100;
    }
    if (downloadProgress.status == DownloadTaskStatus.complete) {
      this.finished = true;
      this.message = "Downloaded successfully!";
      this.errorMessage = null;
      this.hasError = false;
    } else if (downloadProgress.status == DownloadTaskStatus.canceled) {
      this.finished = true;
      this.message = "Download task cancelled";
      this.errorMessage = null;
      this.hasError = false;
    } else if (downloadProgress.status == DownloadTaskStatus.enqueued) {
      this.finished = false;
      this.message = "Download initializing...";
      this.errorMessage = null;
      this.hasError = false;
    } else if (downloadProgress.status == DownloadTaskStatus.failed) {
      this.finished = true;
      this.errorMessage = "Download Failed";
      this.hasError = true;
    } else if (downloadProgress.status == DownloadTaskStatus.paused) {
      this.finished = false;
      this.message = "Download paused";
      this.errorMessage = null;
      this.hasError = false;
    } else if (downloadProgress.status == DownloadTaskStatus.running) {
      this.finished = false;
      this.message = "Downloading...";
      this.errorMessage = null;
      this.hasError = false;
    } else if (downloadProgress.status == DownloadTaskStatus.undefined) {
      this.finished = true;
      this.errorMessage = "Undefined download task";
      this.hasError = true;
    }
  }

  // bool get _isError => this.finished && this.hasError;
  // bool get _isSuccess => this.finished && !this.hasError;
  // bool get _isNoProgress => !this.finished && this.oneBasedProgress == null;
  // bool get _isProgress => !this.finished && this.oneBasedProgress != null;

  // DownloadProgress toDownloadProgress() {
  //   if (_isError && errorMessage == "You have cancelled the download task.") {
  //     return DownloadProgress(status: DownloadTaskStatus.canceled);
  //   } else if (_isSuccess && message == "Downloaded successfully") {
  //     return DownloadProgress(status: DownloadTaskStatus.complete);
  //   } else if (_isNoProgress && message == "New task added") {
  //     return DownloadProgress(status: DownloadTaskStatus.enqueued);
  //   } else if (_isError && message == "Download failed") {
  //     return DownloadProgress(status: DownloadTaskStatus.failed);
  //   } else if (_isNoProgress && message == "Download paused") {
  //     return DownloadProgress(status: DownloadTaskStatus.paused);
  //   } else if (_isProgress && message == "Downloading...") {
  //     return DownloadProgress(
  //         status: DownloadTaskStatus.running,
  //         progress: (oneBasedProgress * 100).toInt());
  //   } else if (_isError && errorMessage == "Download task undefined") {
  //     return DownloadProgress(status: DownloadTaskStatus.undefined);
  //   }
  //   return DownloadProgress();
  // }
}
