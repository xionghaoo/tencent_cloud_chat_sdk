import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/group_application_type_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_application.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_application_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:tencent_cloud_chat_sdk_example/config.dart';

class GroupInfo {
  String id;
  String groupType;

  GroupInfo({required this.id, required this.groupType});
}

class AcceptGroupApplication extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AcceptGroupApplicationState();
  }
}

class _AcceptGroupApplicationState extends State<AcceptGroupApplication> {
  String result = '';
  List<V2TimGroupApplication> applicationInfo = [];
  String selectedId = '';
  late V2TimGroupApplication selectedGroup;
  bool isAllMuted = false;
  bool isSupportTopic = false;
  TextEditingController _groupNameController = TextEditingController();
  TextEditingController _notificationController = TextEditingController();
  TextEditingController _informationController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    result = '';
    getJoinedGroup();
  }

  getJoinedGroup() async {
    V2TimValueCallback<V2TimGroupApplicationResult> getGroupApplicationListRes = await TencentImSDKPlugin.v2TIMManager.getGroupManager().getGroupApplicationList();
    if (getGroupApplicationListRes.code == 0) {
      List<V2TimGroupApplication> temp = [];
      getGroupApplicationListRes.data?.groupApplicationList?.forEach((element) {
        temp.add(element!);
      });
      setState(() {
        applicationInfo = temp;
      });
    }
  }

  pressedFunction() async {
    V2TimCallback acceptGroupApplicationRes = await TencentImSDKPlugin.v2TIMManager.getGroupManager().acceptGroupApplication(
          groupID: selectedGroup.groupID, // 加入的群组id
          fromUser: selectedGroup.fromUser!, //  请求者id
          toUser: selectedGroup.toUser!, // 判决者id
          reason: "", // 同意原因
          addTime: selectedGroup.addTime, // 申请时间
          type: GroupApplicationTypeEnum.values[selectedGroup.type], // 申请类型
          webMessageInstance: "", // 对应【群系统通知】的消息实例
        );
    setState(() {
      result = acceptGroupApplicationRes.toJson().toString();
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
        title: Text('AcceptGroupApplication'),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                DropdownMenu<V2TimGroupApplication>(
                    width: 200,
                    label: const Text('select group'),
                    onSelected: (V2TimGroupApplication? id) {
                      selectedGroup = id!;
                    },
                    requestFocusOnTap: true,
                    dropdownMenuEntries: applicationInfo.map<DropdownMenuEntry<V2TimGroupApplication>>((V2TimGroupApplication id) {
                      return DropdownMenuEntry<V2TimGroupApplication>(value: id, label: id.groupID);
                    }).toList()),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              autofocus: true,
              controller: _groupNameController,
              decoration: InputDecoration(labelText: "groupName", hintText: "groupName", prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              autofocus: true,
              controller: _notificationController,
              decoration: InputDecoration(labelText: "notification", hintText: "notification", prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              autofocus: true,
              controller: _informationController,
              decoration: InputDecoration(labelText: "information", hintText: "information", prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Text('isAllMuted'),
                Switch(
                  // This bool value toggles the switch.
                  value: isAllMuted,
                  activeColor: Colors.red,
                  onChanged: (bool value) {
                    // This is called when the user toggles the switch.
                    setState(() {
                      isAllMuted = value;
                    });
                  },
                )
              ],
            ),
            Row(
              children: [
                Text('isSupportTopic'),
                Switch(
                  // This bool value toggles the switch.
                  value: isSupportTopic,
                  activeColor: Colors.red,
                  onChanged: (bool value) {
                    // This is called when the user toggles the switch.
                    setState(() {
                      isSupportTopic = value;
                    });
                  },
                )
              ],
            ),
            ElevatedButton(
              child: Text('AcceptGroupApplication'),
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
