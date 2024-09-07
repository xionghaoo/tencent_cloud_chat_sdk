import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

class InitSDK extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _InitSDKState();
  }
}

class _InitSDKState extends State<InitSDK> {
  String result = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    result = '';
  }

  initSDK() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final V2TimSDKListener listener = V2TimSDKListener(
      onConnectSuccess: () {
        print("onConnectSuccess");
      },
      onConnecting: () {
        print("onConnecting");
      },
      onConnectFailed: (code, error) {
        print("onConnectFailed");
      },
    );

    V2TimValueCallback<bool> initres = await TencentImSDKPlugin.v2TIMManager
        .initSDK(
            sdkAppID: int.parse(prefs.getString('sdkappid') ?? ''),
            loglevel: LogLevelEnum.V2TIM_LOG_NONE,
            listener: listener);
    print(initres.toJson());
    setState(() {
      result = initres.toJson().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text('initSDK'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              child: Text('InitSDK'),
              onPressed: () {
                initSDK();
              },
            ),
            const SizedBox(
              height: 20,
            ),
            Text(result)
          ],
        ),
      ),
    ));
  }
}
