import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

class PinConversation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PinConversationState();
  }
}

class _PinConversationState extends State<PinConversation> {
  String result = '';
  List<String> conversations = [];
  String selectedconv = '';
  bool pin = false;
  TextEditingController _groupNameController = TextEditingController();
  TextEditingController _notificationController = TextEditingController();
  TextEditingController _informationController = TextEditingController();
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
    V2TimCallback pinConversationRes = await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .pinConversation(
            conversationID: selectedconv, //需要修改置顶属性的会话id
            isPinned: pin);
    setState(() {
      result = pinConversationRes.toJson().toString();
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
        title: Text('PinConversation'),
      ),
      body: Center(
        child: Column(
          children: [
            DropdownMenu<String>(
                width: 200,
                label: const Text('conversation'),
                onSelected: (String? id) {
                  selectedconv = id ?? '';
                },
                requestFocusOnTap: true,
                dropdownMenuEntries:
                    conversations.map<DropdownMenuEntry<String>>((String id) {
                  return DropdownMenuEntry<String>(
                    value: id,
                    label: id,
                  );
                }).toList()),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Text('Pin'),
                Switch(
                  // This bool value toggles the switch.
                  value: pin,
                  activeColor: Colors.red,
                  onChanged: (bool value) {
                    // This is called when the user toggles the switch.
                    setState(() {
                      pin = value;
                    });
                  },
                )
              ],
            ),
            ElevatedButton(
              child: Text('PinConversation'),
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
