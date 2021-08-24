import 'package:core/Modals/streamed_progress.dart';
import 'package:core/global/config.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

Future<void> showLinearProgressPopupLoadingDialog(
    BuildContext context, Stream<StreamedProgress> stream,
    {Function onRetry, Color progressColor}) {
  if (progressColor == null) {
    progressColor = CoreConfig.themeColor ?? Colors.blue;
  }

  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: StreamBuilder<StreamedProgress>(
              stream: stream,
              builder: (context, snapshot) {
                // if (snapshot.data != null && snapshot.data.finished) {
                //   Navigator.pop(context);
                // }
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  actions: [
                    snapshot.data != null &&
                            snapshot.data.hasError &&
                            onRetry != null
                        ? TextButton(
                            onPressed: () {
                              onRetry();
                            },
                            child: Text("Retry"),
                          )
                        : snapshot.data != null && snapshot.data.hasError
                            ? TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("OK"),
                              )
                            : Container()
                  ],
                  content: snapshot.data != null && snapshot.data.hasError
                      ? Text(snapshot.data.errorMessage ?? "Unknown Error")
                      : Container(
                          width: double.infinity,
                          // height: 100,
                          child:
                              Wrap(crossAxisAlignment: WrapCrossAlignment.start,
                                  // alignment: WrapAlignment.center,
                                  children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          snapshot.data?.message ??
                                              "Loading...",
                                          maxLines: 2,
                                          style:
                                              TextStyle(color: Colors.black54),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      snapshot.data != null &&
                                              snapshot.data.progressAvailable
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Text((snapshot.data
                                                              .oneBasedProgress *
                                                          100)
                                                      .toStringAsFixed(1) +
                                                  " %"))
                                          : Container(),
                                    ],
                                  ),
                                ),
                                snapshot.data == null ||
                                        !snapshot.data.progressAvailable
                                    ? LinearProgressIndicator()
                                    : LinearPercentIndicator(
                                        padding: EdgeInsets.all(0),
                                        animation: true,
                                        percent:
                                            snapshot.data?.oneBasedProgress ??
                                                0,
                                        animateFromLastPercent: true,
                                        backgroundColor: Colors.black12,
                                        progressColor: progressColor,
                                      ),
                              ]),
                        ),
                );
              }),
        );
      });
}
