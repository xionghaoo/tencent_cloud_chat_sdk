import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_topic_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

class SetTopicInfo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SetTopicInfoState();
  }
}

class _SetTopicInfoState extends State<SetTopicInfo> {
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

    getJoinedGroup();
  }

  getJoinedGroup() async {
    V2TimValueCallback<List<V2TimGroupInfo>> getJoinedCommunityListRes =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getJoinedCommunityList();
    if (getJoinedCommunityListRes.code == 0) {
      List<String> temp = [];
      getJoinedCommunityListRes.data?.forEach((element) {
        temp.add(element.groupID);
      });
      setState(() {
        groups = temp;
      });
    }
  }

  pressedFunction() async {
    V2TimTopicInfo topicInfo = V2TimTopicInfo(
      topicName: _statusController.text, // 话题名称
    );
    V2TimCallback setTopicInfoRes =
        await TencentImSDKPlugin.v2TIMManager.getGroupManager().setTopicInfo(
              topicInfo: topicInfo, // 需要修改的话题的设置
              groupID: selectedGroup, // 话题所在的群组id
            );

    setState(() {
      result = setTopicInfoRes.toJson().toString();
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
        title: Text('SetTopicInfo'),
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
              ],
            ),
            TextField(
              autofocus: true,
              controller: _statusController,
              decoration: InputDecoration(
                  labelText: "topic id",
                  hintText: "topic id",
                  prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              child: Text('SetTopicInfo'),
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
