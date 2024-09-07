import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

class SetSelfStatus extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SetSelfStatusState();
  }
}

class _SetSelfStatusState extends State<SetSelfStatus> {
  String result = '';
  TextEditingController _statusController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    result = '';
  }

  pressedFunction() async {
    String status = _statusController.text;
    V2TimCallback loginRes =
        await TencentImSDKPlugin.v2TIMManager.setSelfStatus(status: status);
    setState(() {
      result = loginRes.toJson().toString();
    });
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
        title: Text('SetSelfStatus'),
      ),
      body: Center(
        child: Column(
          children: [
            TextField(
              autofocus: true,
              controller: _statusController,
              decoration: InputDecoration(
                  labelText: "SetSelfStatus",
                  hintText: "SetSelfStatus",
                  prefixIcon: Icon(Icons.person)),
            ),
            ElevatedButton(
              child: Text('SetSelfStatus'),
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
