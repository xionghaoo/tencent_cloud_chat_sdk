// ignore_for_file: unnecessary_cast, unused_field

import 'dart:convert';

import 'package:tencent_cloud_chat_sdk/enum/V2TimFriendshipListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/friend_application_type_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/friend_response_type_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/friend_type_enum.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_follow_type_check_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_user_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_follow_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_follow_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_application_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_check_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_group.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_search_param.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_official_account_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_cloud_chat_sdk_platform_interface.dart';

///关系链接口，包含了好友的添加和删除，黑名单的添加和删除等逻辑
///
///[setFriendListener]设置关系链监听器
///
///[getFriendList]获取好友列表
///
///[getFriendsInfo]获取指定好友资料
///
///[setFriendInfo]设置指定好友资料
///
///[addFriend]添加好友
///
///[deleteFromFriendList]删除好友
///
///[checkFriend]检查指定用户的好友关系
///
///[getFriendApplicationList]获取好友申请列表
///
///[acceptFriendApplication]同意好友申请
///
///[refuseFriendApplication]拒绝好友申请
///
///[deleteFriendApplication]删除好友申请
///
///[setFriendApplicationRead]设置好友申请已读
///
///[addToBlackList]添加用户到黑名单
///
///[deleteFromBlackList]把用户从黑名单中删除
///
///[getBlackList]获取黑名单列表
///
///[createFriendGroup]新建好友分组
///
///[getFriendGroups]获取分组信息
///
///[deleteFriendGroup]删除好友分组
///
///[renameFriendGroup]修改好友分组的名称
///
///[addFriendsToFriendGroup]添加好友到一个好友分组
///
///[deleteFriendsFromFriendGroup]从好友分组中删除好友
///
///{@category Manager}
///
class V2TIMFriendshipManager {
  ///设置关系链监听器
  ///
  Future<void> setFriendListener({
    required V2TimFriendshipListener listener,
  }) {
    return TencentCloudChatSdkPlatform.instance
        .setFriendListener(listener: listener);
  }

  Future<void> removeFriendListener({
    V2TimFriendshipListener? listener,
  }) {
    return TencentCloudChatSdkPlatform.instance.removeFriendListener(
      listener: listener,
    );
  }

  Future<void> addFriendListener({
    required V2TimFriendshipListener listener,
  }) {
    return TencentCloudChatSdkPlatform.instance
        .addFriendListener(listener: listener);
  }

  ///获取好友列表
  ///
  Future<V2TimValueCallback<List<V2TimFriendInfo>>> getFriendList() async {
    return TencentCloudChatSdkPlatform.instance.getFriendList();
  }

  /// 获取指定好友资料
  ///
  /// 参数
  ///
  /// ```
  /// userIDList	好友 userID 列表
  /// ID 建议一次最大 100 个，因为数量过多可能会导致数据包太大被后台拒绝，后台限制数据包最大为 1M。
  /// ```
  ///
  Future<V2TimValueCallback<List<V2TimFriendInfoResult>>> getFriendsInfo({
    required List<String> userIDList,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .getFriendsInfo(userIDList: userIDList);
  }

  /// 设置指定好友资料
  ///
  Future<V2TimCallback> setFriendInfo({
    required String userID,
    String? friendRemark,
    Map<String, String>? friendCustomInfo,
  }) async {
    return TencentCloudChatSdkPlatform.instance.setFriendInfo(
        userID: userID,
        friendRemark: friendRemark,
        friendCustomInfo: friendCustomInfo);
  }

  /// 添加好友
  ///
  Future<V2TimValueCallback<V2TimFriendOperationResult>> addFriend({
    required String userID,
    String? remark,
    String? friendGroup,
    String? addWording,
    String? addSource,
    required FriendTypeEnum addType,
  }) async {
    return TencentCloudChatSdkPlatform.instance.addFriend(
      userID: userID,
      remark: remark,
      friendGroup: friendGroup,
      addWording: addWording,
      addSource: addSource,
      addType: addType.index,
    );
  }

  ///   删除好友
  ///
  /// 参数
  ///
  /// ```
  /// userIDList	要删除的好友 userID 列表
  /// ID 建议一次最大 100 个，因为数量过多可能会导致数据包太大被后台拒绝，后台限制数据包最大为 1M。
  /// deleteType	删除类型
  /// ```
  ///
  /// ```
  /// FriendType.V2TIM_FRIEND_TYPE_SINGLE：单向好友
  /// FriendType.V2TIM_FRIEND_TYPE_BOTH：双向好友
  /// ```
  ///
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      deleteFromFriendList({
    required List<String> userIDList,
    required FriendTypeEnum deleteType,
  }) async {
    return TencentCloudChatSdkPlatform.instance.deleteFromFriendList(
      userIDList: userIDList,
      deleteType: deleteType.index,
    );
  }

  /// 检查指定用户的好友关系
  ///
  /// 参数
  ///
  /// ```
  /// checkType	检查类型
  /// ```
  ///
  /// ```
  /// FriendType.V2TIM_FRIEND_TYPE_SINGLE：单向好友
  /// FriendType.V2TIM_FRIEND_TYPE_BOTH：双向好友
  /// ```
  ///
  Future<V2TimValueCallback<List<V2TimFriendCheckResult>>> checkFriend({
    required List<String> userIDList,
    required FriendTypeEnum checkType,
  }) async {
    return TencentCloudChatSdkPlatform.instance.checkFriend(
      userIDList: userIDList,
      checkType: checkType.index,
    );
  }

  ///获取好友申请列表
  ///
  Future<V2TimValueCallback<V2TimFriendApplicationResult>>
      getFriendApplicationList() async {
    return TencentCloudChatSdkPlatform.instance.getFriendApplicationList();
  }

  /// 同意好友申请
  ///
  /// 参数
  ///
  /// ```
  /// application	好友申请信息，getFriendApplicationList 成功后会返回
  /// responseType	建立单向/双向好友关系
  /// ```
  ///
  /// ```
  /// FriendApplicationType.V2TIM_FRIEND_ACCEPT_AGREE：同意添加单向好友
  /// FriendApplicationType.V2TIM_FRIEND_ACCEPT_AGREE_AND_ADD：同意并添加为双向好友
  /// ```
  ///
  Future<V2TimValueCallback<V2TimFriendOperationResult>>
      acceptFriendApplication({
    required FriendResponseTypeEnum responseType,
    required FriendApplicationTypeEnum type,
    required String userID,
  }) async {
    return TencentCloudChatSdkPlatform.instance.acceptFriendApplication(
        responseType: responseType.index, type: type.index, userID: userID);
  }

  /// 拒绝好友申请
  ///
  /// 参数
  ///
  /// ```
  /// application	好友申请信息，getFriendApplicationList 成功后会返回
  /// ```
  ///
  Future<V2TimValueCallback<V2TimFriendOperationResult>>
      refuseFriendApplication({
    required FriendApplicationTypeEnum type,
    required String userID,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .refuseFriendApplication(type: type.index, userID: userID);
  }

  /// 删除好友申请
  ///
  /// 参数
  ///
  /// ```
  /// application	好友申请信息，getFriendApplicationList 成功后会返回
  /// ```
  ///
  Future<V2TimCallback> deleteFriendApplication({
    required FriendApplicationTypeEnum type,
    required String userID,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .deleteFriendApplication(type: type.index, userID: userID);
  }

  ///设置好友申请已读
  ///
  Future<V2TimCallback> setFriendApplicationRead() async {
    return TencentCloudChatSdkPlatform.instance.setFriendApplicationRead();
  }

  ///添加用户到黑名单
  ///
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>> addToBlackList({
    required List<String> userIDList,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .addToBlackList(userIDList: userIDList);
  }

  ///把用户从黑名单中删除
  ///
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      deleteFromBlackList({
    required List<String> userIDList,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .deleteFromBlackList(userIDList: userIDList);
  }

  ///获取黑名单列表
  ///
  Future<V2TimValueCallback<List<V2TimFriendInfo>>> getBlackList() async {
    return TencentCloudChatSdkPlatform.instance.getBlackList();
  }

  ///新建好友分组
  ///
  ///参数
  ///
  ///```
  /// groupName	分组名称
  /// userIDList	要添加到分组中的好友 userID 列表
  /// ```
  ///
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      createFriendGroup({
    required String groupName,
    List<String>? userIDList,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .createFriendGroup(groupName: groupName, userIDList: userIDList);
  }

  /// 获取分组信息
  ///
  /// 参数
  ///
  /// ```
  /// groupNameList	要获取信息的好友分组名称列表,传入 null 获得所有分组信息
  /// ```
  ///
  Future<V2TimValueCallback<List<V2TimFriendGroup>>> getFriendGroups({
    List<String>? groupNameList,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .getFriendGroups(groupNameList: groupNameList);
  }

  ///删除好友分组
  ///
  Future<V2TimCallback> deleteFriendGroup({
    required List<String> groupNameList,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .deleteFriendGroup(groupNameList: groupNameList);
  }

  /// 修改好友分组的名称
  ///
  /// 参数
  ///
  /// ```
  /// oldName	旧的分组名称
  /// newName	新的分组名称
  /// callback	回调
  /// ```
  ///
  Future<V2TimCallback> renameFriendGroup({
    required String oldName,
    required String newName,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .renameFriendGroup(oldName: oldName, newName: newName);
  }

  ///添加好友到一个好友分组
  ///
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      addFriendsToFriendGroup({
    required String groupName,
    required List<String> userIDList,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .addFriendsToFriendGroup(groupName: groupName, userIDList: userIDList);
  }

  ///从好友分组中删除好友
  ///
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      deleteFriendsFromFriendGroup({
    required String groupName,
    required List<String> userIDList,
  }) async {
    return TencentCloudChatSdkPlatform.instance.deleteFriendsFromFriendGroup(
        groupName: groupName, userIDList: userIDList);
  }

  /// 搜索好友
  ///
  /// 接口返回本地存储的用户资料，可以根据 V2TIMFriendInfoResult 中的 relation 来判断是否为好友。
  ///
  Future<V2TimValueCallback<List<V2TimFriendInfoResult>>> searchFriends({
    required V2TimFriendSearchParam searchParam,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .searchFriends(searchParam: searchParam);
  }

  /// 订阅公众号
  ///
  Future<V2TimCallback> subscribeOfficialAccount({
    required String officialAccountID,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .subscribeOfficialAccount(officialAccountID: officialAccountID);
  }

  /// 取消订阅公众号
  ///
  Future<V2TimCallback> unsubscribeOfficialAccount({
    required String officialAccountID,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .unsubscribeOfficialAccount(officialAccountID: officialAccountID);
  }

  /// 获取公众号列表
  ///
  Future<V2TimValueCallback<List<V2TimOfficialAccountInfoResult>>>
      getOfficialAccountsInfo({
    required List<String> officialAccountIDList,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .getOfficialAccountsInfo(officialAccountIDList: officialAccountIDList);
  }

  /// 关注用户
  ///
  Future<V2TimValueCallback<List<V2TimFollowOperationResult>>> followUser({
    required List<String> userIDList,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .followUser(userIDList: userIDList);
  }

  /// 取消关注用户
  ///
  Future<V2TimValueCallback<List<V2TimFollowOperationResult>>> unfollowUser({
    required List<String> userIDList,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .unfollowUser(userIDList: userIDList);
  }

  /// 获取我的关注列表
  ///
  Future<V2TimValueCallback<V2TimUserInfoResult>> getMyFollowingList({
    required String nextCursor,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .getMyFollowingList(nextCursor: nextCursor);
  }

  /// 获取关注我的列表
  ///
  Future<V2TimValueCallback<V2TimUserInfoResult>> getMyFollowersList({
    required String nextCursor,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .getMyFollowersList(nextCursor: nextCursor);
  }

  /// 获取我的互关列表
  ///
  Future<V2TimValueCallback<V2TimUserInfoResult>> getMutualFollowersList({
    required String nextCursor,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .getMutualFollowersList(nextCursor: nextCursor);
  }

  /// 获取指定用户的 关注/粉丝/互关 数量信息
  ///
  Future<V2TimValueCallback<List<V2TimFollowInfo>>> getUserFollowInfo({
    required List<String> userIDList,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .getUserFollowInfo(userIDList: userIDList);
  }

  /// 检查指定用户的关注类型
  ///
  Future<V2TimValueCallback<List<V2TimFollowTypeCheckResult>>> checkFollowType({
    required List<String> userIDList,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .checkFollowType(userIDList: userIDList);
  }

  ///@nodoc
  Map buildParam(Map param) {
    param["TIMManagerName"] = "friendshipManager";
    return param;
  }

  ///@nodoc
  formatJson(jsonSrc) {
    return json.decode(json.encode(jsonSrc));
  }
}
