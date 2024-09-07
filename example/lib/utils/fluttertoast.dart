import 'package:flutter_platform_alert/flutter_platform_alert.dart';

class ToastUtils {
  static showToast(String msg) async {
    final clickedButton = await FlutterPlatformAlert.showAlert(
      windowTitle: '提示',
      text: msg,
      alertStyle: AlertButtonStyle.ok,
      iconStyle: IconStyle.information,
    );
    return clickedButton;
  }
}
