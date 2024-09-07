import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/history_msg_get_type_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/message_elem_type.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_list_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

class GetHistoryMessageList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GetHistoryMessageListState();
  }
}

class _GetHistoryMessageListState extends State<GetHistoryMessageList> {
  String result = '';
  List<String> friends = [];
  List<String> groups = [];
  String selectedId = '';
  String selectedGroup = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    result = '';
    getFriendList();
    getJoinedGroup();
  }

  getFriendList() async {
    V2TimValueCallback<List<V2TimFriendInfo>> getFriendListRes = await TencentImSDKPlugin.v2TIMManager.getFriendshipManager().getFriendList();
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
    V2TimValueCallback<List<V2TimGroupInfo>> getJoinedGroupListRes = await TencentImSDKPlugin.v2TIMManager.getGroupManager().getJoinedGroupList();
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
    if (selectedGroup.isNotEmpty && selectedId.isNotEmpty) {
      result = 'cannot set both';
      return;
    }

    V2TimValueCallback<V2TimMessageListResult> getHistoryMessageListRes = await TencentImSDKPlugin.v2TIMManager.getMessageManager().getHistoryMessageListV2(
      getType: HistoryMsgGetTypeEnum.V2TIM_GET_CLOUD_OLDER_MSG, // 拉取消息的位置及方向
      userID: selectedId.isNotEmpty ? selectedId : null, // 用户id 拉取单聊消息，需要指定对方的 userID，此时 groupID 传空即可。
      groupID: selectedGroup.isNotEmpty ? selectedGroup : null, // 群组id 拉取群聊消息，需要指定群聊的 groupID，此时 userID 传空即可。
      count: 100, // 拉取数据数量
      // 仅能在群聊中使用该字段。
      // 设置 lastMsgSeq 作为拉取的起点，返回的消息列表中包含这条消息。
      // 如果同时指定了 lastMsg 和 lastMsgSeq，SDK 优先使用 lastMsg。
      // 如果均未指定 lastMsg 和 lastMsgSeq，拉取的起点取决于是否设置 getTimeBegin。设置了，则使用设置的范围作为起点；未设置，则使用最新消息作为起点。
      // lastMsgSeq:2506157533,
          // messageTypeList: [
          //   MessageElemType.V2TIM_ELEM_TYPE_IMAGE,
          //   MessageElemType.V2TIM_ELEM_TYPE_SOUND,
          //   MessageElemType.V2TIM_ELEM_TYPE_VIDEO,
          //   MessageElemType.V2TIM_ELEM_TYPE_FILE,
          // ], // 用于过滤历史信息属性，若为空则拉取所有属性信息。
    );
    setState(() {
      result = (getHistoryMessageListRes.data?.toJson() ?? "").toString();
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
        title: Text('GetHistoryMessageList'),
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
                    dropdownMenuEntries: friends.map<DropdownMenuEntry<String>>((String id) {
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
                      print(id);
                      selectedGroup = id ?? '';
                    },
                    requestFocusOnTap: true,
                    dropdownMenuEntries: groups.map<DropdownMenuEntry<String>>((String id) {
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
            ElevatedButton(
              child: Text('GetHistoryMessageList'),
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
