import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

class GetLoginStatus extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GetLoginStatustState();
  }
}

class _GetLoginStatustState extends State<GetLoginStatus> {
  String result = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    result = '';
  }

  pressedFunction() async {
    V2TimValueCallback<int> loginRes =
        await TencentImSDKPlugin.v2TIMManager.getLoginStatus();
    setState(() {
      result = loginRes.toJson().toString();
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
        title: Text('getLoginStatus'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              child: Text('getLoginStatus'),
              onPressed: () {
                pressedFunction();
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
