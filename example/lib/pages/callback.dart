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

class CallbackPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CallbackPageState();
  }
}

class _CallbackPageState extends State<CallbackPage> {
  List<String> callback = [];
  final List<Color> backgroundColors = [Colors.white, Colors.grey];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // callback = context.watch<ListenerConfig>().callbackList;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.read<ListenerConfig>().countZero();
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text('CallbackPage'),
      ),
      body: ListView.builder(
        reverse: true,
        itemCount: context.watch<ListenerConfig>().callbackList.length,
        itemBuilder: (context, index) {
          Color backgroundColor =
              backgroundColors[index % backgroundColors.length];

          return Container(
            // color: backgroundColor,
            child: Text(
              context.watch<ListenerConfig>().callbackList[index],
              style: TextStyle(color: Colors.black),
            ),
          );
        },
      ),
    ));
  }
}
