import 'dart:isolate';
import 'dart:ui';

import 'package:core/Modals/download_progress.dart';
import 'package:core/Modals/streamed_progress.dart';
import 'package:core/global/config.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_file/open_file.dart';
import 'package:rxdart/rxdart.dart';

class DownloadHelper {
  ReceivePort _port = ReceivePort();
  BehaviorSubject<StreamedProgress> _progress;
  Stream<StreamedProgress> get progress => this._progress.stream;
  void addProgress(StreamedProgress p) {
    _progress.add(p);
  }

  void init() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    _progress = BehaviorSubject<StreamedProgress>();
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');

    _port.listen((dynamic data) async {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int prog = data[2];
      _progress.add(StreamedProgress.downloadProgress(
          DownloadProgress(id: id, status: status, progress: prog)));
      if (status == DownloadTaskStatus.complete) {
        bool isOpended;
        try {
          isOpended = await FlutterDownloader.open(taskId: id);
        } catch (e) {
          print(e?.toString() ?? "Unknown error");
          isOpended = false;
        }

        print("isOpended? $isOpended");
        if (!isOpended) {
          try {
            OpenResult openRes =
                await OpenFile.open(CoreConfig.updateDownloadedFilePath);
            print(openRes.message);
          } catch (e) {
            print("Cannot open downloaded file $e");
          }
        }
      }
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    _progress.close();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  Future<void> addTask(String url, String saveDir) async {
    await FlutterDownloader.enqueue(
      url: url,
      savedDir: saveDir,
      showNotification: true,
      openFileFromNotification: true,
    );
  }
}
