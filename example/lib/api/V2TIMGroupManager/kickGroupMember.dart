import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/enum/group_member_filter_enum.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

class KickGroupMember extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _KickGroupMemberState();
  }
}

class _KickGroupMemberState extends State<KickGroupMember> {
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
    getFriendList();

    getJoinedGroup();
  }

  getFriendList() async {
    V2TimValueCallback<V2TimGroupMemberInfoResult> getGroupMemberListRes =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getGroupMemberList(
              groupID: selectedGroup, // 需要查询的群组 ID
              filter: GroupMemberFilterTypeEnum
                  .V2TIM_GROUP_MEMBER_FILTER_ADMIN, //查询群成员类型
              nextSeq:
                  "0", // 分页拉取标志，第一次拉取填0，回调成功如果 nextSeq 不为零，需要分页，传入返回值再次拉取，直至为0。
              count: 100, // 需要拉取的数量。最大值：100，避免回包过大导致请求失败。若传入超过100，则只拉取前100个。
              offset: 0, // 偏移量，默认从0开始拉取。
            );
    if (getGroupMemberListRes.code == 0) {
      List<String> temp = [];
      getGroupMemberListRes.data?.memberInfoList?.forEach((element) {
        if (element!.userID.isNotEmpty) {
          temp.add(element.userID);
        }
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
    V2TimCallback kickGroupMemberRes =
        await TencentImSDKPlugin.v2TIMManager.getGroupManager().kickGroupMember(
            groupID: selectedGroup, // 需要踢人的群组id
            memberList: [selectedId], // 踢出的用户id列表
            reason: "" // 踢出原因
            );
    setState(() {
      result = kickGroupMemberRes.toJson().toString();
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
        title: Text('KickGroupMember'),
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
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              child: Text('KickGroupMember'),
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
