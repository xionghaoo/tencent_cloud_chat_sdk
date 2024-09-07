import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info.dart';
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

class SetGroupInfo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SetGroupInfoState();
  }
}

class _SetGroupInfoState extends State<SetGroupInfo> {
  String result = '';
  List<GroupInfo> groupInfo = [];
  String selectedId = '';
  late GroupInfo selectedGroup;
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
    V2TimValueCallback<List<V2TimGroupInfo>> getJoinedGroupListRes = await TencentImSDKPlugin.v2TIMManager.getGroupManager().getJoinedGroupList();
    if (getJoinedGroupListRes.code == 0) {
      List<GroupInfo> temp = [];
      getJoinedGroupListRes.data?.forEach((element) {
        GroupInfo info = GroupInfo(id: element.groupID, groupType: element.groupType);
        temp.add(info);
      });
      setState(() {
        groupInfo = temp;
      });
    }
    print(groupInfo.toString());
  }

  pressedFunction() async {
    V2TimGroupInfo info = V2TimGroupInfo(
        groupID: selectedGroup.id, // 群组id
        groupType: selectedGroup.groupType, // 群组类型
        introduction: _informationController.text,
        notification: _notificationController.text,
        isAllMuted: isAllMuted
        // 其余属性可见 V2TimGroupInfo
        );
    if (selectedGroup.groupType == "Community") {
      info.isSupportTopic = isSupportTopic;
    }

    V2TimCallback setGroupInfoRes = await TencentImSDKPlugin.v2TIMManager.getGroupManager().setGroupInfo(info: info);
    setState(() {
      result = setGroupInfoRes.toJson().toString();
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
        title: Text('SetGroupInfo'),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                DropdownMenu<GroupInfo>(
                    width: 200,
                    label: const Text('select group'),
                    onSelected: (GroupInfo? id) {
                      selectedGroup = id ?? GroupInfo(id: "", groupType: "");
                    },
                    requestFocusOnTap: true,
                    dropdownMenuEntries: groupInfo.map<DropdownMenuEntry<GroupInfo>>((GroupInfo id) {
                      return DropdownMenuEntry<GroupInfo>(value: id, label: id.id);
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
              child: Text('SetGroupInfo'),
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
