import Flutter
import UIKit

public class TencentCloudChatSdkPlugin: NSObject, FlutterPlugin {
  public static var channels: [FlutterMethodChannel] = [];
	/**
	* 监听器回调的方法名
	*/
	private static let LISTENER_FUNC_NAME = "onListener";
	
	var friendManager: FriendManager?

	var conversationManager: ConversationManager?

	var groupManager: GroupManager?

	var messageManager: MessageManager?

	var sdkManager: SDKManager?
	
	var signalingManager: SignalingManager?
    
    var communityManager: CommunityManager?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "tencent_cloud_chat_sdk", binaryMessenger: registrar.messenger())
    let instance = TencentCloudChatSdkPlugin()
    registrar.addApplicationDelegate(instance)
		registrar.addMethodCallDelegate(instance, channel: channel)
    channels.append(channel);
    
		instance.friendManager = FriendManager(channel: channel)
		instance.conversationManager = ConversationManager(channel: channel)
		instance.groupManager = GroupManager(channel: channel)
		instance.messageManager = MessageManager(channel: channel)
		instance.signalingManager = SignalingManager(channel: channel)
		instance.sdkManager = SDKManager(channel: channel)
        instance.communityManager = CommunityManager(channel: channel);
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    for item:FlutterMethodChannel in  TencentCloudChatSdkPlugin.channels {
        CommonUtils.logFromSwift(channel: item, data: ["msg": "Swift Resqust，方法名\(call.method)，参数：", "data": call.arguments ?? ""])
    }
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "initSDK":
			sdkManager!.`initSDK`(call: call, result: result)
			break
		case "setAPNS":
			sdkManager!.setAPNS(call: call, result: result)
			break
		case "getVersion":
			sdkManager!.`getVersion`(call: call, result: result)
			break
		case "getServerTime":
			sdkManager!.getServerTime(call: call, result: result)
			break
		case "getLoginUser":
			sdkManager!.getLoginUser(call: call, result: result)
			break
		case "unInitSDK":
			sdkManager!.unInitSDK(call: call, result: result)
			break
		case "login":
			sdkManager!.login(call: call, result: result)
			break
		case "logout":
			sdkManager!.logout(call: call, result: result)
			break
		case "initStorage":
			sdkManager!.initStorage(call: call, result: result)
			break
		case "getLoginStatus":
			sdkManager!.getLoginStatus(call: call, result: result)
			break	
		case "setFriendListener":
			sdkManager!.setFriendListener(call: call, result: result)
			break
		case "addConversationListener":
			sdkManager!.addConversationListener(call: call, result: result)
			break
		case "addFriendListener":
			sdkManager!.addFriendListener(call: call, result: result)
			break
		case "removeConversationListener":
			sdkManager!.removeConversationListener(call: call, result: result)
			break
		case "removeFriendListener":
			sdkManager!.removeFriendListener(call: call, result: result)
			break
		case "addAdvancedMsgListener":
			sdkManager!.addAdvancedMsgListener(call: call, result: result)
			break
		case "removeAdvancedMsgListener":
			sdkManager!.removeAdvancedMsgListener(call: call, result: result)
			break
		case "setConversationListener":
			sdkManager!.setConversationListener(call: call, result: result)
			break
		case "addSignalingListener":
			sdkManager!.addSignalingListener(call: call, result: result)
			break
		case "removeSignalingListener":
			sdkManager!.removeSignalingListener(call: call, result: result)
			break
		case "setGroupListener":
			sdkManager!.setGroupListener(call: call, result: result)
			break
		case "addGroupListener":
			sdkManager!.addGroupListener(call: call, result: result)
			break
		case "removeGroupListener":
			sdkManager!.removeGroupListener(call: call, result: result)
			break
		case "sendMessageReadReceipts":
			messageManager!.sendMessageReadReceipts(call: call, result: result)
			break
		case "getMessageReadReceipts":
			messageManager!.getMessageReadReceipts(call: call, result: result)
			break
		case "getGroupMessageReadMemberList":
            messageManager!.getGroupMessageReadMemberList(call: call, result: result)
			break
		case "pinGroupMessage":
            messageManager!.pinGroupMessage(call: call, result: result)
            break
        case "getPinnedGroupMessageList":
            messageManager!.getPinnedGroupMessageList(call: call, result: result)
            break
		case "addSimpleMsgListener":
			sdkManager!.addSimpleMsgListener(call: call, result: result)
			break
		case "removeSimpleMsgListener":
			sdkManager!.removeSimpleMsgListener(call: call, result: result)
			break
		case "setAPNSListener":
			sdkManager!.setAPNSListener(call: call, result: result)
		case "getUsersInfo":
			sdkManager!.getUsersInfo(call: call, result: result)
			break
		case "setSelfInfo":
			sdkManager!.setSelfInfo(call: call, result: result)
			break
		// 好友管理 begin
		case "getFriendList":
			friendManager!.getFriendList(call:call, result: result)
			break
		case "getFriendsInfo":
			friendManager!.getFriendsInfo(call:call, result: result)
			break
		case "setFriendInfo":
			friendManager!.setFriendInfo(call:call, result: result)
			break
		case "addFriend":
			friendManager!.addFriend(call:call, result: result)
			break
		case "deleteFromFriendList":
			friendManager!.deleteFromFriendList(call:call, result: result)
			break
		case "checkFriend":
			friendManager!.checkFriend(call:call, result: result)
			break
		case "getFriendApplicationList":
			friendManager!.getFriendApplicationList(call:call, result: result)
			break
		case "acceptFriendApplication":
			friendManager!.acceptFriendApplication(call:call, result: result)
			break
		case "refuseFriendApplication":
			friendManager!.refuseFriendApplication(call:call, result: result)
			break
		case "deleteFriendApplication":
			friendManager!.deleteFriendApplication(call:call, result: result)
			break
		case "setFriendApplicationRead":
			friendManager!.setFriendApplicationRead(call:call, result: result)
			break
		case "createFriendGroup":
			friendManager!.createFriendGroup(call:call, result: result)
			break
		case "getFriendGroups":
			friendManager!.getFriendGroups(call:call, result: result)
			break
		case "deleteFriendGroup":
			friendManager!.deleteFriendGroup(call:call, result: result)
			break
		case "renameFriendGroup":
			friendManager!.renameFriendGroup(call:call, result: result)
			break
		case "addFriendsToFriendGroup":
			friendManager!.addFriendsToFriendGroup(call:call, result: result)
			break
		case "deleteFriendsFromFriendGroup":
			friendManager!.deleteFriendsFromFriendGroup(call:call, result: result)
			break
		case "getBlackList":
			friendManager!.getBlackList(call:call, result: result)
			break
		case "addToBlackList":
			friendManager!.addToBlackList(call:call, result: result)
			break
		case "deleteFromBlackList":
			friendManager!.deleteFromBlackList(call:call, result: result)
			break
        
        
        
        case "subscribeOfficialAccount":
            friendManager!.subscribeOfficialAccount(call:call, result: result)
            break
        case "unsubscribeOfficialAccount":
            friendManager!.unsubscribeOfficialAccount(call:call, result: result)
            break
        case "getOfficialAccountsInfo":
            friendManager!.getOfficialAccountsInfo(call:call, result: result)
            break
        case "followUser":
            friendManager!.followUser(call:call, result: result)
            break
        case "unfollowUser":
            friendManager!.unfollowUser(call:call, result: result)
            break
        case "getMyFollowingList":
            friendManager!.getMyFollowingList(call:call, result: result)
            break
		case "getMyFollowersList":
            friendManager!.getMyFollowersList(call:call, result: result)
            break
        case "getMutualFollowersList":
            friendManager!.getMutualFollowersList(call:call, result: result)
            break
        case "getUserFollowInfo":
            friendManager!.getUserFollowInfo(call:call, result: result)
            break
        case "checkFollowType":
            friendManager!.checkFollowType(call:call, result: result)
            break
            
        
        
		case "createGroup":
			groupManager!.createGroup(call: call, result: result)
			break
		// case "createGroup":
		//   groupManager!.createGroup(call: call, result: result)
		//   break
		case "joinGroup":
			groupManager!.joinGroup(call: call, result: result)
			break
		case "quitGroup":
			groupManager!.quitGroup(call: call, result: result)
			break
		case "dismissGroup":
			groupManager!.dismissGroup(call: call, result: result)
			break
		case "getJoinedGroupList":
			groupManager!.getJoinedGroupList(call: call, result: result)
			break
		case "getGroupsInfo":
			groupManager!.getGroupsInfo(call: call, result: result)
			break
		case "setGroupInfo":
			groupManager!.setGroupInfo(call: call, result: result)
			break
		case "setReceiveMessageOpt":
			groupManager!.setReceiveMessageOpt(call: call, result: result)
			break
		case "getGroupMemberList":
			groupManager!.getGroupMemberList(call: call, result: result)
			break
		case "getGroupMembersInfo":
			groupManager!.getGroupMembersInfo(call: call, result: result)
			break
		case "setGroupMemberInfo":
			groupManager!.setGroupMemberInfo(call: call, result: result)
			break
		case "muteGroupMember":
			groupManager!.muteGroupMember(call: call, result: result)
			break
		case "inviteUserToGroup":
			groupManager!.inviteUserToGroup(call: call, result: result)
			break
		case "kickGroupMember":
			groupManager!.kickGroupMember(call: call, result: result)
			break
		case "setGroupMemberRole":
			groupManager!.setGroupMemberRole(call: call, result: result)
			break
		case "transferGroupOwner":
			groupManager!.transferGroupOwner(call: call, result: result)
			break
		case "getGroupApplicationList":
			groupManager!.getGroupApplicationList(call: call, result: result)
			break
		case "acceptGroupApplication":
			groupManager!.acceptGroupApplication(call: call, result: result)
			break
		case "refuseGroupApplication":
			groupManager!.refuseGroupApplication(call: call, result: result)
			break
		case "setGroupApplicationRead":
			groupManager!.setGroupApplicationRead(call: call, result: result)
			break
		case "initGroupAttributes":
			groupManager!.initGroupAttributes(call: call, result: result)
			break
		case "setGroupAttributes":
			groupManager!.setGroupAttributes(call: call, result: result)
			break
		case "deleteGroupAttributes":
			groupManager!.deleteGroupAttributes(call: call, result: result)
			break
		case "getGroupAttributes":
			groupManager!.getGroupAttributes(call: call, result: result)
			break
		case "getGroupOnlineMemberCount":
			groupManager!.getGroupOnlineMemberCount(call: call, result: result)
			break
		case "getConversationList":
			conversationManager!.getConversationList(call: call, result: result)
			break
		case "getConversationListByConversaionIds":
			conversationManager!.getConversationListByConversaionIds(call: call, result: result)
			break
		case "getConversation":
			conversationManager!.getConversation(call: call, result: result)
			break
		case "deleteConversation":
			conversationManager!.deleteConversation(call: call, result: result)
			break
		case "setConversationDraft":
			conversationManager!.setConversationDraft(call: call, result: result)
			break
		case "pinConversation":
			conversationManager!.pinConversation(call: call, result: result)
			break
		case "getTotalUnreadMessageCount":
			conversationManager!.getTotalUnreadMessageCount(call: call, result: result)
			break
        case "sendMessage":
            messageManager!.sendMessage(call: call, result: result)
		case "createTargetedGroupMessage":
			messageManager!.createTargetedGroupMessage(call: call, result: result)
		case "createTextMessage":
			messageManager!.createTextMessage(call: call, result: result, type: 1)
			break
		case "createCustomMessage":
			messageManager!.createCustomMessage(call: call, result: result, type: 2)
			break
		case "createImageMessage":
			messageManager!.createImageMessage(call: call, result: result, type: 3)
			break
		case "createSoundMessage":
			messageManager!.createSoundMessage(call: call, result: result, type: 4)
			break
		case "createVideoMessage":
			messageManager!.createVideoMessage(call: call, result: result, type: 5)
			break
		case "createFileMessage":
			messageManager!.createVideoMessage(call: call, result: result, type: 6)
			break
		case "createTextAtMessage":
			messageManager!.createTextAtMessage(call: call, result: result, type: 1)
			break
		case "createLocationMessage":
			messageManager!.createLocationMessage(call: call, result: result, type: 7)
			break
		case "createFaceMessage":
			messageManager!.createFaceMessage(call: call, result: result, type: 8)
			break	
		case "createMergerMessage":
			messageManager!.createMergerMessage(call: call, result: result)
			break
		case "createForwardMessage":
			messageManager!.createForwardMessage(call: call, result: result)
			break
		case "sendTextMessage":
			messageManager!.sendMessageOldEdition(call: call, result: result, type: 1)
			break
		case "sendTextAtMessage":
			messageManager!.sendMessageOldEdition(call: call, result: result, type: 1)
			break
		case "sendCustomMessage":
			messageManager!.sendMessageOldEdition(call: call, result: result, type: 2)
			break
		case "sendImageMessage":
			messageManager!.sendMessageOldEdition(call: call, result: result, type: 3)
			break
		case "sendSoundMessage":
			messageManager!.sendMessageOldEdition(call: call, result: result, type: 4)
			break
		case "sendVideoMessage":
			messageManager!.sendMessageOldEdition(call: call, result: result, type: 5)
			break
		case "sendFileMessage":
			messageManager!.sendMessageOldEdition(call: call, result: result, type: 6)
			break
		case "sendLocationMessage":
			messageManager!.sendMessageOldEdition(call: call, result: result, type: 7)
			break
		case "sendFaceMessage":
			messageManager!.sendMessageOldEdition(call: call, result: result, type: 8)
			break
		// 无creatGroupTipsMessage
		case "sendGroupTipsMessage":
			messageManager!.sendMessageOldEdition(call: call, result: result, type: 9)
			break
		case "downloadMergerMessage":
			messageManager!.downloadMergerMessage(call: call, result: result)
			break;
		case "sendMergerMessage":
			messageManager!.sendMergerMessage(call: call, result: result)
			break;
		case "sendForwardMessage":
			messageManager!.sendForwardMessage(call: call, result: result)
			break
		case "reSendMessage":
			messageManager!.reSendMessage(call: call, result: result)
			break
		case "sendC2CTextMessage":
			messageManager!.sendC2CTextMessage(call: call, result: result)
			break
		case "sendC2CCustomMessage":
			messageManager!.sendC2CCustomMessage(call: call, result: result)
			break
		case "sendGroupTextMessage":
			messageManager!.sendGroupTextMessage(call: call, result: result)
			break
		case "sendGroupCustomMessage":
			messageManager!.sendGroupCustomMessage(call: call, result: result)
			break
		case "setC2CReceiveMessageOpt":
			messageManager!.setC2CReceiveMessageOpt(call: call, result: result)
			break
		case "getC2CReceiveMessageOpt":
			messageManager!.getC2CReceiveMessageOpt(call: call, result: result)
			break
		case "setGroupReceiveMessageOpt":
			messageManager!.setGroupReceiveMessageOpt(call: call, result: result)
			break
		case "getC2CHistoryMessageList":
			messageManager!.getC2CHistoryMessageList(call: call, result: result)
			break
		case "clearC2CHistoryMessage":
			messageManager!.clearC2CHistoryMessage(call: call, result: result)
			break
		case "getGroupHistoryMessageList":
			messageManager!.getGroupHistoryMessageList(call: call, result: result)
			break
		case "getHistoryMessageList":
			messageManager!.getHistoryMessageList(call: call, result: result)
			break
        case "getHistoryMessageListV2":
            messageManager!.getHistoryMessageListV2(call: call, result: result)
            break
		case "revokeMessage":
			messageManager!.revokeMessage(call: call, result: result)
			break
		case "markC2CMessageAsRead":
			messageManager!.markC2CMessageAsRead(call: call, result: result)
			break
		case "markGroupMessageAsRead":
			messageManager!.markGroupMessageAsRead(call: call, result: result)
			break
		case "markAllMessageAsRead":
			messageManager!.markAllMessageAsRead(call: call, result: result)
			break
		case "deleteMessageFromLocalStorage":
			messageManager!.deleteMessageFromLocalStorage(call: call, result: result)
			break
		case "deleteMessages":
			messageManager!.deleteMessages(call: call, result: result)
			break
		case "insertGroupMessageToLocalStorage":
			messageManager!.insertGroupMessageToLocalStorage(call: call, result: result)
			break
		case "insertC2CMessageToLocalStorage":
			messageManager!.insertC2CMessageToLocalStorage(call: call, result: result)
			break
		case "setCloudCustomData":
			messageManager!.setCloudCustomData(call: call, result: result)
			break
		case "setLocalCustomInt":
			messageManager!.setLocalCustomInt(call: call, result: result)
			break
		case "setLocalCustomData":
			messageManager!.setLocalCustomData(call: call, result: result)
			break
		case "setUnreadCount":
			sdkManager!.setUnreadCount(call: call, result: result)
			break
		case "callExperimentalAPI":
            sdkManager!.callExperimentalAPI(call: call, result: result)
            break
		case "invite":
			signalingManager!.invite(call: call, result: result)
			break
		case "inviteInGroup":
			signalingManager!.inviteInGroup(call: call, result: result)
			break
		case "cancel":
			signalingManager!.cancel(call: call, result: result)
			break
		case "accept":
			signalingManager!.accept(call: call, result: result)
			break
		case "reject":
			signalingManager!.reject(call: call, result: result)
			break
		case "getSignalingInfo":
			signalingManager!.getSignalingInfo(call: call, result: result)
			break
		case "addInvitedSignaling":
			signalingManager!.addInvitedSignaling(call: call, result: result)
			break
		case "clearGroupHistoryMessage":
			messageManager!.clearGroupHistoryMessage(call: call, result: result)
			break
		case "searchLocalMessages":
			messageManager!.searchLocalMessages(call: call, result: result)
			break
        case "modifyMessage":
            messageManager!.modifyMessage(call: call, result: result)
            break
		case "findMessages":
			messageManager!.findMessages(call: call, result: result)
			break
		case "searchGroups":
			groupManager!.searchGroups(call: call, result: result)
			break
        case "getJoinedCommunityList":
            groupManager!.getJoinedCommunityList(call: call, result: result)
            break
        case "createTopicInCommunity":
            groupManager!.createTopicInCommunity(call: call, result: result)
            break
        case "deleteTopicFromCommunity":
            groupManager!.deleteTopicFromCommunity(call: call, result: result)
            break
        case "setTopicInfo":
            groupManager!.setTopicInfo(call: call, result: result)
            break
        case "getTopicInfoList":
            groupManager!.getTopicInfoList(call: call, result: result)
            break
		case "searchGroupMembers":
			groupManager!.searchGroupMembers(call: call, result: result)
			break
		case "searchFriends":
			friendManager!.searchFriends(call: call, result: result)
			break
        case "checkAbility":
            sdkManager!.checkAbility(call: call, result: result)
            break;
        case "appendMessage":
            messageManager!.appendMessage(call: call, result: result)
            break
        case "getUserStatus":
            sdkManager!.getUserStatus(call: call, result: result)
            break
        case "setSelfStatus":
            sdkManager!.setSelfStatus(call: call, result: result)
            break
        case "doBackground":
            sdkManager!.doBackground(call: call, result: result)
            break;
		case "doForeground":
            sdkManager!.doForeground(call: call, result: result)
            break;
        case "subscribeUserStatus":
            sdkManager!.subscribeUserStatus(call: call, result: result)
            break;
        case "unsubscribeUserStatus":
            sdkManager!.unsubscribeUserStatus(call: call, result: result)
            break;
        case "setConversationCustomData":
            conversationManager!.setConversationCustomData(call: call, result: result)
            break;
        case "getConversationListByFilter":
            conversationManager!.getConversationListByFilter(call: call, result: result)
            break;
        case "markConversation":
            conversationManager!.markConversation(call: call, result: result)
            break;
        case "createConversationGroup":
            conversationManager!.createConversationGroup(call: call, result: result)
            break;
        case "getConversationGroupList":
            conversationManager!.getConversationGroupList(call: call, result: result)
            break;
        case "deleteConversationGroup":
            conversationManager!.deleteConversationGroup(call: call, result: result)
            break;
        case "renameConversationGroup":
            conversationManager!.renameConversationGroup(call: call, result: result)
            break;
        case "addConversationsToGroup":
            conversationManager!.addConversationsToGroup(call: call, result: result)
            break;
        case "deleteConversationsFromGroup":
            conversationManager!.deleteConversationsFromGroup(call: call, result: result)
            break;
		case "setMessageExtensions":
            messageManager!.setMessageExtensions(call: call, result: result)
            break;
        case "getMessageExtensions":
            messageManager!.getMessageExtensions(call: call, result: result)
            break;
        case "deleteMessageExtensions":
            messageManager!.deleteMessageExtensions(call: call, result: result)
            break;
        case "getMessageOnlineUrl":
            messageManager!.getMessageOnlineUrl(call: call, result: result)
            break;
        case "downloadMessage":
            messageManager!.downloadMessage(call: call, result: result)
            break;
        case "translateText":
            messageManager!.translateText(call: call, result: result)
            break;
        case "setGroupCounters":
            groupManager!.setGroupCounters(call: call, result: result)
            break;
        case "getGroupCounters":
            groupManager!.getGroupCounters(call: call, result: result)
            break;
        case "increaseGroupCounter":
            groupManager!.increaseGroupCounter(call: call, result: result)
            break;
        case "decreaseGroupCounter":
            groupManager!.decreaseGroupCounter(call: call, result: result)
            break;
        case "setVOIP":
            sdkManager!.setVOIP(call:call,result: result)
            break;
        case "subscribeUserInfo":
            sdkManager!.subscribeUserInfo(call:call,result: result);
            break;
        case "unsubscribeUserInfo":
            sdkManager!.unsubscribeUserInfo(call:call,result: result);
            break;
        case "markGroupMemberList":
            groupManager!.markGroupMemberList(call:call,result: result);
            break;
        case "setAllReceiveMessageOpt":
            messageManager!.setAllReceiveMessageOpt(call:call,result: result);
            break;
        case "setAllReceiveMessageOptWithTimestamp":
            messageManager!.setAllReceiveMessageOptWithTimestamp(call:call,result: result);
            break;
        case "getAllReceiveMessageOpt":
            messageManager!.getAllReceiveMessageOpt(call:call,result: result);
            break;
        case "addMessageReaction":
            messageManager!.addMessageReaction(call:call,result: result);
            break;
        case "removeMessageReaction":
            messageManager!.removeMessageReaction(call:call,result: result);
            break;
        case "getMessageReactions":
            messageManager!.getMessageReactions(call:call,result: result);
            break;
        case "getAllUserListOfMessageReaction":
            messageManager!.getAllUserListOfMessageReaction(call:call,result: result);
            break;
        case "searchCloudMessages":
            messageManager!.searchCloudMessages(call:call,result: result);
            break;
        case "getUnreadMessageCountByFilter":
            conversationManager!.getUnreadMessageCountByFilter(call:call,result: result);
            break;
        case "subscribeUnreadMessageCountByFilter":
            conversationManager!.subscribeUnreadMessageCountByFilter(call:call,result: result);
            break;
        case "unsubscribeUnreadMessageCountByFilter":
            conversationManager!.unsubscribeUnreadMessageCountByFilter(call:call,result: result);
            break;
        case "cleanConversationUnreadMessageCount":
            conversationManager!.cleanConversationUnreadMessageCount(call:call,result: result);
            break;
        case "convertVoiceToText":
            messageManager!.convertVoiceToText(call: call, result: result);
            break;
        case "uikitTrace":
            sdkManager!.uikitTrace(call:call,result: result);
            break;
        case "deleteConversationList":
            conversationManager!.deleteConversationList(call: call, result: result);
            break;
        // 社群
    case "addCommunityListener":
        sdkManager!.addCommunityListener(call: call, result: result);
        break;
    case "removeCommunityListener":
        sdkManager!.removeCommunityListener(call: call, result: result);
        break;
    case "createCommunity":
        communityManager!.createCommunity(call: call, result: result);
        break;case "createPermissionGroupInCommunity":
        communityManager!.createPermissionGroupInCommunity(call: call, result: result);
        break;case "deletePermissionGroupFromCommunity":
        communityManager!.deletePermissionGroupFromCommunity(call: call, result: result);
        break;
    case "modifyPermissionGroupInfoInCommunity":
        communityManager!.modifyPermissionGroupInfoInCommunity(call: call, result: result);
        break;
    case "getJoinedPermissionGroupListInCommunity":
        communityManager!.getJoinedPermissionGroupListInCommunity(call: call, result: result);
        break;
    case "getPermissionGroupListInCommunity":
        communityManager!.getPermissionGroupListInCommunity(call: call, result: result);
        break;
    case "addCommunityMembersToPermissionGroup":
        communityManager!.addCommunityMembersToPermissionGroup(call: call, result: result);
        break;
    case "removeCommunityMembersFromPermissionGroup":
        communityManager!.removeCommunityMembersFromPermissionGroup(call: call, result: result);
        break;
    case "getCommunityMemberListInPermissionGroup":
        communityManager!.getCommunityMemberListInPermissionGroup(call: call, result: result);
        break;
    case "addTopicPermissionToPermissionGroup":
        communityManager!.addTopicPermissionToPermissionGroup(call: call, result: result);
        break;
    case "deleteTopicPermissionFromPermissionGroup":
        communityManager!.deleteTopicPermissionFromPermissionGroup(call: call, result: result);
        break;
    case "modifyTopicPermissionInPermissionGroup":
        communityManager!.modifyTopicPermissionInPermissionGroup(call: call, result: result);
        break;
    case "getTopicPermissionInPermissionGroup":
        communityManager!.getTopicPermissionInPermissionGroup(call: call, result: result);
        break;
        
        // 7.9+新增
        
    case "insertGroupMessageToLocalStorageV2":
        messageManager!.insertGroupMessageToLocalStorageV2(call: call, result: result);
        break;
    case "insertC2CMessageToLocalStorageV2":
        messageManager!.insertC2CMessageToLocalStorageV2(call: call, result: result);
        break;
    case "createAtSignedGroupMessage":
        messageManager!.createAtSignedGroupMessage(call: call, result: result);
        break;
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  public static func invokeListener(type: ListenerType, method: String, data: Any?, listenerUuid: String?) {
        DispatchQueue.main.async {
            
          for channel:FlutterMethodChannel in channels {
              CommonUtils.logFromSwift(channel: channel, data: ["msg": "Swift向Dart发送事件，事件名\(type)，数据", "data": data as Any])
          }
           var resultParams: [String: Any] = [:];
           resultParams["type"] = "\(type)";
           if data != nil {
               resultParams["data"] = data;
           }
           
           resultParams["listenerUuid"] = listenerUuid;
           
            for channel:FlutterMethodChannel in channels {
                channel.invokeMethod(method, arguments: resultParams);
            }
        }
	}
}
