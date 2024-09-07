import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/history_msg_get_type_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/message_elem_type.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_online_url.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_receipt.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:tencent_cloud_chat_sdk_example/api/utils.dart';
import 'package:tencent_cloud_chat_sdk_example/config.dart';

class SetLocalCustomInt extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SetLocalCustomIntState();
  }
}

class _SetLocalCustomIntState extends State<SetLocalCustomInt> {
  String result = '';
  List<String> friends = [];
  List<String> groups = [];
  List<V2TimMessage> messages = [];
  String selectedId = '';
  String selectedGroup = '';
  String aboutMessage = '';
  late V2TimMessage selectedMessage;
  TextEditingController _statusController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    result = '';
    getFriendList();

    getJoinedGroup();
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

  getMessageList() async {
    if (selectedGroup.isNotEmpty && selectedId.isNotEmpty) {
      result = '不能同时选择拉取的用户和群组';
      return;
    }
    if (selectedId.isNotEmpty) {
      V2TimValueCallback<List<V2TimMessage>> getHistoryMessageListRes =
          await TencentImSDKPlugin.v2TIMManager
              .getMessageManager()
              .getHistoryMessageList(
                getType: HistoryMsgGetTypeEnum
                    .V2TIM_GET_LOCAL_OLDER_MSG, // 拉取消息的位置及方向
                userID:
                    selectedId, // 用户id 拉取单聊消息，需要指定对方的 userID，此时 groupID 传空即可。
                groupID: null, // 群组id 拉取群聊消息，需要指定群聊的 groupID，此时 userID 传空即可。
                count: 10, // 拉取数据数量
              );
      if (getHistoryMessageListRes.code == 0) {
        List<V2TimMessage> temp = [];
        getHistoryMessageListRes.data?.forEach((element) {
          temp.add(element);
        });
        setState(() {
          messages = temp;
        });
      }
    } else {
      V2TimValueCallback<List<V2TimMessage>> getHistoryMessageListRes =
          await TencentImSDKPlugin.v2TIMManager
              .getMessageManager()
              .getHistoryMessageList(
                getType: HistoryMsgGetTypeEnum
                    .V2TIM_GET_LOCAL_OLDER_MSG, // 拉取消息的位置及方向
                userID: null, // 用户id 拉取单聊消息，需要指定对方的 userID，此时 groupID 传空即可。
                groupID:
                    selectedGroup, // 群组id 拉取群聊消息，需要指定群聊的 groupID，此时 userID 传空即可。
                count: 10, // 拉取数据数量
              );
      if (getHistoryMessageListRes.code == 0) {
        List<V2TimMessage> temp = [];
        getHistoryMessageListRes.data?.forEach((element) {
          temp.add(element);
        });
        setState(() {
          messages = temp;
        });
      }
    }
  }

  pressedFunction() async {
    V2TimCallback setLocalCustomIntRes = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .setLocalCustomInt(
            msgID: selectedMessage
                .msgID!, // 需要设置的消息id messageId为消息发送后服务端创建的messageid，不是创建消息时的消息id
            localCustomInt: 333);
    setState(() {
      result = setLocalCustomIntRes.toJson().toString();
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
        title: Text('SetLocalCustomInt'),
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
                      selectedId = id ?? '';
                      getMessageList();
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
                DropdownMenu<String>(
                    width: 200,
                    label: const Text('group id'),
                    onSelected: (String? id) {
                      selectedGroup = id ?? '';
                      getMessageList();
                    },
                    requestFocusOnTap: true,
                    dropdownMenuEntries:
                        groups.map<DropdownMenuEntry<String>>((String id) {
                      return DropdownMenuEntry<String>(
                        value: id,
                        label: id,
                      );
                    }).toList()),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            DropdownMenu<V2TimMessage>(
                width: 200,
                label: const Text('message id'),
                onSelected: (V2TimMessage? id) {
                  selectedMessage = id!;
                  setState(() {
                    aboutMessage = Utils.getMessageContent(id);
                  });
                },
                requestFocusOnTap: true,
                dropdownMenuEntries: messages
                    .map<DropdownMenuEntry<V2TimMessage>>((V2TimMessage id) {
                  return DropdownMenuEntry<V2TimMessage>(
                    value: id,
                    label: id.msgID!,
                  );
                }).toList()),
            const SizedBox(
              height: 20,
            ),
            Expanded(child: SingleChildScrollView(child: (Text(aboutMessage)))),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              child: Text('SetLocalCustomInt'),
              onPressed: () {
                pressedFunction();
              },
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(child: SingleChildScrollView(child: (Text(result))))
          ],
        ),
      ),
    ));
  }
}
