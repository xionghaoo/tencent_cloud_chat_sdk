// ignore_for_file: unused_field

import 'dart:convert';

import 'package:tencent_cloud_chat_sdk/enum/group_add_opt_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/group_application_type_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/group_member_filter_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/group_member_role_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/group_type.dart';
import 'package:tencent_cloud_chat_sdk/enum/utils.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_application_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member_full_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member_search_param.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member_search_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_search_param.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_topic_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_topic_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_topic_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/tencent_cloud_chat_sdk_platform_interface.dart';

/// 群组高级接口，包含了群组的高级功能，例如群成员邀请、非群成员申请进群等操作接口。
///
///[createGroup]创建自定义群组（高级版本：可以指定初始的群成员）
///
///[getJoinedGroupList]获取当前用户已经加入的群列表
///
///[getGroupsInfo]拉取群资料
///
///[setGroupInfo]修改群资料
///
///[setReceiveMessageOpt]修改群消息接收选项
///
///[initGroupAttributes]初始化群属性，会清空原有的群属性列表
///
///[setGroupAttributes]设置群属性。已有该群属性则更新其 value 值，没有该群属性则添加该属性。
///
///[deleteGroupAttributes]删除指定群属性，keys 传 null 则清空所有群属性。
///
///[getGroupAttributes]获取指定群属性，keys 传 null 则获取所有群属性。
///
///[getGroupMemberList]获取群成员列表
///
///[getGroupMembersInfo]获取指定的群成员资料
///
///[setGroupMemberInfo]修改指定的群成员资料
///
///[muteGroupMember]禁言（只有管理员或群主能够调用）
///
///[inviteUserToGroup]邀请他人入群
///
///[kickGroupMember]踢人
///
///[setGroupMemberRole]切换群成员的角色。
///
///[transferGroupOwner]转让群主
///
///[getGroupApplicationList]获取加群的申请列表
///
///[acceptGroupApplication]同意某一条加群申请
///
///[refuseGroupApplication]拒绝某一条加群申请
///
///[setGroupApplicationRead]标记申请列表为已读
///
///[searchGroupByID] 通过群ID搜索群信息
///
/// {@category Manager}
///
class V2TIMGroupManager {
  ///创建自定义群组（高级版本：可以指定初始的群成员）
  ///
  /// 参数
  ///
  /// ```
  /// info	自定义群组信息，可以设置 groupID | groupType | groupName | notification | introduction | faceURL 字段
  /// memberList	指定初始的群成员（直播群 AVChatRoom 不支持指定初始群成员，memberList 请传 null）
  /// ```
  ///
  /// 注意
  ///
  /// ```
  /// 其他限制请参考V2TIMManager.createGroup注释
  /// isSupportTopic 仅对社群有效
  /// ```
  Future<V2TimValueCallback<String>> createGroup({
    String? groupID,
    required String groupType,
    required String groupName,
    String? notification,
    String? introduction,
    String? faceUrl,
    bool? isAllMuted,
    bool? isSupportTopic = false,
    GroupAddOptTypeEnum? addOpt,
    List<V2TimGroupMember>? memberList,
    GroupAddOptTypeEnum? approveOpt,
    bool? isEnablePermissionGroup,
    int? defaultPermissions,
  }) async {
    // add a default number.
    GroupAddOptTypeEnum addOptDefault = addOpt == null
        ? GroupAddOptTypeEnum.V2TIM_GROUP_ADD_ANY
        : (groupType == GroupType.AVChatRoom
            ? GroupAddOptTypeEnum.V2TIM_GROUP_ADD_ANY
            : addOpt);
    GroupAddOptTypeEnum approveOptDefault = approveOpt == null
        ? GroupAddOptTypeEnum.V2TIM_GROUP_ADD_FORBID
        : (groupType == GroupType.AVChatRoom
            ? GroupAddOptTypeEnum.V2TIM_GROUP_ADD_FORBID
            : approveOpt);
    return TencentCloudChatSdkPlatform.instance.createGroup(
      groupType: groupType,
      groupName: groupName,
      groupID: groupID,
      notification: notification,
      introduction: introduction,
      faceUrl: faceUrl,
      isAllMuted: isAllMuted,
      addOpt: addOptDefault.index,
      memberList: memberList,
      isSupportTopic: isSupportTopic,
      approveOpt: approveOptDefault.index,
      isEnablePermissionGroup: isEnablePermissionGroup,
      defaultPermissions: defaultPermissions,
    );
  }

  /// 获取当前用户已经加入的群列表
  ///
  /// 注意
  ///
  /// ```
  /// 直播群(AVChatRoom) 不支持该 API。
  /// 该接口有频限检测，SDK 限制调用频率为1 秒 10 次，超过限制后会报 ERR_SDK_COMM_API_CALL_FREQUENCY_LIMIT （7008）错误
  /// ```
  Future<V2TimValueCallback<List<V2TimGroupInfo>>> getJoinedGroupList() async {
    return TencentCloudChatSdkPlatform.instance.getJoinedGroupList();
  }

  /// 拉取群资料
  ///
  /// 参数
  ///
  /// ```
  /// groupIDList	群 ID 列表
  /// ```
  Future<V2TimValueCallback<List<V2TimGroupInfoResult>>> getGroupsInfo({
    required List<String> groupIDList,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .getGroupsInfo(groupIDList: groupIDList);
  }

  ///修改群资料
  ///
  ///参数：
  ///[V2TimGroupInfo]  群资料参数
  Future<V2TimCallback> setGroupInfo({
    // required String groupID,
    // String? groupType,
    // String? groupName,
    // String? notification,
    // String? introduction,
    // String? faceUrl,
    // bool? isAllMuted,
    // int? addOpt,
    // Map<String, String>? customInfo,
    required V2TimGroupInfo info,
  }) async {
    return TencentCloudChatSdkPlatform.instance.setGroupInfo(info: info);
  }

  /// 这个接口移到messageManager下面去了，2020-6-4
  /// 修改群消息接收选项
  ///
  /// 参数
  ///
  /// ```
  /// opt	三种类型的消息接收选项： ReceiveMsgOptEnum.V2TIM_GROUP_RECEIVE_MESSAGE：在线正常接收消息，离线时会有厂商的离线推送通知 ReceiveMsgOptEnum.V2TIM_GROUP_NOT_RECEIVE_MESSAGE：不会接收到群消息 ReceiveMsgOptEnum.V2TIM_GROUP_RECEIVE_NOT_NOTIFY_MESSAGE：在线正常接收消息，离线不会有推送通知
  /// ```
  // Future<V2TimCallback> setReceiveMessageOpt({
  //   required String groupID,
  //   required int opt,
  // }) async {
  //   return V2TimCallback.fromJson(
  //     formatJson(
  //       await _channel.invokeMethod(
  //         "setReceiveMessageOpt",
  //         buildParam(
  //           {
  //             "groupID": groupID,
  //             "opt": opt,
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }

  /// 初始化群属性，会清空原有的群属性列表
  ///
  /// 注意
  ///
  /// attributes 的使用限制如下：
  ///
  /// ```
  /// 1、目前只支持 AVChatRoom
  /// 2、key 最多支持16个，长度限制为32字节
  /// 3、value 长度限制为4k
  /// 4、总的 attributes（包括 key 和 value）限制为16k
  /// 5、initGroupAttributes、setGroupAttributes、deleteGroupAttributes 接口合并计算， SDK 限制为5秒10次，超过后回调8511错误码；后台限制1秒5次，超过后返回10049错误码
  /// 6、getGroupAttributes 接口 SDK 限制5秒20次
  /// ```
  Future<V2TimCallback> initGroupAttributes({
    required String groupID,
    required Map<String, String> attributes,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .initGroupAttributes(groupID: groupID, attributes: attributes);
  }

  ///设置群属性。已有该群属性则更新其 value 值，没有该群属性则添加该属性。
  ///
  Future<V2TimCallback> setGroupAttributes({
    required String groupID,
    required Map<String, String> attributes,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .setGroupAttributes(groupID: groupID, attributes: attributes);
  }

  ///删除指定群属性，keys 传 null 则清空所有群属性。
  ///
  Future<V2TimCallback> deleteGroupAttributes({
    required String groupID,
    required List<String> keys,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .deleteGroupAttributes(groupID: groupID, keys: keys);
  }

  ///获取指定群属性，keys 传 null 则获取所有群属性。
  ///
  Future<V2TimValueCallback<Map<String, String>>> getGroupAttributes({
    required String groupID,
    List<String>? keys,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .getGroupAttributes(groupID: groupID, keys: keys);
  }

  ///获取指定群在线人数
  ///请注意：
  ///```
  ///目前只支持：直播群（AVChatRoom）。
  ///该接口有频限检测，SDK 限制调用频率为60秒1次。
  ///```
  Future<V2TimValueCallback<int>> getGroupOnlineMemberCount({
    required String groupID,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .getGroupOnlineMemberCount(groupID: groupID);
  }

  /// 获取群成员列表
  ///
  /// 参数
  ///
  /// ```
  /// filter	指定群成员类型
  /// GroupMemberFilterTypeEnum.V2TIM_GROUP_MEMBER_FILTER_ALL：所有类型
  /// GroupMemberFilterTypeEnum.V2TIM_GROUP_MEMBER_FILTER_OWNER：群主
  /// GroupMemberFilterTypeEnum.V2TIM_GROUP_MEMBER_FILTER_ADMIN：群管理员
  /// GroupMemberFilterTypeEnum.V2TIM_GROUP_MEMBER_FILTER_COMMON：普通群成员
  /// nextSeq	分页拉取标志，第一次拉取填0，回调成功如果 nextSeq 不为零，需要分页，传入再次拉取，直至为0。
  /// ```
  /// 注意
  ///
  /// ```
  /// 直播群（AVChatRoom）的特殊限制：
  /// 不支持管理员角色的拉取，群成员个数最大只支持 31 个（新进来的成员会排前面），程序重启后，请重新加入群组，否则拉取群成员会报 10007 错误码。
  /// 群成员资料信息仅支持 userID | nickName | faceURL | role 字段。
  /// role 字段不支持管理员角色，如果您的业务逻辑依赖于管理员角色，可以使用群自定义字段 groupAttributes 管理该角色。
  /// ```
  /// web 端使用时，count 和 offset 为必传参数. filter 和 nextSeq 不生效
  /// count: 需要拉取的数量。最大值：100，避免回包过大导致请求失败。若传入超过100，则只拉取前100个。
  /// offset: 偏移量，默认从0开始拉取
  ///
  Future<V2TimValueCallback<V2TimGroupMemberInfoResult>> getGroupMemberList({
    required String groupID,
    required GroupMemberFilterTypeEnum filter,
    required String nextSeq,
    int count = 15,
    int offset = 0,
  }) async {
    return TencentCloudChatSdkPlatform.instance.getGroupMemberList(
        groupID: groupID,
        filter: filter.index,
        nextSeq: nextSeq,
        count: count,
        offset: offset);
  }

  ///获取指定的群成员资料
  ///
  Future<V2TimValueCallback<List<V2TimGroupMemberFullInfo>>>
      getGroupMembersInfo({
    required String groupID,
    required List<String> memberList,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .getGroupMembersInfo(groupID: groupID, memberList: memberList);
  }

  ///修改指定的群成员资料
  ///
  Future<V2TimCallback> setGroupMemberInfo({
    required String groupID,
    required String userID,
    String? nameCard,
    Map<String, String>? customInfo,
  }) async {
    return TencentCloudChatSdkPlatform.instance.setGroupMemberInfo(
      groupID: groupID,
      userID: userID,
      nameCard: nameCard,
      customInfo: customInfo,
    );
  }

  ///禁言（只有管理员或群主能够调用）
  ///
  Future<V2TimCallback> muteGroupMember({
    required String groupID,
    required String userID,
    required int seconds,
  }) async {
    return TencentCloudChatSdkPlatform.instance.muteGroupMember(
      groupID: groupID,
      userID: userID,
      seconds: seconds,
    );
  }

  /// 邀请他人入群
  ///
  /// 注意
  ///
  /// ```
  /// 工作群（Work）：群里的任何人都可以邀请其他人进群。
  /// 会议群（Meeting）和公开群（Public）：只有通过rest api 使用 App 管理员身份才可以邀请其他人进群。
  /// 直播群（AVChatRoom）：不支持此功能。
  /// ```
  Future<V2TimValueCallback<List<V2TimGroupMemberOperationResult>>>
      inviteUserToGroup({
    required String groupID,
    required List<String> userList,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .inviteUserToGroup(groupID: groupID, userList: userList);
  }

  /// 踢人
  ///
  /// 注意
  ///
  /// ```
  /// 工作群（Work）：只有群主或 APP 管理员可以踢人。
  /// 公开群（Public）、会议群（Meeting）：群主、管理员和 APP 管理员可以踢人
  /// 直播群（AVChatRoom）：只支持禁言（muteGroupMember），不支持踢人。
  /// ```
  Future<V2TimCallback> kickGroupMember({
    required String groupID,
    required List<String> memberList,
    int? duration,
    String? reason,
  }) async {
    return TencentCloudChatSdkPlatform.instance.kickGroupMember(
      groupID: groupID,
      memberList: memberList,
      duration: duration,
    );
  }

  /// 切换群成员的角色。
  ///
  /// 注意
  ///
  /// ```
  /// 公开群（Public）和会议群（Meeting）：只有群主才能对群成员进行普通成员和管理员之间的角色切换。
  /// 其他群不支持设置群成员角色。
  /// 转让群组请调用 transferGroupOwner 接口。
  /// ```
  ///
  /// 参数
  ///
  /// ```
  /// role	切换的角色支持： V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_ROLE_MEMBER：普通群成员 V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_ROLE_ADMIN：管理员
  /// ```
  Future<V2TimCallback> setGroupMemberRole({
    required String groupID,
    required String userID,
    required GroupMemberRoleTypeEnum role,
  }) async {
    return TencentCloudChatSdkPlatform.instance.setGroupMemberRole(
        groupID: groupID,
        userID: userID,
        role: EnumUtils.convertGroupMemberRoleTypeEnum(
          role,
        ));
  }

  /// 转让群主
  ///
  /// 注意
  ///
  /// ```
  /// 普通类型的群（Work、Public、Meeting）：只有群主才有权限进行群转让操作。
  /// 直播群（AVChatRoom）：不支持转让群主。
  /// ```
  Future<V2TimCallback> transferGroupOwner({
    required String groupID,
    required String userID,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .transferGroupOwner(groupID: groupID, userID: userID);
  }

  ///获取加群的申请列表
  ///
  ///web 不支持
  ///
  Future<V2TimValueCallback<V2TimGroupApplicationResult>>
      getGroupApplicationList() async {
    return TencentCloudChatSdkPlatform.instance.getGroupApplicationList();
  }

  ///同意某一条加群申请
  ///
  ///
  //web 端使用时必须传入webMessageInstance 字段。 对应【群系统通知】的消息实例
  ///
  Future<V2TimCallback> acceptGroupApplication({
    required String groupID,
    String? reason,
    required String fromUser,
    required String toUser,
    int? addTime,
    GroupApplicationTypeEnum? type,
    String? webMessageInstance,
  }) async {
    return TencentCloudChatSdkPlatform.instance.acceptGroupApplication(
      groupID: groupID,
      reason: reason,
      fromUser: fromUser,
      toUser: toUser,
      addTime: addTime,
      type: type?.index,
      webMessageInstance: webMessageInstance,
    );
  }

  ///拒绝某一条加群申请
  ///
  ///参数：
  ///webMessageInstance [web端实例](https://web.sdk.qcloud.com/im/doc/zh-cn/SDK.html#handleGroupApplication)
  ///type [GroupApplicationTypeEnum] 群未决请求类型
  ///fromUser  请求者ID
  ///toUser 获取处理者 ID, 请求加群:0，邀请加群:被邀请人
  ///addTime 获取群未决添加的时间
  ///```
  ///web 端使用时必须传入webMessageInstance 字段。 对应【群系统通知】的消息实例
  ///```
  Future<V2TimCallback> refuseGroupApplication({
    required String groupID,
    String? reason,
    required String fromUser,
    required String toUser,
    required int addTime,
    required GroupApplicationTypeEnum type,
    String? webMessageInstance,
  }) async {
    return TencentCloudChatSdkPlatform.instance.refuseGroupApplication(
        groupID: groupID,
        fromUser: fromUser,
        toUser: toUser,
        addTime: addTime,
        type: type.index,
        webMessageInstance: webMessageInstance);
  }

  ///标记申请列表为已读
  ///
  /// web 不支持
  ///
  Future<V2TimCallback> setGroupApplicationRead() async {
    return TencentCloudChatSdkPlatform.instance.setGroupApplicationRead();
  }

  /// 搜索群资料(需要您购买旗舰套餐)
  ///
  ///参数：
  ///searchParam	搜索参数([V2TimGroupSearchParam])
  ///```
  ///SDK 会搜索群名称包含于关键字列表 keywordList 的所有群并返回群信息列表。关键字列表最多支持5个。
  /// web 不支持关键字搜索搜索, 请使用searchGroupByID
  ///```
  Future<V2TimValueCallback<List<V2TimGroupInfo>>> searchGroups({
    required V2TimGroupSearchParam searchParam,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .searchGroups(searchParam: searchParam);
  }

  /// ## 搜索群成员
  /// `TODO这里安卓和ios有差异化，ios能根据组名返回key:list但 安卓但key是""为空，我设为default`
  ///参数：
  /// - searchParam	搜索参数([V2TimGroupSearchParam])
  ///```
  ///SDK 会在本地搜索指定群 ID 列表中，群成员信息（名片、好友备注、昵称、userID）包含于关键字列表 keywordList 的所有群成员并返回群 ID 和群成员列表的 map，关键字列表最多支持5个。
  /// web 不支持搜索
  /// ```
  ///
  Future<V2TimValueCallback<V2GroupMemberInfoSearchResult>> searchGroupMembers({
    required V2TimGroupMemberSearchParam param,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .searchGroupMembers(param: param);
  }

  /// 通过 groupID 搜索群组
  /// 注意： 好友工作群不能被搜索
  /// 仅 web 支持该搜索方式
  ///
  Future<V2TimValueCallback<V2TimGroupInfo>> searchGroupByID({
    required String groupID,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .searchGroupByID(groupID: groupID);
  }

  /// 获取当前用户已经加入的支持话题的社群列表
  /// 4.0.1及以上版本支持
  /// web版本不支持
  ///
  Future<V2TimValueCallback<List<V2TimGroupInfo>>>
      getJoinedCommunityList() async {
    return TencentCloudChatSdkPlatform.instance.getJoinedCommunityList();
  }

  /// 创建话题
  /// 4.0.1及以上版本支持
  /// web版本不支持
  ///
  Future<V2TimValueCallback<String>> createTopicInCommunity({
    required String groupID,
    required V2TimTopicInfo topicInfo,
  }) async {
    return TencentCloudChatSdkPlatform.instance.createTopicInCommunity(
      groupID: groupID,
      topicInfo: topicInfo,
    );
  }

  /// 删除话题
  /// 4.0.1及以上版本支持
  /// web版本不支持
  ///
  Future<V2TimValueCallback<List<V2TimTopicOperationResult>>>
      deleteTopicFromCommunity({
    required String groupID,
    required List<String> topicIDList,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .deleteTopicFromCommunity(groupID: groupID, topicIDList: topicIDList);
  }

  /// 删除话题
  /// 4.0.1及以上版本支持
  /// web版本不支持
  ///
  Future<V2TimCallback> setTopicInfo({
    required String groupID,
    required V2TimTopicInfo topicInfo,
  }) async {
    return TencentCloudChatSdkPlatform.instance.setTopicInfo(
      topicInfo: topicInfo,
      groupID: groupID,
    );
  }

  /// 获取话题列表。
  /// 4.0.1及以上版本支持
  /// web版本不支持
  ///
  Future<V2TimValueCallback<List<V2TimTopicInfoResult>>> getTopicInfoList({
    required String groupID,
    required List<String> topicIDList,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .getTopicInfoList(groupID: groupID, topicIDList: topicIDList);
  }

  /// 设置群计数器（5.0.8 及其以上版本支持）
  /// 注意
  /// 该计数器的 key 如果存在，则直接更新计数器的 value 值；如果不存在，则添加该计数器的 key-value；
  /// 当群计数器设置成功后，在 succ 回调中会返回最终成功设置的群计数器信息；
  /// 除了社群和话题，群计数器支持所有的群组类型。
  ///
  Future<V2TimValueCallback<Map<String, int>>> setGroupCounters({
    required String groupID,
    required Map<String, int> counters,
  }) async {
    return TencentCloudChatSdkPlatform.instance.setGroupCounters(
      groupID: groupID,
      counters: counters,
    );
  }

  /// 获取群计数器（5.0.8 及其以上版本支持）
  ///
  /// 注意
  /// 如果 keys 为空，则表示获取群内的所有计数器；
  /// 除了社群和话题，群计数器支持所有的群组类型。
  ///
  Future<V2TimValueCallback<Map<String, int>>> getGroupCounters({
    required String groupID,
    required List<String> keys,
  }) async {
    return TencentCloudChatSdkPlatform.instance.getGroupCounters(
      groupID: groupID,
      keys: keys,
    );
  }

  /// 递增群计数器（5.0.8 及其以上版本支持）
  ///
  ///   参数
  /// groupID	群 ID
  /// key	群计数器的 key
  /// value	群计数器的递增的变化量，计数器 key 对应的 value 变更方式为： new_value = old_value + value
  /// 注意
  /// 成功后的回调，会返回当前计数器做完递增操作后的 value
  /// 该计数器的 key 如果存在，则直接在当前值的基础上根据传入的 value 作递增操作；反之，添加 key，并在默认值为 0 的基础上根据传入的 value 作递增操作；
  /// 除了社群和话题，群计数器支持所有的群组类型。
  ///
  Future<V2TimValueCallback<Map<String, int>>> increaseGroupCounter({
    required String groupID,
    required String key,
    required int value,
  }) async {
    return TencentCloudChatSdkPlatform.instance.increaseGroupCounter(
      groupID: groupID,
      key: key,
      value: value,
    );
  }

  /// 递减群计数器（7.0 及其以上版本支持）
  ///
  /// 参数
  /// groupID	群 ID
  /// key	群计数器的 key
  /// value	群计数器的递减的变化量，计数器 key 对应的 value 变更方式为： new_value = old_value - value
  /// 注意
  /// 成功后的回调，会返回当前计数器做完递减操作后的 value
  /// 该计数器的 key 如果存在，则直接在当前值的基础上根据传入的 value 作递减操作；反之，添加 key，并在默认值为 0 的基础上根据传入的 value 作递减操作
  /// 除了社群和话题，群计数器支持所有的群组类型。
  ///
  Future<V2TimValueCallback<Map<String, int>>> decreaseGroupCounter({
    required String groupID,
    required String key,
    required int value,
  }) async {
    return TencentCloudChatSdkPlatform.instance.decreaseGroupCounter(
      groupID: groupID,
      key: key,
      value: value,
    );
  }

  Future<V2TimCallback> markGroupMemberList({
    required String groupID,
    required List<String> memberIDList,
    required int markType,
    required bool enableMark,
  }) async {
    return TencentCloudChatSdkPlatform.instance.markGroupMemberList(
      groupID: groupID,
      memberIDList: memberIDList,
      markType: markType,
      enableMark: enableMark,
    );
  }

  ///@nodoc
  Map buildParam(Map param) {
    param["TIMManagerName"] = "groupManager";
    return param;
  }

  ///@nodoc
  formatJson(jsonSrc) {
    return json.decode(json.encode(jsonSrc));
  }
}
