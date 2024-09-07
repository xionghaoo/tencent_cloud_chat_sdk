import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/enum/v2_tim_conversation_marktype.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

class MarkConversation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MarkConversationState();
  }
}

class _MarkConversationState extends State<MarkConversation> {
  String result = '';
  List<int> markType = [
    V2TimConversationMarkType.V2TIM_CONVERSATION_MARK_TYPE_FOLD,
    V2TimConversationMarkType.V2TIM_CONVERSATION_MARK_TYPE_HIDE,
    V2TimConversationMarkType.V2TIM_CONVERSATION_MARK_TYPE_STAR,
    V2TimConversationMarkType.V2TIM_CONVERSATION_MARK_TYPE_UNREAD
  ];
  List<String> conversations = [];
  int selectedtype = -1;
  String selectedconv = '';
  TextEditingController _statusController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    result = '';
    getConversationList();

    // getJoinedGroup();
  }

  getConversationList() async {
    V2TimValueCallback<V2TimConversationResult> getConversationListRes = await TencentImSDKPlugin.v2TIMManager.getConversationManager().getConversationList(
        count: 100, //分页拉取的个数，一次分页拉取不宜太多，会影响拉取的速度，建议每次拉取 100 个会话
        nextSeq: "0" //分页拉取的游标，第一次默认取传 0，后续分页拉传上一次分页拉取成功回调里的 nextSeq
        );
    if (getConversationListRes.code == 0) {
      List<String> temp = [];
      getConversationListRes.data?.conversationList?.forEach((element) {
        temp.add(element!.conversationID);
      });
      print(temp);
      setState(() {
        conversations = temp;
      });
    }
  }

  pressedFunction() async {
    if (selectedtype == -1) {
      return;
    }
    Int64 value = Int64(0x1) << 32;
    int t = int.parse(value.toString());
    print(t);
    V2TimValueCallback<List<V2TimConversationOperationResult>> markConversationRes = await TencentImSDKPlugin.v2TIMManager.getConversationManager().markConversation(
        markType: selectedtype, //标记类型
        enableMark: true, //是否支持标记功能
        conversationIDList: [selectedconv]);
    setState(() {
      result = markConversationRes.toJson().toString();
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
        title: Text('MarkConversation'),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                DropdownMenu<int>(
                    width: 200,
                    label: const Text('markType'),
                    onSelected: (int? id) {
                      selectedtype = id ?? -1;
                    },
                    requestFocusOnTap: true,
                    dropdownMenuEntries: markType.map<DropdownMenuEntry<int>>((int id) {
                      return DropdownMenuEntry<int>(
                        value: id,
                        label: id.toString(),
                      );
                    }).toList()),
                const SizedBox(
                  width: 20,
                ),
                DropdownMenu<String>(
                    width: 200,
                    label: const Text('conversation'),
                    onSelected: (String? id) {
                      selectedconv = id ?? '';
                    },
                    requestFocusOnTap: true,
                    dropdownMenuEntries: conversations.map<DropdownMenuEntry<String>>((String id) {
                      return DropdownMenuEntry<String>(
                        value: id,
                        label: id,
                      );
                    }).toList()),
              ],
            ),
            ElevatedButton(
              child: Text('MarkConversation'),
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
