import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/receive_message_opt_enum.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:tencent_cloud_chat_sdk_example/config.dart';

class SetC2CReceiveMessageOpt extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SetC2CReceiveMessageOptState();
  }
}

class _SetC2CReceiveMessageOptState extends State<SetC2CReceiveMessageOpt> {
  String result = '';
  List<String> friends = [];
  List<String> groups = [];
  List<ReceiveMsgOptEnum> opt = [
    ReceiveMsgOptEnum.V2TIM_RECEIVE_MESSAGE,
    ReceiveMsgOptEnum.V2TIM_NOT_RECEIVE_MESSAGE,
  ];
  late ReceiveMsgOptEnum selectedOpt;
  String selectedId = '';
  String selectedGroup = '';
  TextEditingController _statusController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    result = '';
    getFriendList();
  }

  getFriendList() async {
    V2TimValueCallback<List<V2TimFriendInfo>> getFriendListRes =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .getFriendList();
    if (getFriendListRes.code == 0) {
      List<String> temp = [];
      getFriendListRes.data?.forEach((element) {
        temp.add(element.userID);
      });
      setState(() {
        friends = temp;
      });
    }
  }

  pressedFunction() async {
    V2TimCallback setC2CReceiveMessageOptRes = await TencentImSDKPlugin
        .v2TIMManager
        .getMessageManager()
        .setC2CReceiveMessageOpt(
            userIDList: [selectedId], // 需要设置的用户id列表
            opt: selectedOpt);
    setState(() {
      result = setC2CReceiveMessageOptRes.toJson().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    // setState(() {
    //   friends = context.watch<ListenerConfig>().friendList;
    // });

    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text('SetC2CReceiveMessageOpt'),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                DropdownMenu<String>(
                    width: 200,
                    label: const Text('user id'),
                    onSelected: (String? id) {
                      print(id);
                      selectedId = id ?? '';
                    },
                    requestFocusOnTap: true,
                    dropdownMenuEntries:
                        friends.map<DropdownMenuEntry<String>>((String id) {
                      return DropdownMenuEntry<String>(
                        value: id,
                        label: id,
                      );
                    }).toList()),
                const SizedBox(
                  width: 20,
                ),
                DropdownMenu<ReceiveMsgOptEnum>(
                    width: 200,
                    label: const Text('opt'),
                    onSelected: (ReceiveMsgOptEnum? id) {
                      selectedOpt =
                          id ?? ReceiveMsgOptEnum.V2TIM_RECEIVE_MESSAGE;
                    },
                    requestFocusOnTap: true,
                    dropdownMenuEntries: opt
                        .map<DropdownMenuEntry<ReceiveMsgOptEnum>>(
                            (ReceiveMsgOptEnum id) {
                      return DropdownMenuEntry<ReceiveMsgOptEnum>(
                        value: id,
                        label: id.name,
                      );
                    }).toList()),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              child: Text('SetC2CReceiveMessageOpt'),
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
