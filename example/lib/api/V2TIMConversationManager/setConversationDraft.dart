import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/enum/v2_tim_conversation_marktype.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

class SetConversationDraft extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SetConversationDraftState();
  }
}

class _SetConversationDraftState extends State<SetConversationDraft> {
  String result = '';
  List<String> conversations = [];
  String selectedconv = '';
  TextEditingController _statusController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    result = '';
    getConversationList();
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
        conversations = temp;
      });
    }
  }

  pressedFunction() async {
    V2TimCallback setConversationDraftRes = await TencentImSDKPlugin
        .v2TIMManager
        .getConversationManager()
        .setConversationDraft(
          conversationID: selectedconv, //需要设置草稿的会话id
          draftText: _statusController.text, //草稿信息
        );
    setState(() {
      result = setConversationDraftRes.toJson().toString();
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
        title: Text('SetConversationDraft'),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                DropdownMenu<String>(
                    width: 200,
                    label: const Text('conversation'),
                    onSelected: (String? id) {
                      selectedconv = id ?? '';
                    },
                    requestFocusOnTap: true,
                    dropdownMenuEntries: conversations
                        .map<DropdownMenuEntry<String>>((String id) {
                      return DropdownMenuEntry<String>(
                        value: id,
                        label: id,
                      );
                    }).toList()),
              ],
            ),
            TextField(
              autofocus: true,
              controller: _statusController,
              decoration: InputDecoration(
                  labelText: "custom data",
                  hintText: "custom data",
                  prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              child: Text('SetConversationDraft'),
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
