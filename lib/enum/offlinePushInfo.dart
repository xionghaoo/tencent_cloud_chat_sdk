// ignore_for_file: file_names
import 'package:tencent_cloud_chat_sdk/utils/utils.dart';

class OfflinePushInfo {
  late String? title;
  late String? desc;
  String? ext;
  late bool? disablePush = false;
  late String? iOSSound;
  late bool? ignoreIOSBadge;
  late String? androidOPPOChannelID;
  late int? androidVIVOClassification = 1;
  late String? androidSound;
  String? androidFCMChannelID;
  String? androidXiaoMiChannelID;
  int? iOSPushType = 0; // 1 is voip
  String? androidHuaWeiCategory;
  String? androidVIVOCategory;
  String? androidHuaWeiImage;
  String? androidHonorImage;
  String? androidFCMImage;
  String? iOSImage;
  OfflinePushInfo({
    this.title,
    this.desc,
    this.disablePush,
    this.iOSSound,
    this.ignoreIOSBadge,
    this.androidOPPOChannelID,
    this.ext,
    this.androidSound,
    this.androidVIVOClassification,
    this.androidFCMChannelID,
    this.androidXiaoMiChannelID,
    this.iOSPushType,
    this.androidHuaWeiCategory,
    this.androidVIVOCategory,
    this.androidHuaWeiImage,
    this.androidHonorImage,
    this.androidFCMImage,
    this.iOSImage,
  });

  OfflinePushInfo.fromJson(Map json) {
    json = Utils.formatJson(json);
    title = json['title'];
    desc = json['desc'];
    ext = json['ext'];
    disablePush = json['disablePush'] ?? false;
    iOSSound = json['iOSSound'];
    ignoreIOSBadge = json['ignoreIOSBadge'];
    androidOPPOChannelID = (json['androidOPPOChannelID'] ?? "").toString();
    androidSound = (json['androidSound'] ?? "").toString();
    androidVIVOClassification = (json['androidVIVOClassification'] ?? 1);
    androidFCMChannelID = json["androidFCMChannelID"] ?? "";
    androidXiaoMiChannelID = json["androidXiaoMiChannelID"] ?? "";
    iOSPushType = json["iOSPushType"] ?? 0;
    androidHuaWeiCategory = json["androidHuaWeiCategory"] ?? "";
    androidVIVOCategory = json["androidVIVOCategory"] ?? "";
    androidHuaWeiImage = json["androidHuaWeiImage"] ?? "";
    androidHonorImage = json["androidHonorImage"] ?? "";
    androidFCMImage = json["androidFCMImage"] ?? "";
    iOSImage = json["iOSImage"] ?? "";
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

    data['androidFCMChannelID'] = androidFCMChannelID;
    data['androidXiaoMiChannelID'] = androidXiaoMiChannelID;
    data['iOSPushType'] = iOSPushType;
    data['androidHuaWeiCategory'] = androidHuaWeiCategory;
    data["androidVIVOCategory"] = androidVIVOCategory;

    data["androidHuaWeiImage"] = androidHuaWeiImage ?? "";
    data["androidHonorImage"] = androidHonorImage ?? "";
    data["androidFCMImage"] = androidFCMImage ?? "";
    data["iOSImage"] = iOSImage ?? "";
    return data;
  }
  String toLogString() {
    var res = "|title:$title|desc:$desc|ext:$ext";
    return res;
  }
}
