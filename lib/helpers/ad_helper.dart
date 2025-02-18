import 'dart:io';

String getBannerAdUnitId() {
  if (Platform.isAndroid) {
    // return 'ca-app-pub-3940256099942544/6300978111'; // Android test ad unit ID
    return 'ca-app-pub-3237977755350079/9236145625';
  } else if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544/2934735716'; // iOS test ad unit ID
  } else {
    throw UnsupportedError("Unsupported platform");
  }
}
