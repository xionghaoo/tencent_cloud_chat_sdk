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
class SetSelfInfo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SetSelfInfoState();
  }
}

class _SetSelfInfoState extends State<SetSelfInfo> {
  String result = '';
  String nickname = '';
  List<int> allowType = [
    AllowType.V2TIM_FRIEND_ALLOW_ANY,
    AllowType.V2TIM_FRIEND_DENY_ANY,
    AllowType.V2TIM_FRIEND_NEED_CONFIRM
  ];
  int selectedAllowType = -1;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    result = '';
  }

  pressedFunction() async {
    V2TimUserFullInfo userFullInfo;
    if (selectedAllowType != -1) {
      userFullInfo = V2TimUserFullInfo(
        allowType:
            selectedAllowType, //用户的好友验证方式 0:允许所有人加我好友 1:不允许所有人加我好友 2:加我好友需我确认
      );
    } else {
      userFullInfo = V2TimUserFullInfo(nickName: nickname);
    }

    V2TimCallback setSelfInfoRes = await TencentImSDKPlugin.v2TIMManager
        .setSelfInfo(userFullInfo: userFullInfo);
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
        title: Text('SetSelfInfo 修改个人资料'),
      ),
      body: Center(
        child: Column(
          children: [
            TextField(
                autofocus: true,
                decoration: InputDecoration(
                    labelText: "nickname",
                    hintText: "nickname",
                    prefixIcon: Icon(Icons.person)),
                onChanged: (value) {
                  nickname = value;
                }),
            SizedBox(
              height: 10,
            ),
            DropdownMenu<int>(
                width: 200,
                label: const Text('allow Type'),
                onSelected: (int? id) {
                  selectedAllowType = id ?? -1;
                },
                requestFocusOnTap: true,
                dropdownMenuEntries:
                    allowType.map<DropdownMenuEntry<int>>((int id) {
                  return DropdownMenuEntry<int>(
                    value: id,
                    label: id.toString(),
                  );
                }).toList()),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              child: Text('SetSelfInfo'),
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
