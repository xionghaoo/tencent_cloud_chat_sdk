import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/group_member_filter_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/group_member_role_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:tencent_cloud_chat_sdk_example/config.dart';

class SetGroupMemberRole extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SetGroupMemberRoleState();
  }
}

class _SetGroupMemberRoleState extends State<SetGroupMemberRole> {
  String result = '';
  List<String> friends = [];
  List<String> groups = [];
  List<GroupMemberRoleTypeEnum> role = [
    GroupMemberRoleTypeEnum.V2TIM_GROUP_MEMBER_ROLE_ADMIN,
    GroupMemberRoleTypeEnum.V2TIM_GROUP_MEMBER_ROLE_MEMBER,
    GroupMemberRoleTypeEnum.V2TIM_GROUP_MEMBER_ROLE_OWNER,
    GroupMemberRoleTypeEnum.V2TIM_GROUP_MEMBER_UNDEFINED
  ];
  GroupMemberRoleTypeEnum selectedRole =
      GroupMemberRoleTypeEnum.V2TIM_GROUP_MEMBER_ROLE_MEMBER;
  String selectedId = '';
  String selectedGroup = '';
  TextEditingController _statusController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    result = '';

    getJoinedGroup();
  }

  getGroupMember() async {
    V2TimValueCallback<V2TimGroupMemberInfoResult> getGroupMemberListRes =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getGroupMemberList(
              groupID: selectedGroup, // 需要查询的群组 ID
              filter: GroupMemberFilterTypeEnum
                  .V2TIM_GROUP_MEMBER_FILTER_ALL, //查询群成员类型
              nextSeq:
                  "0", // 分页拉取标志，第一次拉取填0，回调成功如果 nextSeq 不为零，需要分页，传入返回值再次拉取，直至为0。
              count: 100, // 需要拉取的数量。最大值：100，避免回包过大导致请求失败。若传入超过100，则只拉取前100个。
              offset: 0, // 偏移量，默认从0开始拉取。
            );
    if (getGroupMemberListRes.code == 0) {
      List<String> temp = [];
      getGroupMemberListRes.data?.memberInfoList?.forEach((element) {
        temp.add(element!.userID);
      });
      setState(() {
        friends = temp;
      });
    }
  }

  getJoinedGroup() async {
    V2TimValueCallback<List<V2TimGroupInfo>> getJoinedGroupListRes =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getJoinedGroupList();
    if (getJoinedGroupListRes.code == 0) {
      List<String> temp = [];
      getJoinedGroupListRes.data?.forEach((element) {
        temp.add(element.groupID);
      });
      setState(() {
        groups = temp;
      });
    }
  }

  pressedFunction() async {
    V2TimCallback setGroupMemberRoleRes = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .setGroupMemberRole(
            groupID: selectedGroup, // 设置群组的id
            userID: selectedId, // 被设置角色的用户id
            role: selectedRole // 用户被设置的角色属性
            );
    setState(() {
      result = setGroupMemberRoleRes.toJson().toString();
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
        title: Text('SetGroupMemberRole'),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                DropdownMenu<String>(
                    width: 200,
                    label: const Text('group id'),
                    onSelected: (String? id) {
                      selectedGroup = id ?? '';
                      getGroupMember();
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
                DropdownMenu<GroupMemberRoleTypeEnum>(
                    width: 200,
                    label: const Text('role'),
                    onSelected: (GroupMemberRoleTypeEnum? id) {
                      selectedRole = id ??
                          GroupMemberRoleTypeEnum
                              .V2TIM_GROUP_MEMBER_ROLE_MEMBER;
                    },
                    requestFocusOnTap: true,
                    dropdownMenuEntries: role
                        .map<DropdownMenuEntry<GroupMemberRoleTypeEnum>>(
                            (GroupMemberRoleTypeEnum id) {
                      return DropdownMenuEntry<GroupMemberRoleTypeEnum>(
                        value: id,
                        label: id.name,
                      );
                    }).toList()),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              child: Text('SetGroupMemberRole'),
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