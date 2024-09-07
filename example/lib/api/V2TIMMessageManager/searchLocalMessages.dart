import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/message_elem_type.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_search_param.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_search_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:tencent_cloud_chat_sdk_example/config.dart';

class SearchLocalMessages extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchLocalMessagesState();
  }
}

class _SearchLocalMessagesState extends State<SearchLocalMessages> {
  String result = '';
  List<String> friends = [];
  List<String> groups = [];
  String selectedId = '';
  String selectedGroup = '';
  List<int> messageType = [
    MessageElemType.V2TIM_ELEM_TYPE_CUSTOM,
    MessageElemType.V2TIM_ELEM_TYPE_FILE,
    MessageElemType.V2TIM_ELEM_TYPE_IMAGE,
    MessageElemType.V2TIM_ELEM_TYPE_LOCATION,
    MessageElemType.V2TIM_ELEM_TYPE_MERGER,
    MessageElemType.V2TIM_ELEM_TYPE_SOUND,
    MessageElemType.V2TIM_ELEM_TYPE_TEXT,
    MessageElemType.V2TIM_ELEM_TYPE_VIDEO
  ];
  List<String> typeInString = [
    "none",
    "text",
    "custom",
    "image",
    "sound",
    "video",
    "file",
    "location",
    "face",
    "tips",
    "merger"
  ];
  int selectedMessage = -1;
  TextEditingController _statusController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    result = '';
    getFriendList();

    getConversationList();
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

  getConversationList() async {
    V2TimValueCallback<V2TimConversationResult> getConversationListRes =
        await TencentImSDKPlugin.v2TIMManager
            .getConversationManager()
            .getConversationList(
                count: 100, //分页拉取的个数，一次分页拉取不宜太多，会影响拉取的速度，建议每次拉取 100 个会话
                nextSeq: "0" //分页拉取的游标，第一次默认取传 0，后续分页拉传上一次分页拉取成功回调里的 nextSeq
                );
    if (getConversationListRes.code == 0) {
      List<String> temp = [];
      getConversationListRes.data?.conversationList?.forEach((element) {
        temp.add(element!.conversationID);
      });
      setState(() {
        groups = temp;
      });
    }
  }

  pressedFunction() async {
    List<String> keywordList = [];
    if (_statusController.text.isNotEmpty) {
      keywordList.add(_statusController.text);
    }
    List<String> userList = [];
    if (selectedId.isNotEmpty) {
      userList.add(selectedId);
    }
    V2TimMessageSearchParam searchParam = V2TimMessageSearchParam(
        conversationID: selectedGroup.isNotEmpty
            ? selectedGroup
            : null, // conversationID == null，代表搜索全部会话，conversationID != null，代表搜索指定会话。
        keywordList:
            keywordList, // 关键字列表，最多支持5个。当消息发送者以及消息类型均未指定时，关键字列表必须非空；否则，关键字列表可以为空。
        type: 3, // 获取历史消息类型
        userIDList: userList, // 指定 userID 发送的消息，最多支持5个。
        messageTypeList: [
          selectedMessage == -1 ? 0 : selectedMessage
        ], // 消息类型过滤列表
        searchTimePeriod:
            0, // 从起始时间点开始的过去时间范围，单位秒。默认为0即代表不限制时间范围，传24x60x60代表过去一天。
        searchTimePosition: 0, // 搜索的起始时间点。默认为0即代表从现在开始搜索。UTC 时间戳，单位：秒
        pageIndex: 0, // 分页的页号：用于分页展示查找结果，从零开始起步。
        pageSize: 10);
    V2TimValueCallback<V2TimMessageSearchResult> searchLocalMessagesRes =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .searchLocalMessages(searchParam: searchParam);
    setState(() {
      result = searchLocalMessagesRes.toJson().toString();
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
        title: Text('SearchLocalMessages'),
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
                    label: const Text('conversation id'),
                    onSelected: (String? id) {
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
                DropdownMenu<int>(
                    width: 200,
                    label: const Text('conversation id'),
                    onSelected: (int? id) {
                      selectedMessage = id ?? -1;
                    },
                    requestFocusOnTap: true,
                    dropdownMenuEntries:
                        messageType.map<DropdownMenuEntry<int>>((int id) {
                      return DropdownMenuEntry<int>(
                        value: id,
                        label: typeInString[id],
                      );
                    }).toList()),
              ],
            ),
            TextField(
              autofocus: true,
              controller: _statusController,
              decoration: InputDecoration(
                  labelText: "keyword",
                  hintText: "keyword",
                  prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              child: Text('SearchLocalMessages'),
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
