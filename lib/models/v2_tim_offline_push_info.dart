import 'package:tencent_cloud_chat_sdk/utils/utils.dart';

/// V2TimOfflinePushInfo
///
/// {@category Models}
///
// ignore_for_file: non_constant_identifier_names

class V2TimOfflinePushInfo {
  late String? title;
  late String? desc;
  String? ext;
  late bool? disablePush;
  late String? iOSSound;
  late bool? ignoreIOSBadge;
  late String? androidOPPOChannelID;
  late String? androidVIVOClassification;
  late String? androidSound;

  V2TimOfflinePushInfo({
    this.title,
    this.desc,
    this.disablePush,
    this.iOSSound,
    this.ignoreIOSBadge,
    this.androidOPPOChannelID,
    this.ext,
    this.androidSound,
    this.androidVIVOClassification,
  });

  V2TimOfflinePushInfo.fromJson(Map json) {
    json = Utils.formatJson(json);
    title = json['title'];
    desc = json['desc'];
    ext = json['ext'];
    disablePush = json['disablePush'] ?? false;
    iOSSound = json['iOSSound'];
    ignoreIOSBadge = json['ignoreIOSBadge'];
    androidOPPOChannelID = (json['androidOPPOChannelID'] ?? "").toString();
    androidSound = (json['androidSound'] ?? "").toString();
    androidVIVOClassification =
        (json['androidVIVOClassification'] ?? "").toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['desc'] = desc;
    data['ext'] = ext;
    data['disablePush'] = disablePush;
    data['iOSSound'] = iOSSound;
    data['ignoreIOSBadge'] = ignoreIOSBadge;
    data['androidOPPOChannelID'] = androidOPPOChannelID;
    data['androidSound'] = androidSound;
    data['androidVIVOClassification'] = androidVIVOClassification;
    return data;
  }
  String toLogString() {
    String res = "title:$title|desc:$desc|ext:$ext";
    return res;
  }
}

// {
//   "title":"",
//   "desc":"",
//   "disablePush":true
// }
