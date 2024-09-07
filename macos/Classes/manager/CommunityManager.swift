import ImSDKForMac_Plus
import FlutterMacOS


 class CommunityManager {
    var channel: FlutterMethodChannel
    
    
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }
    
    
    
    func createCommunity(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let info = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "info"}) as?  Dictionary<String, Any>;
        let memberList = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "memberList"}) as?  [Dictionary<String, Any>];
        let gruopInfo = V2GroupInfoEntity.init(dict: info!);
        var n_memberList:[V2TIMCreateGroupMemberInfo] = []
        memberList?.forEach({ data in
            let it = V2TIMCreateGroupMemberInfo();
            it.role = data["role"] as? UInt32 ?? 0
            it.userID = data["userID"] as? String ?? ""
            n_memberList.append(it)
        })
        V2TIMManager.sharedInstance().createCommunity(gruopInfo, memberList: n_memberList) { groupid in
            CommonUtils.resultSuccess(call: call, result: result,data: groupid ?? "")
        } fail: {  code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    
    func createPermissionGroupInCommunity(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let info = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "info"}) as?  Dictionary<String, Any>;
        let n_info = V2TimPermissionGroupInfo.init(dict: info!);
        V2TIMManager.sharedInstance().createPermissionGroup(inCommunity: n_info) { gid in
            CommonUtils.resultSuccess(call: call, result: result,data: gid ?? "")
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    
    func deletePermissionGroupFromCommunity(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let groupID = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "groupID"}) as?  String;
        let permissionGroupIDList = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "permissionGroupIDList"}) as?  [String];
        V2TIMManager.sharedInstance().deletePermissionGroup(fromCommunity: groupID, permissionGroupIDList: permissionGroupIDList) { re_arr in
            CommonUtils.resultSuccess(call: call, result: result,data: V2TimPermissionGroupOperationResult.getListDict(infos: re_arr as! [V2TIMPermissionGroupOperationResult]))
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    
    func modifyPermissionGroupInfoInCommunity(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let info = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "info"}) as?  Dictionary<String, Any>;
        let n_info = V2TimPermissionGroupInfo.init(dict: info!);
        V2TIMManager.sharedInstance().modifyPermissionGroupInfo(inCommunity: n_info) {
            CommonUtils.resultSuccess(call: call, result: result)
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    
    func getJoinedPermissionGroupListInCommunity(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let groupID = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "groupID"}) as?  String;
        V2TIMManager.sharedInstance().getJoinedPermissionGroupList(inCommunity: groupID) { ar_arr in
            CommonUtils.resultSuccess(call: call, result: result,data: V2TimPermissionGroupInfoResult.getListDict(infos: ar_arr as! [V2TIMPermissionGroupInfoResult]))
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    
    func getPermissionGroupListInCommunity(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let groupID = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "groupID"}) as?  String;
        let permissionGroupIDList = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "permissionGroupIDList"}) as?  [String];
        V2TIMManager.sharedInstance().getPermissionGroupList(inCommunity: groupID, permissionGroupIDList: permissionGroupIDList) { ar_arr in
            CommonUtils.resultSuccess(call: call, result: result,data: V2TimPermissionGroupInfoResult.getListDict(infos: ar_arr as! [V2TIMPermissionGroupInfoResult]))
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    
    func addCommunityMembersToPermissionGroup(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let groupID = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "groupID"}) as?  String;
        let permissionGroupID = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "permissionGroupID"}) as?  String;
        let memberList = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "memberList"}) as?  [String];
        V2TIMManager.sharedInstance().addCommunityMembers(toPermissionGroup: groupID, permissionGroupID: permissionGroupID, memberList: memberList) { re_arr in
            CommonUtils.resultSuccess(call: call, result: result,data: V2TimPermissionGroupOperationResult.getListDict(infos: re_arr as! [V2TIMPermissionGroupOperationResult]))
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    
    func removeCommunityMembersFromPermissionGroup(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let groupID = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "groupID"}) as?  String;
        let permissionGroupID = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "permissionGroupID"}) as?  String;
        let memberList = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "memberList"}) as?  [String];
        V2TIMManager.sharedInstance().removeCommunityMembers(fromPermissionGroup: groupID, permissionGroupID: permissionGroupID, memberList: memberList) { re_arr in
            CommonUtils.resultSuccess(call: call, result: result,data: V2TimPermissionGroupOperationResult.getListDict(infos: re_arr as! [V2TIMPermissionGroupOperationResult]))
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    
    func getCommunityMemberListInPermissionGroup(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let groupID = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "groupID"}) as?  String;
        let permissionGroupID = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "permissionGroupID"}) as?  String;
        let nextCursor = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "nextCursor"}) as?  String;
        V2TIMManager.sharedInstance().getCommunityMemberList(inPermissionGroup: groupID, permissionGroupID: permissionGroupID, nextCursor: nextCursor) { next_seq, info_list in
            var res: [String: Any] = [:];
            res["nextCursor"] = next_seq;
            res["memberInfoList"] = V2GroupMemberFullInfoEntity.getListDict(infos: info_list as! [V2TIMGroupMemberFullInfo])
            CommonUtils.resultSuccess(call: call, result: result,data: res)
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    
    func addTopicPermissionToPermissionGroup(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let groupID = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "groupID"}) as?  String;
        let permissionGroupID = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "permissionGroupID"}) as?  String;
        let topicPermissionMap = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "topicPermissionMap"}) as?  [String: NSNumber];
        V2TIMManager.sharedInstance().addTopicPermission(toPermissionGroup: groupID, permissionGroupID: permissionGroupID, topicPermissionMap: topicPermissionMap) { re_arr in
            CommonUtils.resultSuccess(call: call, result: result,data: V2TimTopicOperationResult.getListDict(infos: re_arr as! [V2TIMTopicOperationResult]))
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    
    func deleteTopicPermissionFromPermissionGroup(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let groupID = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "groupID"}) as?  String;
        let permissionGroupID = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "permissionGroupID"}) as?  String;
        let topicIDList = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "topicIDList"}) as?  [String];
        V2TIMManager.sharedInstance().deleteTopicPermission(fromPermissionGroup: groupID, permissionGroupID: permissionGroupID, topicIDList: topicIDList) { re_arr in
            CommonUtils.resultSuccess(call: call, result: result,data: V2TimTopicOperationResult.getListDict(infos: re_arr as! [V2TIMTopicOperationResult]))
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    
    func modifyTopicPermissionInPermissionGroup(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let groupID = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "groupID"}) as?  String;
        let permissionGroupID = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "permissionGroupID"}) as?  String;
        let topicPermissionMap = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "topicPermissionMap"}) as?  [String: NSNumber];
        V2TIMManager.sharedInstance().modifyTopicPermission(inPermissionGroup: groupID, permissionGroupID: permissionGroupID, topicPermissionMap: topicPermissionMap) { re_arr in
            CommonUtils.resultSuccess(call: call, result: result,data: V2TimTopicOperationResult.getListDict(infos: re_arr as! [V2TIMTopicOperationResult]))
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    
    func getTopicPermissionInPermissionGroup(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let groupID = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "groupID"}) as?  String;
        let permissionGroupID = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "permissionGroupID"}) as?  String;
        let topicIDList = (call.arguments as? Dictionary<String, Any>)?.first(where: {$0.key == "topicIDList"}) as?  [String];
        V2TIMManager.sharedInstance().getTopicPermission(inPermissionGroup: groupID, permissionGroupID: permissionGroupID, topicIDList: topicIDList) { re_arr in
            CommonUtils.resultSuccess(call: call, result: result,data: V2TimTopicPermissionResult.getListDict(infos: re_arr as! [V2TIMTopicPermissionResult]))
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    
}
