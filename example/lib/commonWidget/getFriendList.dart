// ignore_for_file: file_names

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

typedef Onselected = void Function(List<String> groupIds);

class SelectFriendsIds extends StatefulWidget {
  final Onselected onselected;
  final bool isMultSelect;
  const SelectFriendsIds({
    super.key,
    required this.onselected,
    required this.isMultSelect,
  });

  @override
  State<StatefulWidget> createState() => _SelectFriendsIdsState();
}

class _SelectFriendsIdsState extends State<SelectFriendsIds> {
  List<String> selectedGroupIds = [];

  ontap(String e) {
    var copy = selectedGroupIds;
    if (widget.isMultSelect) {
      if (copy.contains(e)) {
        copy.remove(e);
      } else {
        copy.add(e);
      }
    } else {
      copy = [e];
    }

    setState(() {
      selectedGroupIds = copy;
    });
    widget.onselected(selectedGroupIds);
  }

  List<String> ginfos = [];
  bool getSuccess = false;
  String hint = "加载重，请稍候";
  getJoinedGroupList() async {
    V2TimValueCallback<List<V2TimFriendInfo>> res = await TencentImSDKPlugin.v2TIMManager.getFriendshipManager().getFriendList();
    if (res.code == 0 && res.data != null) {
      if (res.data!.isNotEmpty) {
        List<String> infocopy = [];
        for (var element in res.data!) {
          String name = element.userProfile?.nickName ?? "";
          String id = element.userID;
          infocopy.add("($name)/id:$id");
        }
        setState(() {
          ginfos = infocopy;
          getSuccess = true;
        });
        return;
      }
    }
    setState(() {
      hint = "获取群成员失败,在控制台看错误原因";
      if (kDebugMode) {
        print(res);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getJoinedGroupList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
        height: 300,
        width: MediaQuery.of(context).size.width - 20,
        child: getSuccess
            ? Row(
                children: [
                  Expanded(
                    child: GridView(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 6,
                      ),
                      children: ginfos.map(
                        (e) {
                          bool selected = selectedGroupIds.contains(e);
                          return CheckboxListTile(
                              title: Text(e),
                              value: selected,
                              onChanged: (check) {
                                ontap(e);
                              });
                        },
                      ).toList(),
                    ),
                  ),
                ],
              )
            : Center(
                child: Text(hint),
              ),
      ),
    );
  }
}
