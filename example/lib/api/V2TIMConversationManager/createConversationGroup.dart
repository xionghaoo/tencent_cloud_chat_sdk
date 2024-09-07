import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:tencent_cloud_chat_sdk_example/config.dart';

class CreateConversationGroup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreateConversationGroupState();
  }
}

class _CreateConversationGroupState extends State<CreateConversationGroup> {
  String result = '';
  List<String> groups = [];
  String selectedGroup = '';
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
        groups = temp;
      });
    }
  }

  pressedFunction() async {
    V2TimValueCallback<List<V2TimConversationOperationResult>>
        setConversationCustomDataRes = await TencentImSDKPlugin.v2TIMManager
            .getConversationManager()
            .createConversationGroup(
                groupName: _statusController.text, // 创建的会话分组的名称
                conversationIDList: [selectedGroup]);
    setState(() {
      result = setConversationCustomDataRes.toJson().toString();
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
        title: Text('CreateConversationGroup 创建会话分组'),
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
            TextField(
              autofocus: true,
              controller: _statusController,
              decoration: InputDecoration(
                  labelText: "groupNAme",
                  hintText: "groupName",
                  prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              child: Text('CreateConversationGroup'),
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
