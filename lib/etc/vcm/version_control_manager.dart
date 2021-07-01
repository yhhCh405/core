import 'dart:io';

import 'package:core/Modals/streamed_progress.dart';
import 'package:core/Widgets/global/linearprogresspopuploadingdialog.dart';
import 'package:core/etc/vcm/download_helper.dart';
import 'package:core/global/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

/// Author: Ye Htet Hein
///
/// Before using this class, you must setup [flutter_downloader](https://pub.dev/packages/flutter_downloader),  package first in your project.
abstract class VersionControlManager {
  /// Platforms that allow to download update directly
  bool get isDirectDownloadSupportedPlatform;
  String get downloadedSaveDir;
  String get downloadedSaveFileName;

  /// Usage:
  /// ```dart
  /// Map<String, String> get updateDownloadUrl => {
  ///   Platform.Android : "https://somewhere.com/download/update.apk"
  /// }
  /// ```
  Map<String, String> get updateDownloadUrl;

  /// Usage:
  /// ```dart
  /// Map<String, String> get updateDownloadUrl => {
  ///   Platform.Android : "https://play.google.com/apps/something"
  /// }
  /// ```
  Map<String, String> get playstoreUrls;

  String get playstoreIconAssetImagePath;
  String get appstoreIconAssetImagePath;

  bool get shouldUpdate;
  bool get mustUpdate;

  String get _currentPlatformPlaystoreUrl {
    if (playstoreUrls == null) return null;
    return playstoreUrls.entries
        .firstWhere((entry) => entry.key == Platform.operatingSystem,
            orElse: () => null)
        .value;
  }

  Widget shouldUpdateWidget(BuildContext context,
      {@required Function onPressedDownload,
      @required Function onPressedGooglePlayUpdate,
      @required Function onPressNotNow}) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Center(
        child: Text("New version available"),
      ),
      content: Text(
        "We have just prepared new version for you. You can enjoy it if you wish.",
      ),
      actions: [
        Row(
          children: [
            _currentPlatformPlaystoreUrl != null
                ? TextButton(
                    onPressed: () {
                      launch(_currentPlatformPlaystoreUrl);
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          Platform.isAndroid
                              ? playstoreIconAssetImagePath
                              : Platform.isIOS
                                  ? appstoreIconAssetImagePath
                                  : Container(),
                          width: 20,
                          fit: BoxFit.cover,
                          height: 20,
                        ),
                        Text(Platform.isAndroid
                            ? 'Download on playstore'
                            : Platform.isIOS
                                ? 'Download on appstore'
                                : "")
                      ],
                    ))
                : Container(),
            Spacer(),
            (isDirectDownloadSupportedPlatform)
                ? TextButton(
                    onPressed: () {
                      onPressedDownload();
                    },
                    child: Text("Download"),
                  )
                : Container(),
            TextButton(
              onPressed: () {
                onPressNotNow();
              },
              child: Text("Not Now"),
            ),
          ],
        ),
      ],
    );
  }

  Widget mustUpdateWidget(BuildContext context,
      {@required Function onPressedDownload,
      @required Function onPressedGooglePlayUpdate,
      @required Function onPressExit}) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Center(
        child: Text("Please Update"),
      ),
      content: Text(
        "New version available! You must update to continue Lovoot.",
      ),
      actions: [
        Row(
          children: [
            _currentPlatformPlaystoreUrl != null
                ? Expanded(
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                          onPressed: () {
                            launch(_currentPlatformPlaystoreUrl);
                          },
                          child: Row(
                            children: [
                              Image.asset(
                                Platform.isAndroid
                                    ? 'assets/images/playstore.png'
                                    : Platform.isIOS
                                        ? 'assets/images/app-store.png'
                                        : Container(),
                              ),
                              Text(Platform.isAndroid
                                  ? 'Download on playstore'
                                  : Platform.isIOS
                                      ? 'Download on appstore'
                                      : "")
                            ],
                          ))
                    ],
                  ))
                : Container(),
            isDirectDownloadSupportedPlatform
                ? Builder(
                    builder: (context) => TextButton(
                      onPressed: () async {
                        onPressedDownload();
                      },
                      child: Text("Download"),
                    ),
                  )
                : Container(),
            TextButton(
              onPressed: () {
                onPressExit();
              },
              child: Text("Exit"),
            ),
          ],
        ),
      ],
    );
  }

  DownloadHelper _helper;
  BuildContext _context;

  VersionControlManager(this._context, this._helper);

  Future<void> _awaitForDownloadStream() async {
    await for (var _event in _helper.progress) {
      if (_event.finished && !_event.hasError) {
        print("finished");
        break;
      }
    }
  }

  String _absoluteSavePath() {
    if (!downloadedSaveDir.endsWith("/")) {
      CoreConfig.updateDownloadedFilePath =
          downloadedSaveDir + "/" + downloadedSaveFileName;
    } else {
      CoreConfig.updateDownloadedFilePath =
          downloadedSaveDir + downloadedSaveFileName;
    }
    return CoreConfig.updateDownloadedFilePath;
  }

  void _downloadNewVersion() async {
    omit(String errorMessage) {
      _helper.addProgress(StreamedProgress.error(errorMessage: errorMessage));
      return;
    }

    showLinearProgressPopupLoadingDialog(_context, _helper.progress);
    List<DownloadTask> _tasks = await FlutterDownloader.loadTasks();
    for (var t in _tasks) {
      await FlutterDownloader.remove(
          taskId: t.taskId, shouldDeleteContent: true);
    }
    if (!isDirectDownloadSupportedPlatform) {
      omit("Sorry! Your platform is not supported.");
    }
    String url;
    try {
      url = updateDownloadUrl.entries
          .firstWhere((element) => element.key == Platform.operatingSystem,
              orElse: () => null)
          ?.value;
    } catch (e) {
      _helper.addProgress(StreamedProgress.error(errorMessage: e?.toString()));
    }

    if (url == null) {
      _helper.addProgress(StreamedProgress.error(
          errorMessage:
              "Sorry! Your update is not ready yet. Please try again later."));
    }

    await Directory(downloadedSaveDir).create();
    if (File(_absoluteSavePath()).existsSync())
      await File(_absoluteSavePath()).delete();

    final taskId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: downloadedSaveDir,
      fileName: downloadedSaveFileName,
      showNotification: true,
      openFileFromNotification: true,
    );

    _helper.progress.listen((event) async {
      if (event.finished && !event.hasError) {
        Navigator.pop(_context);
        if (event.downloadProgress.status == DownloadTaskStatus.complete) {
          bool isOpended;
          try {
            isOpended =
                await FlutterDownloader.open(taskId: event.downloadProgress.id);
          } catch (e) {
            print(e?.toString() ?? "Unknown error");
            isOpended = false;
          }

          print("isOpended? $isOpended");
          if (!isOpended) {
            OpenResult openRes = await OpenFile.open(_absoluteSavePath());
            print(openRes.message);
          }
        }
      }
    });

    /// *
    /// * Below are working stable code. Removed and replaced with flutter_downloader due to memory leak as it was running in Main Thread.
    /// *
    // List<int> _bytes = [];
    // int _received = 0;
    // http.StreamedResponse _resp =
    //     await http.Client().send(http.Request('GET', Uri.parse(url)));
    // int _total = _resp.contentLength;
    // _resp.stream.listen((value) {
    //   _bytes.addAll(value);
    //   _received += value.length;
    //   _downloadProgress.add(UploadProgress.progress(_received / _total,
    //       message: "Downloading..."));
    // })
    //   ..onDone(() async {
    //     File pkg;
    //     if (Platform.isAndroid) {
    //       pkg =
    //           File((await getTemporaryDirectory()).path + "/lovoot/update.apk");
    //     } else if (Platform.isIOS) {
    //       pkg =
    //           File((await getTemporaryDirectory()).path + "/lovoot/update.ipa");
    //     }

    //     if (pkg.existsSync()) {
    //       await pkg.delete();
    //     }
    //     await pkg.create(recursive: true);
    //     await pkg.writeAsBytes(_bytes);
    //     _downloadProgress.add(UploadProgress.success());
    //     OpenResult openResult = await OpenFile.open(pkg.path);
    //     print(openResult.message);
    // })
    // ..onError((e) {
    //   _downloadProgress
    //       .add(UploadProgress.error(errorMessage: e?.toString()));
    // });
  }

  Future<bool> _showWarningDialog() {
    return showDialog<bool>(
        context: _context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: shouldUpdateWidget(context,
                onPressedDownload: () {
                  Navigator.pop(context, true);
                },
                onPressedGooglePlayUpdate: () {},
                onPressNotNow: () {
                  Navigator.pop(context, false);
                }),
          );
        });
  }

  Future<void> _showForceUpdateDialog() {
    return showDialog(
        context: _context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: mustUpdateWidget(context,
                  onPressedDownload: () {
                    Navigator.pop(context);
                    _downloadNewVersion();
                  },
                  onPressedGooglePlayUpdate: () {},
                  onPressExit: () {
                    exit(0);
                  }));
        });
  }

  Future<bool> check() async {
    if (mustUpdate) {
      await _showForceUpdateDialog();
      await _awaitForDownloadStream();
      return false;
    } else if (shouldUpdate) {
      bool pressedUpdate = await _showWarningDialog();
      if (pressedUpdate) {
        _downloadNewVersion();
        await showLinearProgressPopupLoadingDialog(_context, _helper.progress,
            onRetry: () {
          Navigator.pop(_context);
          _downloadNewVersion();
        });
        await _awaitForDownloadStream();
      }

      return true;
    }
    return true;
  }
}
