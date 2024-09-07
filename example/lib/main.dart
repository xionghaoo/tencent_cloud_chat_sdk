// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimConversationListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimFriendshipListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimGroupListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/group_add_opt_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/history_msg_get_type_enum.dart';

import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/manager/v2_tim_manager.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';

import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:tencent_cloud_chat_sdk_example/config.dart';
import 'package:tencent_cloud_chat_sdk_example/pages/V2TIMCommunityManager.dart';
import 'package:tencent_cloud_chat_sdk_example/pages/V2TIMConversationManager.dart';
import 'package:tencent_cloud_chat_sdk_example/pages/V2TIMFriendManager.dart';
import 'package:tencent_cloud_chat_sdk_example/pages/V2TIMGroupManager.dart';
import 'package:tencent_cloud_chat_sdk_example/pages/V2TIMManager.dart';
import 'package:tencent_cloud_chat_sdk_example/pages/V2TIMMessageManager.dart';
import 'package:tencent_cloud_chat_sdk_example/pages/callback.dart';
import 'package:tencent_cloud_chat_sdk_example/pages/settings.dart';

void main() {
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => ListenerConfig()),
    ], child: const MaterialApp(home: MyApp())),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}



class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  bool isLogin = false;
  @override
  void initState() {
    super.initState();
    // isLogin = context.watch<ListenerConfig>().isLogin;
    initConfig();
    print("init here");
  }

  void initConfig() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String sdkappid = prefs.getString('sdkappid') ?? '';
    String userid = prefs.getString('userid') ?? '';
    String usersig = prefs.getString('usersig') ?? '';

    if (sdkappid.isNotEmpty && userid.isNotEmpty && usersig.isNotEmpty) {
      // ignore: use_build_context_synchronously
      int code = await context.read<ListenerConfig>().initSDK();
      if (code == 0) {
        context.read<ListenerConfig>().setisLogin(true);
      } else {
        prefs.clear();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Settings()),
        );
        context.read<ListenerConfig>().setisLogin(false);
      }
    } else {
      prefs.clear();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Settings()),
      );
      context.read<ListenerConfig>().setisLogin(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20),
      // backgroundColor: isLogin == false ? Colors.grey : Colors.purple[100],
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
    );
    return MaterialApp(
      color: Colors.white,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          leading: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Settings()),
                );
              },
              icon: const Icon(Icons.settings)),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CallbackPage()),
            );
          },
          tooltip: '获取callback',
          child: Text(' ${context.watch<ListenerConfig>().count}'),
        ),
        body: Wrap(
          spacing: 10, // 子小部件之间的水平间距
          runSpacing: 10,
          children: [
            ElevatedButton(
              style: style,
              onPressed: Provider.of<ListenerConfig>(context, listen: true).isLogin
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => V2TIMManagerPage()),
                      );
                    }
                  : null,
              child: const Text('V2TIMManager 基础模块'),
            ),
            ElevatedButton(
              style: style,
              onPressed: Provider.of<ListenerConfig>(context, listen: true).isLogin
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => V2TIMMessageManagerPage()),
                      );
                    }
                  : null,
              child: const Text('V2TIMMessageManager 消息模块'),
            ),
            ElevatedButton(
              style: style,
              onPressed: Provider.of<ListenerConfig>(context, listen: true).isLogin
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => V2TIMConversationManagerPage()),
                      );
                    }
                  : null,
              child: const Text('V2TIMConversationManager 会话模块'),
            ),
            ElevatedButton(
              style: style,
              onPressed: Provider.of<ListenerConfig>(context, listen: true).isLogin
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => V2TIMGroupManagerPage(),
                        ),
                      );
                    }
                  : null,
              child: const Text('V2TIMGroupManager 群组模块'),
            ),
            ElevatedButton(
              style: style,
              onPressed: Provider.of<ListenerConfig>(context, listen: true).isLogin
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => V2TIMFriendshipManagerPage(),
                        ),
                      );
                    }
                  : null,
              child: const Text('V2TIMFriendshipManager 好友模块'),
            ),
            ElevatedButton(
              style: style,
              onPressed: null,
              child: const Text('V2TIMOfflinePushManager 推送模块'),
            ),
            ElevatedButton(
              style: style,
              onPressed: null,
              child: const Text('V2TIMSignalingManager 信令模块'),
            ),
            ElevatedButton(
              style: style,
              onPressed: Provider.of<ListenerConfig>(context, listen: true).isLogin
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const V2TIMCommunityManagerPage(),
                        ),
                      );
                    }
                  : null,
              child: const Text('V2TIMCommunityManager 社群模块'),
            ),
          ],
        ),
      ),
    );
  }
}
