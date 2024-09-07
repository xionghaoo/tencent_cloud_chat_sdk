import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversationList_filter.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation_filter.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:tencent_cloud_chat_sdk_example/config.dart';

class DeleteConversationFromGroup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DeleteConversationFromGroupState();
  }
}

class _DeleteConversationFromGroupState
    extends State<DeleteConversationFromGroup> {
  String result = '';
  List<String> friends = [];
  List<String> groups = [];
  String selectedId = '';
  String selectedGroup = '';
  TextEditingController _statusController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    result = '';
    getConversationGroupList();
  }

  getConversationGroupList() async {
    V2TimValueCallback<List<String>> getConversationGroupListDataRes =
        await TencentImSDKPlugin.v2TIMManager
            .getConversationManager()
            .getConversationGroupList();
    if (getConversationGroupListDataRes.code == 0) {
      List<String> temp = [];
      getConversationGroupListDataRes.data?.forEach((element) {
        temp.add(element);
      });
      setState(() {
        friends = temp;
      });
    }
  }

  getJoinedConversation() async {
    if (selectedId.isEmpty) {
      return;
    }
    V2TimConversationFilter filter =
        V2TimConversationFilter(conversationGroup: selectedId); //拉取的群组名
    //获取会话列表的高级接口
    V2TimValueCallback<V2TimConversationResult> getConversationListByFilterRes =
        await TencentImSDKPlugin.v2TIMManager
            .getConversationManager()
            .getConversationListByFilter(filter: filter, nextSeq: 0, count: 20);
    if (getConversationListByFilterRes.code == 0) {
      List<String> temp = [];
      getConversationListByFilterRes.data?.conversationList?.forEach((element) {
        temp.add(element!.conversationID);
      });
      setState(() {
        groups = temp;
      });
    }
  }

  pressedFunction() async {
    V2TimValueCallback<List<V2TimConversationOperationResult>>
        deleteConversationsFromGroupRes = await TencentImSDKPlugin.v2TIMManager
            .getConversationManager()
            .deleteConversationsFromGroup(
                groupName: selectedId, conversationIDList: [selectedGroup]);
    setState(() {
      result = deleteConversationsFromGroupRes.toJson().toString();
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
        title: Text('DeleteConversationFromGroup'),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                DropdownMenu<String>(
                    width: 200,
                    label: const Text('conv group'),
                    onSelected: (String? id) {
                      selectedId = id ?? '';
                      getJoinedConversation();
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
                    label: const Text('conv id'),
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
              ],
            ),
            ElevatedButton(
              child: Text('DeleteConversationFromGroup'),
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
