import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_receipt.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:tencent_cloud_chat_sdk_example/config.dart';

class AddGroupListener extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddGroupListenerState();
  }
}

class _AddGroupListenerState extends State<AddGroupListener> {
  String result = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  pressedFunction() async {
    // 创建消息监听器

    // 添加高级消息的事件监听器
    context.read<ListenerConfig>().addGroupListener();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text('AddGroupListener'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              child: Text('AddGroupListener'),
              onPressed: () {
                pressedFunction();
              },
            ),
            const SizedBox(
              height: 20,
            ),
            Text('${context.watch<ListenerConfig>().groupListenerData}')
          ],
        ),
      ),
    ));
  }
}
