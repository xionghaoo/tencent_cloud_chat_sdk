import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/group_add_opt_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:tencent_cloud_chat_sdk_example/config.dart';

class CreateGroup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreateGroupState();
  }
}

class _CreateGroupState extends State<CreateGroup> {
  String result = '';
  List<String> groupType = [
    "Public",
    "Work",
    "Community",
    "Meeting",
    "AVChatRoom"
  ];
  String selectedType = '';
  TextEditingController _statusController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    result = '';
  }

  pressedFunction() async {
    if (groupType.isEmpty) {
      result = "选择一个群组类型";
      return;
    }
    V2TimValueCallback<String> createGroupRes =
        await TencentImSDKPlugin.v2TIMManager.getGroupManager().createGroup(
      groupType: selectedType, // 群类型
      groupName: _statusController.text, // 群名称，不能为 null。
      notification: "", // 群公告
      introduction: "", // 群介绍
      faceUrl: "", // 群头像Url
      isAllMuted: false, // 是否全体禁言
      isSupportTopic: false, // 是否支持话题
      addOpt: GroupAddOptTypeEnum.V2TIM_GROUP_ADD_AUTH, // 添加群设置
      memberList: [], // 初始成员列表
      defaultPermissions:0,
      isEnablePermissionGroup: false,
    );
    if(createGroupRes.code ==0){
      var groupId = createGroupRes.data ?? "";
      var setginfo = await TencentImSDKPlugin.v2TIMManager.getGroupManager().setGroupInfo(info: V2TimGroupInfo(groupID: groupId, groupType: selectedType,isEnablePermissionGroup: true));
      print(setginfo.toJson());
    }
    setState(() {
      result = createGroupRes.toJson().toString();
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
        title: Text('CreateGroup'),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                DropdownMenu<String>(
                    width: 200,
                    label: const Text('groupType'),
                    onSelected: (String? id) {
                      print(id);
                      selectedType = id ?? '';
                    },
                    requestFocusOnTap: true,
                    dropdownMenuEntries:
                        groupType.map<DropdownMenuEntry<String>>((String id) {
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
            TextField(
              autofocus: true,
              controller: _statusController,
              decoration: InputDecoration(
                  labelText: "group Name",
                  hintText: "group Name",
                  prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              child: Text('CreateGroup'),
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
