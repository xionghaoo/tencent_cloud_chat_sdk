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

class SetGroupReceiveMessageOpt extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SetGroupReceiveMessageOptState();
  }
}

class _SetGroupReceiveMessageOptState extends State<SetGroupReceiveMessageOpt> {
  String result = '';
  List<String> friends = [];
  List<String> groups = [];
  String selectedId = '';
  String selectedGroup = '';
  List<ReceiveMsgOptEnum> opt = [
    ReceiveMsgOptEnum.V2TIM_RECEIVE_MESSAGE,
    ReceiveMsgOptEnum.V2TIM_NOT_RECEIVE_MESSAGE,
  ];
  late ReceiveMsgOptEnum selectedOpt;
  TextEditingController _statusController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    result = '';

    getJoinedGroup();
  }

  getJoinedGroup() async {
    V2TimValueCallback<List<V2TimGroupInfo>> getJoinedGroupListRes =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getJoinedGroupList();
    if (getJoinedGroupListRes.code == 0) {
      List<String> temp = [];
      getJoinedGroupListRes.data?.forEach((element) {
        temp.add(element.groupID);
      });
      setState(() {
        groups = temp;
      });
    }
  }

  pressedFunction() async {
    V2TimCallback setGroupReceiveMessageOptRes = await TencentImSDKPlugin
        .v2TIMManager
        .getMessageManager()
        .setGroupReceiveMessageOpt(
            groupID: selectedGroup, // 需要设置的群组id
            opt: selectedOpt);
    setState(() {
      result = setGroupReceiveMessageOptRes.toJson().toString();
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
        title: Text('SetGroupReceiveMessageOpt'),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                DropdownMenu<String>(
                    width: 200,
                    label: const Text('group id'),
                    onSelected: (String? id) {
                      print(id);
                      selectedGroup = id ?? '';
                    },
                    requestFocusOnTap: true,
                    dropdownMenuEntries:
                        groups.map<DropdownMenuEntry<String>>((String id) {
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
            TextField(
              autofocus: true,
              controller: _statusController,
              decoration: InputDecoration(
                  labelText: "text message",
                  hintText: "text message",
                  prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              child: Text('SetGroupReceiveMessageOpt'),
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
