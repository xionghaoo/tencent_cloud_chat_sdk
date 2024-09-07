import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_group.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

class DeleteFriendsFromFriendGroup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DeleteFriendsFromFriendGroupState();
  }
}

class _DeleteFriendsFromFriendGroupState
    extends State<DeleteFriendsFromFriendGroup> {
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
    getFriendGroupList();
  }

  getFriendList() async {
    V2TimValueCallback<List<V2TimFriendInfo>> getFriendListRes =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .getFriendList();
    if (getFriendListRes.code == 0) {
      List<String> temp = [];
      getFriendListRes.data?.forEach((element) {
        temp.add(element.userID);
      });
      setState(() {
        friends = temp;
      });
    }
  }

  getFriendGroupList() async {
    V2TimValueCallback<List<V2TimFriendGroup>> getFriendGroupsRes =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .getFriendGroups(groupNameList: null);
    if (getFriendGroupsRes.code == 0) {
      List<String> temp = [];
      getFriendGroupsRes.data?.forEach((element) {
        String name = element.name ?? "";
        if (name != "") {
          temp.add(name);
        }
      });
      setState(() {
        groups = temp;
      });
    }
  }

  pressedFunction() async {
    V2TimValueCallback<List<V2TimFriendOperationResult>>
        deleteFriendsFromFriendGroupRes = await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .deleteFriendsFromFriendGroup(
                groupName: selectedGroup, //需要删除的群组名称
                userIDList: [selectedId] //需要删除的用户id列表
                );
    setState(() {
      result = deleteFriendsFromFriendGroupRes.toJson().toString();
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
        title: Text('DeleteFriendsFromFriendGroup'),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
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
                DropdownMenu<String>(
                    width: 200,
                    label: const Text('group name'),
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
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              child: Text('DeleteFriendsFromFriendGroup'),
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
