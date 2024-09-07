import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/enum/history_msg_get_type_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/message_priority_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/offlinePushInfo.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:tencent_cloud_chat_sdk_example/api/utils.dart';

class SendReplyMessage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SendReplyMessageState();
  }
}

class _SendReplyMessageState extends State<SendReplyMessage> {
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
    V2TimValueCallback<V2TimMsgCreateInfoResult> createTextMessageRes =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .createTextMessage(
              text: "replyMessage", // 回复消息的文本信息
            );
    if (createTextMessageRes.code == 0) {
      // 文本信息创建成功
      String? id = createTextMessageRes.data?.id;
      V2TimValueCallback<V2TimMessage> sendMessageRes = await TencentImSDKPlugin
          .v2TIMManager
          .getMessageManager()
          .sendReplyMessage(
              id: id!, // 发送的回复消息的id
              receiver: selectedId, // 接收人id
              groupID: selectedGroup, // 接收群组id
              replyMessage: selectedMessage, // 被回复的消息 类型为V2TimMessage
              priority: MessagePriorityEnum.V2TIM_PRIORITY_DEFAULT, // 消息优先级
              onlineUserOnly:
                  false, // 是否只有在线用户才能收到，如果设置为 true ，接收方历史消息拉取不到，常被用于实现“对方正在输入”或群组里的非重要提示等弱提示功能，该字段不支持 AVChatRoom。
              isExcludedFromUnreadCount: false, // 发送消息是否计入会话未读数
              needReadReceipt:
                  false, // 消息是否需要已读回执（只有 Group 消息有效，6.1 及以上版本支持，需要您购买旗舰版套餐）
              offlinePushInfo: OfflinePushInfo(), // 离线推送时携带的标题和内容
              localCustomData:
                  "" // 消息本地数据，消息附带的额外的数据，存本地，消息的接受者不可以访问到，App 卸载后数据丢失
              );
      setState(() {
        result = sendMessageRes.toJson().toString();
      });
    }
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
        title: Text('SendReplyMessage'),
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
            TextField(
              autofocus: true,
              controller: _statusController,
              decoration: InputDecoration(
                  labelText: "cloud custom data",
                  hintText: "cloud custom data",
                  prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              child: Text('SendReplyMessage'),
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
