import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_topic_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:tencent_cloud_chat_sdk_example/config.dart';

class CreateTopicInCommunity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreateTopicInCommunityState();
  }
}

class _CreateTopicInCommunityState extends State<CreateTopicInCommunity> {
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
    V2TimValueCallback<List<V2TimGroupInfo>> getJoinedGroupListRes =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getJoinedCommunityList();
    if (getJoinedGroupListRes.code == 0) {
      List<String> temp = [];
      print(getJoinedGroupListRes.toJson());
      getJoinedGroupListRes.data?.forEach((element) {
        if(element.customInfo !=null){
          var kesy = element.customInfo!.keys.toList();
          print("keys $kesy");
          for (var i = 0; i < kesy.length; i++) {
            print("${kesy[i]} ${element.customInfo![kesy[i]]}");
          }
        }
        if (element.groupType == "Community") {
          temp.add(element.groupID);
        }
      });
      setState(() {
        groups = temp;
      });
    }
  }

  pressedFunction() async {
    V2TimTopicInfo topicInfo = V2TimTopicInfo(
      topicID: _statusController.text, // 话题id
      topicName: _statusController.text, // 话题名称
    );
    V2TimValueCallback<String> createTopicInCommunityRes =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .createTopicInCommunity(
              groupID: selectedGroup, // 需要创建话题的群组id
              topicInfo: topicInfo, // 创建话题的设置
            );
            
    setState(() {
      result = createTopicInCommunityRes.toJson().toString();
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
        title: Text('CreateTopicInCommunity'),
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
              child: Text('CreateTopicInCommunity'),
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
