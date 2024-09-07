import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_topic_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_topic_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

class DeleteTopicFromCommunity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DeleteTopicFromCommunityState();
  }
}

class _DeleteTopicFromCommunityState extends State<DeleteTopicFromCommunity> {
  String result = '';
  List<String> friends = [];
  List<String> groups = [];
  List<String> keys = [];
  String selectedId = '';
  String selectedGroup = '';
  String selectedKey = '';
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

  getGroupTopic() async {
    V2TimValueCallback<List<V2TimTopicInfoResult>> getTopicInfoListoRes =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getTopicInfoList(
      groupID: selectedGroup, // 需要获取话题属性的群组id
      topicIDList: [], // 需要获取话题属性的话题id列表
    );
    if (getTopicInfoListoRes.code == 0) {
      List<String> temp = [];
      getTopicInfoListoRes.data?.forEach((element) {
        if (element.topicInfo!.topicID!.isNotEmpty) {
          String id = element.topicInfo!.topicID!;
          temp.add(id);
        }
      });

      setState(() {
        keys = temp;
      });
    }
  }

  pressedFunction() async {
    V2TimValueCallback<List<V2TimTopicOperationResult>>
        deleteTopicFromCommunityRes = await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .deleteTopicFromCommunity(
      groupID: selectedGroup, // 需要删除属性的群组id
      topicIDList: [selectedKey], // 删除的话题id列表
    );
    setState(() {
      result = deleteTopicFromCommunityRes.toJson().toString();
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
        title: Text('DeleteTopicFromCommunity'),
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
                      getGroupTopic();
                    },
                    requestFocusOnTap: true,
                    dropdownMenuEntries:
                        groups.map<DropdownMenuEntry<String>>((String id) {
                      return DropdownMenuEntry<String>(
                        value: id,
                        label: id,
                      );
                    }).toList()),
                SizedBox(
                  width: 10,
                ),
                DropdownMenu<String>(
                    width: 200,
                    label: const Text('topic'),
                    onSelected: (String? id) {
                      selectedKey = id ?? '';
                    },
                    requestFocusOnTap: true,
                    dropdownMenuEntries:
                        keys.map<DropdownMenuEntry<String>>((String id) {
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
              child: Text('DeleteTopicFromCommunity'),
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
