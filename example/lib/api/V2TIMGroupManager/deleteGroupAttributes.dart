import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

class DeleteGroupAttributes extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DeleteGroupAttributesState();
  }
}

class _DeleteGroupAttributesState extends State<DeleteGroupAttributes> {
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

  getGroupAttributes() async {
    V2TimValueCallback<Map<String, String>> getGroupAttributesRes =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getGroupAttributes(
                groupID: selectedGroup, // 需要获取属性的群组id
                keys: null // 获取的属性key值列表
                );
    if (getGroupAttributesRes.code == 0) {
      List<String> temp = [];
      temp = getGroupAttributesRes.data!.keys.toList();
      setState(() {
        keys = temp;
      });
    }
  }

  pressedFunction() async {
    V2TimCallback deleteGroupAttributesRes = await TencentImSDKPlugin
        .v2TIMManager
        .getGroupManager()
        .deleteGroupAttributes(groupID: selectedGroup, keys: [selectedKey]);
    setState(() {
      result = deleteGroupAttributesRes.toJson().toString();
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
        title: Text('DeleteGroupAttributes'),
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
                      getGroupAttributes();
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
                    label: const Text('key'),
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
              child: Text('DeleteGroupAttributes'),
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
