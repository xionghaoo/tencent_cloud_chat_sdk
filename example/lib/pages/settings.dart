import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_cloud_chat_sdk_example/config.dart';

class Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsState();
  }
}

class _SettingsState extends State<Settings> {
  TextEditingController _sdkappidController = TextEditingController();
  TextEditingController _useridController = TextEditingController();
  TextEditingController _usersigController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initConfig();
  }

  void initConfig() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    _sdkappidController.text = prefs.getString('sdkappid') ?? '';
    _useridController.text = prefs.getString('userid') ?? '';
    _usersigController.text = prefs.getString('usersig') ?? '';
  }

  void login() async {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text('Settings'),
        actions: [
          ElevatedButton(
              onPressed: () async {
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
              },
              child: const Text("clean config"))
        ],
      ),
      body: Center(
          child: Column(
        children: <Widget>[
          TextField(
            autofocus: true,
            controller: _sdkappidController,
            decoration: const InputDecoration(labelText: "sdkappid", hintText: "sdkappid", prefixIcon: Icon(Icons.person)),
          ),
          TextField(
            controller: _useridController,
            decoration: const InputDecoration(labelText: "userid", hintText: "userid", prefixIcon: Icon(Icons.person)),
          ),
          TextField(
            controller: _usersigController,
            decoration: const InputDecoration(labelText: "userSig", hintText: "userSig", prefixIcon: Icon(Icons.lock)),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            child: const Text("确定"),
            onPressed: () async {
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('sdkappid', _sdkappidController.text);
              prefs.setString('userid', _useridController.text);
              prefs.setString('usersig', _usersigController.text);
              print("init sdk ${_sdkappidController.text} ${_useridController.text} ${_usersigController.text}");
              int code = await context.read<ListenerConfig>().initSDK();
              if (code == 0) {
                Navigator.pop(context);
              } else {
                prefs.clear();
                _sdkappidController.text = "";
                _useridController.text = "";
                _usersigController.text = "";
              }
            },
          ),
        ],
      )),
    ));
  }
}
