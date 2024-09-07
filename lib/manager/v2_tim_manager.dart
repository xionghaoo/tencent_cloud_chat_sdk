// ignore_for_file: unused_element, deprecated_member_use_from_same_package, unused_field

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimCommunityListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimGroupListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSimpleMsgListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimUIKitListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/callbacks.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/message_priority_enum.dart';
import 'package:tencent_cloud_chat_sdk/manager/v2_tim_community_manager.dart';
import 'package:tencent_cloud_chat_sdk/manager/v2_tim_conversation_manager.dart';
import 'package:tencent_cloud_chat_sdk/manager/v2_tim_friendship_manager.dart';
import 'package:tencent_cloud_chat_sdk/manager/v2_tim_group_manager.dart';
import 'package:tencent_cloud_chat_sdk/manager/v2_tim_message_manager.dart';
import 'package:tencent_cloud_chat_sdk/manager/v2_tim_offline_push_manager.dart';
import 'package:tencent_cloud_chat_sdk/manager/v2_tim_signaling_manager.dart';
import 'package:tencent_cloud_chat_sdk/enum/v2_tim_plugins.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_user_status.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_user_full_info.dart';
import 'package:tencent_cloud_chat_sdk/tencent_cloud_chat_sdk_platform_interface.dart';
import 'package:tencent_cloud_chat_sdk/utils/const.dart';

/// IM SDK 主核心类，负责 IM SDK 的初始化、登录、消息收发，建群退群等功能。
///
///[initSDK] 初始化 SDK
///
///[unInitSDK] 反初始化 SDK
///
///[login] 登录
///
///[logout] 登出
///
///[getLoginUser] 获取登录用户
///
///[getLoginStatus] 获取登录状态
///
///[addSimpleMsgListener] 设置基本消息（文本消息和自定义消息）的事件监听器
///
///[removeSimpleMsgListener] 移除基本消息（文本消息和自定义消息）的事件监听器
///
///[sendC2CTextMessage] 发送单聊普通文本消息（最大支持 8KB）
///
///[sendC2CCustomMessage] 发送单聊自定义（信令）消息（最大支持 8KB）
///
///[sendGroupTextMessage] 发送群聊普通文本消息（最大支持 8KB）
///
///[sendGroupCustomMessage] 发送群聊自定义（信令）消息（最大支持 8KB）
///
///[setGroupListener] 设置群组监听器
///
///[createGroup] 创建群组（已弃用）
///
///[joinGroup] 加入群组
///
///[quitGroup] 退出群组
///
///{@category Manager}
///
class V2TIMManager {
  static Map<String, String> currentLoginInfo = {};
  static bool addNativeCallback = false;
  V2TIMMessageManager v2TIMMessageManager = V2TIMMessageManager();
  V2TIMConversationManager v2ConversationManager = V2TIMConversationManager();
  V2TIMGroupManager v2TIMGroupManager = V2TIMGroupManager();
  V2TIMOfflinePushManager v2TIMOfflinePushManager = V2TIMOfflinePushManager();
  V2TIMFriendshipManager v2TIMFriendshipManager = V2TIMFriendshipManager();
  V2TIMSignalingManager v2timSignalingManager = V2TIMSignalingManager();

  V2TIMManager() {
    if (!addNativeCallback) {
      TencentCloudChatSdkPlatform.instance.addNativeCallback();
      addNativeCallback = true;
    }
  }
  Future<V2TimValueCallback<bool>> initSDK({
    required int sdkAppID,
    required LogLevelEnum loglevel,
    required V2TimSDKListener listener,
    bool? showImLog = true,
    List<V2TimPlugins>? plugins,
  }) {
    int platform = _getUiPlatform(StackTrace.current.toString());
    currentLoginInfo["a"] = sdkAppID.toString();
    return TencentCloudChatSdkPlatform.instance.initSDK(
      sdkAppID: sdkAppID,
      loglevel: loglevel.index,
      listener: listener,
      uiPlatform: platform,
      showImLog: showImLog,
      plugins: plugins ?? [],
    );
  }

  Future<void> emitUIKitEvent(UIKitEvent event) async {
    return TencentCloudChatSdkPlatform.instance.emitUIKitEvent(event);
  }

  Future<void> emitPluginEvent(PluginEvent event) async {
    return TencentCloudChatSdkPlatform.instance.emitPluginEvent(event);
  }

  String addUIKitListener({
    required V2TimUIKitListener listener,
  }) {
    return TencentCloudChatSdkPlatform.instance.addUIKitListener(
      listener: listener,
    );
  }

  void emitUIKitListener({
    required Map<String, dynamic> data,
  }) {
    TencentCloudChatSdkPlatform.instance.emitUIKitListener(
      data: data,
    );
  }

  void removeUIKitListener({
    String? uuid,
  }) {
    TencentCloudChatSdkPlatform.instance.removeUIKitListener(
      uuid: uuid,
    );
  }

  ///@nodoc
  int _getUiPlatform(String trace) {
    int platfrom = TencentIMSDKCONST.Flutter;
    if (trace.contains(TencentIMSDKCONST.FlutterUIKitPkg) ||
        trace.contains(TencentIMSDKCONST.FlutterUIKitPkgLatest)) {
      platfrom = TencentIMSDKCONST.FlutterUIKit;
    } else if (trace.contains(TencentIMSDKCONST.FlutterPlugin_35_pkg)) {
      platfrom = TencentIMSDKCONST.FlutterUIKitPlus;
    }
    return platfrom;
  }

  ///反初始化 SDK
  ///
  Future<V2TimCallback> unInitSDK() async {
    await TencentCloudChatSdkPlatform.instance.removeAdvancedMsgListener();
    await TencentCloudChatSdkPlatform.instance.removeConversationListener();
    await TencentCloudChatSdkPlatform.instance.removeFriendListener();
    await TencentCloudChatSdkPlatform.instance.removeGroupListener();
    await TencentCloudChatSdkPlatform.instance.removeSimpleMsgListener();
    await TencentCloudChatSdkPlatform.instance.removeSignalingListener();
    return TencentCloudChatSdkPlatform.instance.unInitSDK();
  }

  /// 获取版本号
  ///
  Future<V2TimValueCallback<String>> getVersion() {
    return TencentCloudChatSdkPlatform.instance.getVersion();
  }

  /// 获取服务器当前时间
  ///
  /// 注意： web不支持该接口
  ///
  Future<V2TimValueCallback<int>> getServerTime() {
    return TencentCloudChatSdkPlatform.instance.getServerTime();
  }

  /// 登录
  ///
  /// 参数
  ///
  /// ```
  /// @required String userID,
  /// @required String userSig,
  /// ```
  ///
  /// ```
  /// 登录需要设置用户名 userID 和用户签名 userSig，userSig 生成请参考 UserSig 后台 API。
  /// ```
  ///
  /// 注意
  ///
  /// ```
  /// 登陆时票据过期：login 函数的回调会返回 ERR_USER_SIG_EXPIRED：6206 错误码，此时生成新的 userSig 重新登录。
  /// 在线时票据过期：用户在线期间也可能收到 V2TIMListener -> onUserSigExpired 回调，此时也是需要您生成新的 userSig 并重新登录。
  /// 在线时被踢下线：用户在线情况下被踢，SDK 会通过 V2TIMListener -> onKickedOffline 回调通知给您，此时可以 UI 提示用户，并再次调用 login() 重新登录。
  /// ```
  Future<V2TimCallback> login({
    required String userID,
    required String userSig,
  }) async {
    V2TimCallback res = await TencentCloudChatSdkPlatform.instance
        .login(userID: userID, userSig: userSig);
    if (res.code == 0) {
      currentLoginInfo["u"] = userID;
      currentLoginInfo["s"] = userSig;
    }
    return res;
  }

  /// 登出
  ///
  ///```
  /// 退出登录，如果切换账号，需要 logout 回调成功或者失败后才能再次 login，否则 login 可能会失败。
  ///```
  Future<V2TimCallback> logout() async {
    return TencentCloudChatSdkPlatform.instance.logout();
  }

  /// 获取登录用户
  ///
  Future<V2TimValueCallback<String>> getLoginUser() async {
    return TencentCloudChatSdkPlatform.instance.getLoginUser();
  }

  /// 获取登录状态
  ///
  ///```
  /// 如果用户已经处于已登录和登录中状态，请勿再频繁调用登录接口登录。
  /// ```
  ///
  /// 返回
  ///
  ///```
  /// 登录状态
  /// V2TIM_STATUS_LOGINED 已登录
  /// V2TIM_STATUS_LOGINING 登录中
  /// V2TIM_STATUS_LOGOUT 无登录
  /// ```
  ///
  /// 注意： web不支持该接口
  ///
  Future<V2TimValueCallback<int>> getLoginStatus() async {
    return TencentCloudChatSdkPlatform.instance.getLoginStatus();
  }

  /// 发送单聊普通文本消息（最大支持 8KB）（自3.6.0开始弃用，请使用MessageManager下的高级收发消息）
  ///
  /// ```
  /// 文本消息支持云端的脏词过滤，如果用户发送的消息中有敏感词，callback 回调将会返回 80001 错误码。
  /// ```
  /// 返回
  ///
  /// ```
  /// 返回消息的唯一标识 ID
  /// ```
  /// 注意
  ///
  /// ```
  /// 该接口发送的消息默认会推送（前提是在 V2TIMOfflinePushManager 开启了推送），如果需要自定义推送（标题和内容），请调用 V2TIMMessageManager.sendMessage 接口。
  /// ```
  @Deprecated('简单消息自3.6.0开始弃用，请使用messageManager下的高级收发消息,此接口将在以后版本中被删除')
  Future<V2TimValueCallback<V2TimMessage>> sendC2CTextMessage({
    required String text,
    required String userID,
  }) async {
    printWarning(
        "tencent_im_sdk_plugin：简单消息接口自3.6.0开始弃用，请使用messageManager下的高级收发消息,此接口将在以后版本中被删除）");
    return TencentCloudChatSdkPlatform.instance.sendC2CTextMessage(
      text: text,
      userID: userID,
    );
  }

  /// 发送单聊自定义（信令）消息（最大支持 8KB）（自3.6.0开始弃用，请使用MessageManager下的高级收发消息）
  ///
  /// ```
  /// 自定义消息本质就是一端二进制 buffer，您可以在其上自由组织自己的消息格式（常用于发送信令），但是自定义消息不支持云端敏感词过滤。
  /// ```
  ///
  /// 返回
  ///
  /// ```
  /// 返回消息的唯一标识 ID
  /// ```
  ///
  /// 注意
  /// ```
  /// 该接口发送的消息默认不会推送，如果需要推送，请调用 V2TIMMessageManager.sendMessage 接口。
  /// ```
  @Deprecated('简单消息自3.6.0开始弃用，请使用messageManager下的高级收发消息,此接口将在以后版本中被删除')
  Future<V2TimValueCallback<V2TimMessage>> sendC2CCustomMessage({
    required String customData,
    required String userID,
  }) async {
    printWarning("简单消息自3.6.0开始弃用，请使用messageManager下的高级收发消息,此接口将在以后版本中被删除）");
    return TencentCloudChatSdkPlatform.instance.sendC2CCustomMessage(
      customData: customData,
      userID: userID,
    );
  }

  /// 发送群聊普通文本消息（最大支持 8KB）（自3.6.0开始弃用，请使用MessageManager下的高级收发消息）
  ///
  /// 参数
  ///
  /// ```
  /// priority	设置消息的优先级，我们没有办法所有消息都能 100% 送达每一个用户，但高优先级的消息会有更高的送达成功率。
  /// V2TIMMessage.V2TIM_PRIORITY_HIGH = 1：云端会优先传输，适用于在群里发送重要消息，比如主播发送的文本消息等。
  /// V2TIMMessage.V2TIM_PRIORITY_NORMAL = 2：云端按默认优先级传输，适用于在群里发送非重要消息，比如观众发送的弹幕消息等。
  /// ```
  ///
  /// 返回
  ///
  /// ```
  /// 返回消息的唯一标识 ID
  /// ```
  ///
  /// 注意
  ///
  /// ```
  /// 该接口发送的消息默认会推送（前提是在 V2TIMOfflinePushManager 开启了推送），如果需要自定义推送（标题和内容），请调用 V2TIMMessageManager.sendMessage 接口。
  /// ```
  @Deprecated('简单消息自3.6.0开始弃用，请使用messageManager下的高级收发消息,此接口将在以后版本中被删除')
  Future<V2TimValueCallback<V2TimMessage>> sendGroupTextMessage({
    required String text,
    required String groupID,
    int priority = 0,
  }) async {
    printWarning("简单消息自3.6.0开始弃用，请使用messageManager下的高级收发消息,此接口将在以后版本中被删除）");
    return TencentCloudChatSdkPlatform.instance
        .sendGroupTextMessage(text: text, groupID: groupID, priority: priority);
  }

  /// 发送群聊自定义（信令）消息（最大支持 8KB）（自3.6.0开始弃用，请使用MessageManager下的高级收发消息）
  ///
  /// 参数
  ///
  /// ```
  /// priority	设置消息的优先级，我们没有办法所有消息都能 100% 送达每一个用户，但高优先级的消息会有更高的送达成功率。
  /// V2TIMMessage.V2TIM_PRIORITY_HIGH = 1：云端会优先传输，适用于在群里发送重要信令，比如连麦邀请，PK邀请、礼物赠送等关键性信令。
  /// V2TIMMessage.V2TIM_PRIORITY_NORMAL = 2：云端按默认优先级传输，适用于在群里发送非重要信令，比如观众的点赞提醒等等。
  /// ```
  /// 返回
  ///
  /// ```
  /// 返回消息的唯一标识 ID
  /// ```
  ///
  /// 注意
  ///
  /// ```
  /// 该接口发送的消息默认不会推送，如果需要推送，请调用 V2TIMMessageManager.sendMessage 接口。
  /// ```
  @Deprecated('简单消息自3.6.0开始弃用，请使用messageManager下的高级收发消息,此接口将在以后版本中被删除')
  Future<V2TimValueCallback<V2TimMessage>> sendGroupCustomMessage({
    required String customData,
    required String groupID,
    MessagePriorityEnum? priority = MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
  }) async {
    printWarning("简单消息自3.6.0开始弃用，请使用messageManager下的高级收发消息,此接口将在以后版本中被删除）");
    return TencentCloudChatSdkPlatform.instance.sendGroupCustomMessage(
      customData: customData,
      groupID: groupID,
      priority: priority!.index,
    );
  }

  /// 创建群组
  ///
  ///参数
  ///```
  /// groupType	群类型，我们为您预定义好了四种常用的群类型，您也可以在控制台定义自己需要的群类型：
  ///
  ///   "Work" ：工作群，成员上限 200 人，不支持由用户主动加入，需要他人邀请入群，适合用于类似微信中随意组建的工作群（对应老版本的 Private 群）。
  ///
  ///   "Public" ：公开群，成员上限 2000 人，任何人都可以申请加群，但加群需群主或管理员审批，适合用于类似 QQ 中由群主管理的兴趣群。
  ///
  ///   "Meeting" ：会议群，成员上限 6000 人，任何人都可以自由进出，且加群无需被审批，适合用于视频会议和在线培训等场景（对应老版本的 ChatRoom 群）。
  ///
  ///   "AVChatRoom" ：直播群，人数无上限，任何人都可以自由进出，消息吞吐量大，适合用作直播场景中的高并发弹幕聊天室。
  ///
  /// groupID	自定义群组 ID，可以传 null。传 null 时系统会自动分配 groupID，并通过 callback 返回。
  ///
  /// groupName	群名称，不能为 null。
  ///```
  /// 注意
  ///
  ///```
  /// 不支持在同一个 SDKAPPID 下创建两个相同 groupID 的群
  /// ```
  @Deprecated('简单创建群组自3.6.0开始弃用，请使用groupManager下的高级创建群组,此接口将在以后版本中被删除')
  Future<V2TimValueCallback<String>> createGroup({
    required String groupType,
    required String groupName,
    String? groupID,
  }) async {
    return TencentCloudChatSdkPlatform.instance.createGroup(
        groupType: groupType, groupName: groupName, groupID: groupID);
  }

  /// 加入群组
  ///
  /// 注意
  ///
  /// ```
  /// 工作群（Work）：不能主动入群，只能通过群成员调用 V2TIMManager.getGroupManager().inviteUserToGroup() 接口邀请入群。
  /// 公开群（Public）：申请入群后，需要管理员审批，管理员在收到 V2TIMGroupListener -> onReceiveJoinApplication 回调后调用 V2TIMManager.getGroupManager().getGroupApplicationList() 接口处理加群请求。
  /// 其他群：可以直接入群。
  /// 注意：当在web端时，加入直播群时groupType字段必填
  /// ```
  Future<V2TimCallback> joinGroup({
    required String groupID,
    required String message,
    String? groupType,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .joinGroup(groupID: groupID, message: message, groupType: groupType);
  }

  /// 退出群组
  ///
  /// 注意
  ///
  /// ```
  /// 在公开群（Public）、会议（Meeting）和直播群（AVChatRoom）中，群主是不可以退群的，群主只能调用 dismissGroup 解散群组。
  /// ```
  Future<V2TimCallback> quitGroup({
    required String groupID,
  }) async {
    return TencentCloudChatSdkPlatform.instance.quitGroup(groupID: groupID);
  }

  /// 解散群组
  ///
  /// 注意
  ///
  /// ```
  /// Work：任何人都无法解散群组。
  /// 其他群：群主可以解散群组。
  /// ```
  Future<V2TimCallback> dismissGroup({
    required String groupID,
  }) async {
    return TencentCloudChatSdkPlatform.instance.dismissGroup(groupID: groupID);
  }

  /// 获取用户资料
  ///
  /// 注意
  ///
  /// ```
  /// 获取自己的资料，传入自己的 ID 即可。
  /// userIDList 建议一次最大 100 个，因为数量过多可能会导致数据包太大被后台拒绝，后台限制数据包最大为 1M。
  /// ```
  Future<V2TimValueCallback<List<V2TimUserFullInfo>>> getUsersInfo({
    required List<String> userIDList,
  }) async {
    return TencentCloudChatSdkPlatform.instance.getUsersInfo(
      userIDList: userIDList,
    );
  }

  /// 修改个人资料
  ///
  Future<V2TimCallback> setSelfInfo({
    required V2TimUserFullInfo userFullInfo,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .setSelfInfo(userFullInfo: userFullInfo);
  }

  /// 实验性 API 接口
  ///
  /// 参数
  /// api	接口名称
  /// param	接口参数
  /// 注意
  /// 该接口提供一些实验性功能
  ///
  /// 注意：web不支持该接口
  ///
  Future<V2TimValueCallback<Object>> callExperimentalAPI({
    required String api,
    Object? param,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .callExperimentalAPI(api: api, param: param);
  }

  /// 高级消息功能入口
  ///
  /// 返回
  ///
  /// ```
  /// 高级消息管理类实例
  /// ```
  V2TIMMessageManager getMessageManager() {
    return V2TIMMessageManager();
  }

  /// 高级群组功能入口
  ///
  /// 返回
  ///
  /// ```
  /// 高级群组管理类实例
  /// ```
  V2TIMGroupManager getGroupManager() {
    return V2TIMGroupManager();
  }

  /// 会话功能入口
  ///
  /// 返回
  ///
  /// ```
  /// 会话管理类实例
  /// ```
  V2TIMConversationManager getConversationManager() {
    return V2TIMConversationManager();
  }

  V2TIMCommunityManager getCommunityManager(){
    return V2TIMCommunityManager();
  }

  /// 关系链功能入口
  ///
  /// 返回
  ///
  /// ```
  /// 关系链管理类实例
  /// ```
  V2TIMFriendshipManager getFriendshipManager() {
    return V2TIMFriendshipManager();
  }

  /// 离线推送功能入口
  ///
  /// 返回
  ///
  /// ```
  /// 离线推送功能类实例
  /// ```
  V2TIMOfflinePushManager getOfflinePushManager() {
    return V2TIMOfflinePushManager();
  }

  /// 信令入口
  ///
  /// 返回
  ///
  /// ```
  /// 信令管理类实例
  /// ```
  V2TIMSignalingManager getSignalingManager() {
    return V2TIMSignalingManager();
  }

  /// 设置基本消息（文本消息和自定义消息）的事件监听器
  ///
  /// 注意
  ///
  /// ```
  /// 图片消息、视频消息、语音消息等高级消息的监听，请参考: V2TIMMessageManager.addAdvancedMsgListener(V2TIMAdvancedMsgListener) 。
  /// ```
  @Deprecated('简单消息自3.6.0开始弃用，请使用messageManager下的高级收发消息,此接口将在以后版本中被删除')
  Future<String> addSimpleMsgListener({
    required V2TimSimpleMsgListener listener,
  }) {
    return TencentCloudChatSdkPlatform.instance
        .addSimpleMsgListener(listener: listener);
  }

  /// 移除基本消息（文本消息和自定义消息）的事件监听器
  ///
  /// 如果传入listener，会移除指定listener的事件监听器。如果未传入listener会移除所有addSimpleMsgListener的事件监听器。
  ///
  @Deprecated('简单消息自3.6.0开始弃用，请使用messageManager下的高级收发消息,此接口将在以后版本中被删除')
  Future<void> removeSimpleMsgListener({
    V2TimSimpleMsgListener? listener,
    String? uuid,
  }) {
    return TencentCloudChatSdkPlatform.instance.removeSimpleMsgListener(
      listener: listener,
      uuid: uuid,
    );
  }

  /// 设置群组监听器
  ///
  /// 在web端时，不支持onQuitFromGroup回调
  ///
  Future<void> setGroupListener({
    required V2TimGroupListener listener,
  }) {
    return TencentCloudChatSdkPlatform.instance
        .setGroupListener(listener: listener);
  }

  /// 添加群组监听器
  ///
  /// 在web端时，不支持onQuitFromGroup回调
  ///
  Future<void> addGroupListener({
    required V2TimGroupListener listener,
  }) {
    return TencentCloudChatSdkPlatform.instance
        .addGroupListener(listener: listener);
  }

  /// 移除群组监听器
  ///
  ///
  Future<void> removeGroupListener({
    V2TimGroupListener? listener,
  }) {
    return TencentCloudChatSdkPlatform.instance
        .removeGroupListener(listener: listener);
  }

  /// 能力位检测
  ///
  ///
  Future<V2TimValueCallback<int>> checkAbility() {
    return TencentCloudChatSdkPlatform.instance.checkAbility();
  }

  /// 获取用户在线状态
  /// 注意：4.0.3版本开始支持，web不支持
  ///
  ///
  Future<V2TimValueCallback<List<V2TimUserStatus>>> getUserStatus({
    required List<String> userIDList,
  }) {
    return TencentCloudChatSdkPlatform.instance
        .getUserStatus(userIDList: userIDList);
  }

  /// 设置当前登录用户在线状态
  /// 注意：4.0.3版本开始支持，web不支持
  ///
  ///
  Future<V2TimCallback> setSelfStatus({
    required String status,
  }) {
    return TencentCloudChatSdkPlatform.instance.setSelfStatus(status: status);
  }

  /// 订阅用户状态
  /// 注意：4.0.8版本开始支持，web不支持
  /// 当成功订阅用户状态后，当对方的状态（包含在线状态、自定义状态）发生变更后，您可以监听 @onUserStatusChanged 回调来感知
  /// 如果您需要订阅好友列表的状态，您只需要在控制台上打开开关即可，无需调用该接口
  /// 该接口不支持订阅自己，您可以通过监听 @onUserStatusChanged 回调来感知自身的自定义状态的变更
  /// 订阅列表有个数限制，超过限制后，会自动淘汰最先订阅的用户
  /// 该功能为 IM 旗舰版功能，购买旗舰版套餐包后可使用，详见价格说明。
  ///
  ///
  Future<V2TimCallback> subscribeUserStatus({
    required List<String> userIDList,
  }) {
    return TencentCloudChatSdkPlatform.instance
        .subscribeUserStatus(userIDList: userIDList);
  }

  /// 取消订阅用户状态
  /// 注意：4.0.8版本开始支持，web不支持
  /// 当 userIDList 为空或者 nil 时，取消当前所有的订阅
  /// 该功能为 IM 旗舰版功能，购买旗舰版套餐包后可使用，详见价格说明。
  Future<V2TimCallback> unsubscribeUserStatus({
    required List<String> userIDList,
  }) {
    return TencentCloudChatSdkPlatform.instance
        .unsubscribeUserStatus(userIDList: userIDList);
  }

  /// 设置apns监听
  ///
  Future setAPNSListener() {
    return TencentCloudChatSdkPlatform.instance.setAPNSListener();
  }

  Future<void> uikitTrace({
    required String trace,
  }) async {
    TencentCloudChatSdkPlatform.instance.uikitTrace(trace: trace);
  }

  /// 订阅用户资料，从 6.0.0 版本开始支持
  /// 参数
  /// userIDList	待订阅的用户 ID
  /// 注意
  /// 请注意
  /// 该接口用于订阅陌生人的资料变更事件，订阅成功后，当订阅用户资料发生变更，您可以通过监听 onUserInfoChanged 回调来感知
  /// 订阅列表最多允许订阅 200 个，超过限制后，会自动淘汰最先订阅的用户
  /// 自己的资料变更通知不需要订阅，默认会通过 onSelfInfoUpdated 回调通知给您
  /// 好友的资料变更通知不需要订阅，默认会通过 onFriendInfoChange 回调通知给您
  /// 该功能为 IM 旗舰版功能，购买旗舰版套餐包后可使用，详见价格说明。
  Future<V2TimCallback> subscribeUserInfo({
    required List<String> userIDList,
  }) {
    return TencentCloudChatSdkPlatform.instance
        .subscribeUserInfo(userIDList: userIDList);
  }

  /// 取消订阅用户资料，从 6.0.0 版本开始支持
  /// 参数
  /// userIDList	需要取消订阅的用户 ID
  /// 注意
  /// 当 userIDList 为空时，取消当前所有的订阅
  /// 该功能为 IM 旗舰版功能，购买旗舰版套餐包后可使用，详见价格说明。
  Future<V2TimCallback> unsubscribeUserInfo({
    required List<String> userIDList,
  }) {
    return TencentCloudChatSdkPlatform.instance
        .unsubscribeUserInfo(userIDList: userIDList);
  }

  Map<String, String> getCurrentLoginInfo() {
    String trace = StackTrace.current.toString();
    if (trace.contains("tencent_cloud_chat_push")) {
      return currentLoginInfo;
    }
    return {};
  }

  ///@nodoc
  formatJson(jsonSrc) {
    return json.decode(json.encode(jsonSrc));
  }

  ///@nodoc
  Map buildParam(Map param) {
    param["TIMManagerName"] = "timManager";
    return param;
  }

  void printWarning(String text) {
    debugPrint('\x1B[33m$text\x1B[0m');
  }
}
