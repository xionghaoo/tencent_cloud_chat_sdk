import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/user_info_allow_type.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_user_full_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

// TODO
class UnsubscribeUserStatus extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UnsubscribeUserStatusState();
  }
}

class _UnsubscribeUserStatusState extends State<UnsubscribeUserStatus> {
  String result = '';
  String nickname = '';
  int selectedAllowType = -1;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    result = '';
  }

  pressedFunction() async {
    V2TimCallback setSelfInfoRes;
    if (nickname.isEmpty) {
      setSelfInfoRes = await TencentImSDKPlugin.v2TIMManager
          .subscribeUserStatus(userIDList: []);
    } else {
      setSelfInfoRes = await TencentImSDKPlugin.v2TIMManager
          .subscribeUserStatus(userIDList: [nickname]);
    }

    setState(() {
      result = setSelfInfoRes.toJson().toString();
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
        title: Text('UnsubscribeUserStatus 取消订阅用户状态'),
      ),
      body: Center(
        child: Column(
          children: [
            TextField(
                autofocus: true,
                decoration: InputDecoration(
                    labelText: "userID",
                    hintText: "userID",
                    prefixIcon: Icon(Icons.person)),
                onChanged: (value) {
                  nickname = value;
                }),
            ElevatedButton(
              child: Text('UnsubscribeUserStatus'),
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
