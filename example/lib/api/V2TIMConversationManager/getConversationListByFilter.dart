import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/history_msg_get_type_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversationList_filter.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation_filter.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

class GetConversationListByFilter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GetConversationListByFilterState();
  }
}

class _GetConversationListByFilterState
    extends State<GetConversationListByFilter> {
  String result = '';
  List<String> conversations = [];
  String selectedId = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    result = '';
    // getConversationList();
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
      getConversationListRes.data?.conversationList?.forEach((element) {
        conversations.add(element!.conversationID);
      });
    }
  }

  pressedFunction() async {
    V2TimConversationFilter filter = V2TimConversationFilter(
      conversationGroup: '',
      hasUnreadCount: true,
      hasGroupAtInfo: false,
      conversationType: 0, //会话类型
      markType: 0, //会话标记类型
    ); //拉取的群组名
    //获取会话列表的高级接口
    V2TimValueCallback<V2TimConversationResult> getConversationListByFilterRes =
        await TencentImSDKPlugin.v2TIMManager
            .getConversationManager()
            .getConversationListByFilter(filter: filter, nextSeq: 0, count: 20);
    setState(() {
      result = getConversationListByFilterRes.toJson().toString();
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
        title: Text('GetConversationListByFilter'),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                DropdownMenu<String>(
                    width: 200,
                    label: const Text('conv id'),
                    onSelected: (String? id) {
                      selectedId = id ?? '';
                    },
                    requestFocusOnTap: true,
                    dropdownMenuEntries: conversations
                        .map<DropdownMenuEntry<String>>((String id) {
                      return DropdownMenuEntry<String>(
                        value: id,
                        label: id,
                      );
                    }).toList()),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              child: Text('GetConversationListByFilter'),
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
