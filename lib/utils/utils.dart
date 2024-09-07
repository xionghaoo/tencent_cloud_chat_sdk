// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:math';

import 'package:tencent_cloud_chat_sdk/utils/const.dart';

class Utils {
  ///@nodoc
  ///
  static List<int> getAbility() {
    String t = StackTrace.current.toString();
    List<int> ab = List.empty(growable: true);
    TencentIMSDKCONST.scenes.keys.forEach((element) {
      if (t.contains(element)) {
        if (TencentIMSDKCONST.scenes.keys.contains(element)) {
          ab.add(TencentIMSDKCONST.scenes[element]!);
        }
      }
    });
    return ab;
  }

  ///@nodoc
  ///
  static String generateUniqueString() {
    var random = Random();
    var uniqueString = '';
    var characters =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

    while (uniqueString.length < 32) {
      var randomIndex = random.nextInt(characters.length);
      var randomChar = characters[randomIndex];
      uniqueString += randomChar;
    }

    return uniqueString;
  }

  static Map<String, dynamic> formatJson(Map? jsonSrc) {
    if (jsonSrc != null) {
      return Map<String, dynamic>.from(jsonSrc);
    }
    return Map<String, dynamic>.from({});
  }
}
