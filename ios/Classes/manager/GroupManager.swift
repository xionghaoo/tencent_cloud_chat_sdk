//
//  GroupManager.swift
//  tencent_im_sdk_plugin
//
//  Created by xingchenhe on 2020/12/24.
//
import Hydra
import Foundation
import ImSDK_Plus
import Flutter

class GroupManager {
	var channel: FlutterMethodChannel
	
	init(channel: FlutterMethodChannel) {
		self.channel = channel
	}

	func createGroup(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String;
		let groupType = CommonUtils.getParam(call: call, result: result, param: "groupType") as? String;
		let groupName = CommonUtils.getParam(call: call, result: result, param: "groupName") as? String;
		let notification = CommonUtils.getParam(call: call, result: result, param: "notification") as? String;
		let introduction = CommonUtils.getParam(call: call, result: result, param: "introduction") as? String;
		let faceURL = CommonUtils.getParam(call: call, result: result, param: "faceUrl") as? String;
		let addOpt = CommonUtils.getParam(call: call, result: result, param: "addOpt") as? Int;
		let memberListMap = CommonUtils.getParam(call: call, result: result, param: "memberList") as? [[String: Any]];
        let isAllMuted = CommonUtils.getParam(call: call, result: result, param: "isAllMuted") as? Bool;
        let isSupportTopic = CommonUtils.getParam(call: call, result: result, param: "isSupportTopic") as? Bool;
        let approveOpt = CommonUtils.getParam(call: call, result: result, param: "approveOpt") as? Int;
        let isEnablePermissionGroup = CommonUtils.getParam(call: call, result: result, param: "isEnablePermissionGroup") as? Bool;
        let defaultPermissions = CommonUtils.getParam(call: call, result: result, param: "defaultPermissions") as? UInt64;
       
		let info = V2TIMGroupInfo();
		info.groupID = groupID;
		info.groupType = groupType as String?;
		info.groupName = groupName;
		info.notification = notification;
		info.introduction = introduction;
		info.faceURL = faceURL;
		info.groupAddOpt = V2TIMGroupAddOpt(rawValue: addOpt ?? 2)!;
        info.allMuted = isAllMuted ?? false;
        info.groupApproveOpt = V2TIMGroupAddOpt(rawValue: approveOpt ?? 2)!
        info.isSupportTopic = isSupportTopic ?? false
        info.enablePermissionGroup = isEnablePermissionGroup ?? false;
        info.defaultPermissions = defaultPermissions ?? 0;
        
		var memberList: [V2TIMCreateGroupMemberInfo] = []
		if memberListMap != nil {
			for i in memberListMap! {
				let item = V2TIMCreateGroupMemberInfo()
                item.userID = i["userID"] as? String;
                item.role = i["role"] as? UInt32 ?? 200;
				memberList.append(item);
			}
		}
		V2TIMManager.sharedInstance()?.createGroup(info, memberList: memberList, succ: {
			(id) -> Void in
			
			CommonUtils.resultSuccess(call: call, result: result, data: id!)
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	func joinGroup(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String;
		let msg = CommonUtils.getParam(call: call, result: result, param: "message") as? String;
		
		V2TIMManager.sharedInstance()?.joinGroup(groupID, msg: msg ?? "", succ: {
			() -> Void in
			
			CommonUtils.resultSuccess(call: call, result: result)
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	func quitGroup(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String;
		
		V2TIMManager.sharedInstance()?.quitGroup(groupID, succ: {
			() -> Void in
			
			CommonUtils.resultSuccess(call: call, result: result)
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	func dismissGroup(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String;
		
		V2TIMManager.sharedInstance()?.dismissGroup(groupID, succ: {
			() -> Void in
			
			CommonUtils.resultSuccess(call: call, result: result)
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	func getJoinedGroupList(call: FlutterMethodCall, result: @escaping FlutterResult) {
		V2TIMManager.sharedInstance()?.getJoinedGroupList({
			(array) -> Void in
			
			var res: [[String: Any]] = []
			for info in array ?? [] {
				res.append(V2GroupInfoEntity.getDict(info: info))
			}
			CommonUtils.resultSuccess(call: call, result: result, data: res);
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	func getGroupsInfo(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let groupIDList = CommonUtils.getParam(call: call, result: result, param: "groupIDList") as? Array<String>;
		
		V2TIMManager.sharedInstance()?.getGroupsInfo(groupIDList, succ: {
			(array) -> Void in
			
			var groupList: [[String: Any]] = []
			for item in array ?? [] {
                let i = ["resultCode": item.resultCode, "resultMessage": item.resultMsg!, "groupInfo": V2GroupInfoEntity.getDict(info: item.info)] as [String : Any]
				groupList.append(i)
			}
			
			CommonUtils.resultSuccess(call: call, result: result, data: groupList);
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}

	/// 修改群资料
    public func setGroupInfo(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let dict = call.arguments as? Dictionary<String, Any> {
			let info = V2GroupInfoEntity.init(dict: dict)
            
			V2TIMManager.sharedInstance().setGroupInfo(info, succ: {

				CommonUtils.resultSuccess(call: call, result: result)
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
        }
    }
    public func getJoinedCommunityList(call: FlutterMethodCall, result: @escaping FlutterResult) {
        V2TIMManager.sharedInstance().getJoinedCommunityList { infos in
            var dataList: [[String: Any]]  = [];
            infos?.forEach({ info_item in
                dataList.append(V2GroupInfoEntity.getDict(info: info_item))
            })
            CommonUtils.resultSuccess(call: call, result: result, data:dataList);
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }
    }
    
    public func createTopicInCommunity(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String;
        let topicInfo = CommonUtils.getParam(call: call, result: result, param: "topicInfo") as? [String:Any] ;
        
        let info = V2TIMTopicInfoEntity.init(dict: topicInfo!);
        
        V2TIMManager.sharedInstance().createTopic(inCommunity: groupID, topicInfo: info) { groupid in
            CommonUtils.resultSuccess(call: call, result: result, data:groupid as Any);
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    public func deleteTopicFromCommunity(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String;
        let topicIDList = CommonUtils.getParam(call: call, result: result, param: "topicIDList") as? Array<String>;
        V2TIMManager.sharedInstance().deleteTopic(fromCommunity: groupID, topicIDList: topicIDList) { _array in
            var list: [[String: Any]]  = [];
            _array?.forEach({ item in
                let i = item as? V2TIMTopicOperationResult
                var _item:[String:Any] = [:];
                _item["errorCode"] = i?.errorCode as Any?
                _item["errorMsg"] = i?.errorMsg as Any?
                _item["topicID"] = i?.topicID as Any?
                list.append(_item)
            })
            CommonUtils.resultSuccess(call: call, result: result, data:list);
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call,result: result)
        }
    }
    public func setTopicInfo(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String ;
        let topicInfo = CommonUtils.getParam(call: call, result: result, param: "topicInfo") as? [String:Any] ?? [:];
        if((topicInfo["topicID"]) != nil){
            var IDList :[String] = [];
            IDList.append(topicInfo["topicID"] as! String)
            V2TIMManager.sharedInstance().getTopicInfoList(groupID, topicIDList: IDList) { res_list in
                if(res_list?.count == 1){
                    let info_native = res_list?[0] as? V2TIMTopicInfoResult;
                    
                    if(info_native?.errorCode == 0){
                        let tinfo = info_native?.topicInfo;
                        print(topicInfo)
                        if(topicInfo["topicName"] as? String != nil){
                            tinfo?.topicName = topicInfo["topicName"] as? String
                        }
                        if(topicInfo["topicFaceUrl"] as? String != nil){
                            
                            let obj = V2TIMTopicInfo()
                            let mirror = Mirror(reflecting: obj)
                            var hasfaceURLField = false
                            var hasTopicFaceURLField = false
                            for child in mirror.children {
                                if child.label == "faceURL" {
                                    hasfaceURLField = true
                                    #if hasfaceURLField
                                    tinfo?.faceURL = topicInfo["topicFaceUrl"] as? String
                                    #endif
                                    break
                                }
                                if child.label == "topicFaceURL" {
                                    hasTopicFaceURLField = true
                                    #if hasTopicFaceURLField
                                    tinfo?.topicFaceURL = topicInfo["topicFaceUrl"] as? String
                                    #endif
                                    break
                                }
                            }
                            
                            if(hasfaceURLField){
                            }else if(hasTopicFaceURLField){
                            }
                            
                        }
                        if(topicInfo["notification"] as? String != nil){
                            tinfo?.notification = topicInfo["notification"] as? String
                        }
                        if(topicInfo["isAllMute"] as? Bool != nil){
                            tinfo?.isAllMuted = topicInfo["isAllMute"] as! Bool
                        }
                        if(topicInfo["customString"] as? String != nil){
                            tinfo?.customString = topicInfo["customString"] as? String
                        }
                        if(topicInfo["draftText"] as? String != nil){
                            tinfo?.draftText = topicInfo["draftText"] as? String
                        }
                        if(topicInfo["introduction"] as? String != nil){
                            tinfo?.introduction = topicInfo["introduction"] as? String
                        }
                        if(topicInfo["defaultPermissions"] as? UInt64 != nil){
                            tinfo?.defaultPermissions = topicInfo["defaultPermissions"] as? UInt64 ?? 0
                        }
                        V2TIMManager.sharedInstance().setTopicInfo(tinfo) {
                            CommonUtils.resultSuccess(call: call, result: result);
                        } fail: { code, desc in
                            CommonUtils.resultFailed(desc: desc, code: code, call: call,result: result)
                        }
                    }else{
                        CommonUtils.resultFailed(desc: info_native?.errorMsg, code: info_native?.errorCode, call: call,result: result)
                    }
                }else {
                    CommonUtils.resultFailed(desc: "topic not found", code: -1, call: call, result: result)
                }
            } fail: { code, desc in
                CommonUtils.resultFailed(desc: desc, code: code, call: call,result: result)
            }

            
        }
        
        
        
    }
    
    public func getTopicInfoList(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String;
        let topicIDList = CommonUtils.getParam(call: call, result: result, param: "topicIDList") as? Array<String>;
        
        V2TIMManager.sharedInstance().getTopicInfoList(groupID, topicIDList: topicIDList) { _array in
            
            var list: [[String: Any]]  = [];
        
            _array?.forEach({ item in
                let i = item as? V2TIMTopicInfoResult
                
                var _item:[String:Any] = [:];
                _item["errorCode"] = i!.errorCode as Int32?
                _item["errorMsg"] = i!.errorMsg as String? ?? ""
                do {
                    _item["topicInfo"] =  V2TIMTopicInfoEntity.getDict(info: i!.topicInfo)
                } 
                list.append(_item)
            })
            CommonUtils.resultSuccess(call: call, result: result, data:list);
            
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call,result: result)
        }

    }
	
	// 0接收且推送，1不接收，2在线接收离线不推送
	func setReceiveMessageOpt(call: FlutterMethodCall, result: @escaping FlutterResult) {
//		let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as! String;
//		let opt = CommonUtils.getParam(call: call, result: result, param: "opt") as! Int;
//		
//		V2TIMManager.sharedInstance()?.setReceiveMessageOpt(groupID, opt: V2TIMGroupReceiveMessageOpt(rawValue: opt)!, succ: {
//			() -> Void in
//			
//			CommonUtils.resultSuccess(call: call, result: result)
//		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	func getGroupMemberList(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String;
		let filterParam = CommonUtils.getParam(call: call, result: result, param: "filter") as? Int;
		let nextSeqParam = CommonUtils.getParam(call: call, result: result, param: "nextSeq") as? String;
		var filter = V2TIMGroupMemberFilter(rawValue: 0);
		var nextSeq: String = "0";
		
		if(filterParam != nil) {
			filter = V2TIMGroupMemberFilter(rawValue: filterParam!)!
		}
		if(nextSeqParam != nil) {
			nextSeq = nextSeqParam!
		}
		
        V2TIMManager.sharedInstance()?.getGroupMemberList(groupID, filter: UInt32(filter!.rawValue), nextSeq: UInt64(nextSeq)!, succ: {
			(nextSeq, memberList) -> Void in
			
			var res: [[String: Any]] = []
			
			for item in memberList ?? [] {
				res.append(V2GroupMemberFullInfoEntity.getDict(info: item))
			}
			
			CommonUtils.resultSuccess(call: call, result: result, data: ["nextSeq": String(nextSeq), "memberInfoList": res]);
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	func getGroupMembersInfo(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String;
		let memberList = CommonUtils.getParam(call: call, result: result, param: "memberList") as? Array<String>;
		
		V2TIMManager.sharedInstance()?.getGroupMembersInfo(groupID, memberList: memberList, succ: {
			(array) -> Void in
			
			var res: [[String: Any]] = []
			
			for item in array ?? [] {
				res.append(V2GroupMemberFullInfoEntity.getDict(info: item));
			}
			
			CommonUtils.resultSuccess(call: call, result: result, data: JsonUtil.getDictionaryOrArrayFromObject(res));
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	
	
	func setGroupMemberInfo(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as! String;
		let userID = CommonUtils.getParam(call: call, result: result, param: "userID") as! String;
		let nameCard = CommonUtils.getParam(call: call, result: result, param: "nameCard") as! String;
		let customInfo = CommonUtils.getParam(call: call, result: result, param: "customInfo") as? Dictionary<String, String>;
		var customInfoData: [String: Data] = [:]
		
		if customInfo != nil {
			for (key, value) in customInfo! {
				customInfoData[key] = value.data(using: String.Encoding.utf8, allowLossyConversion: true);
			}
		}
		
		V2TIMManager.sharedInstance()?.getGroupMembersInfo(groupID, memberList: userID.components(separatedBy: ","), succ: {
			(array) -> Void in
			
			var info: V2TIMGroupMemberFullInfo;
			for item in array ?? [] {
				if item.userID == userID {
					info = item
					info.nameCard = nameCard
					info.customInfo = customInfoData
					
					V2TIMManager.sharedInstance()?.setGroupMemberInfo(groupID, info: info, succ: {
						() -> Void in
						
						CommonUtils.resultSuccess(call: call, result: result)
					}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
				}
			}
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	func muteGroupMember(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String;
		let userID = CommonUtils.getParam(call: call, result: result, param: "userID") as? String;
		let seconds = (CommonUtils.getParam(call: call, result: result, param: "seconds") as? UInt32)!;
		
		V2TIMManager.sharedInstance()?.muteGroupMember(groupID, member: userID, muteTime: seconds, succ: {
			() -> Void in
			
			CommonUtils.resultSuccess(call: call, result: result);
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	func inviteUserToGroup(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String;
		let userList = CommonUtils.getParam(call: call, result: result, param: "userList") as? Array<String>;
		
		V2TIMManager.sharedInstance()?.inviteUser(toGroup: groupID, userList: userList, succ: {
			(array) -> Void in
			
			var res: [GroupMemberOperationResultEntity] = []
			
			for item in array! {
				res.append(GroupMemberOperationResultEntity(result: item))
			}
			
			CommonUtils.resultSuccess(call: call, result: result, data: JsonUtil.getDictionaryOrArrayFromObject(res));
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	func kickGroupMember(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String;
		let memberList = CommonUtils.getParam(call: call, result: result, param: "memberList") as? Array<String>;
		let reason = CommonUtils.getParam(call: call, result: result, param: "reason") as? String;
        let duration = (CommonUtils.getParam(call: call, result: result, param: "duration") as? UInt32);
        
		V2TIMManager.sharedInstance()?.kickGroupMember(groupID, memberList: memberList, reason: reason, duration: duration ?? 0,succ: {
			(array) -> Void in
			
			var res: [GroupMemberOperationResultEntity] = []
			
			for item in array ?? [] {
				res.append(GroupMemberOperationResultEntity(result: item))
			}
			
			CommonUtils.resultSuccess(call: call, result: result, data: JsonUtil.getDictionaryOrArrayFromObject(res));
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	func setGroupMemberRole(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String;
		let userID = CommonUtils.getParam(call: call, result: result, param: "userID") as? String;
		let role = CommonUtils.getParam(call: call, result: result, param: "role") as! Int;
		
        V2TIMManager.sharedInstance()?.setGroupMemberRole(groupID, member: userID, newRole: UInt32(V2TIMGroupMemberRole(rawValue: role)!.rawValue), succ: {
			() -> Void in
			
			CommonUtils.resultSuccess(call: call, result: result)
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	func transferGroupOwner(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String;
		let userID = CommonUtils.getParam(call: call, result: result, param: "userID") as? String;
		
		V2TIMManager.sharedInstance()?.transferGroupOwner(groupID, member: userID, succ: {
			() -> Void in
			
			CommonUtils.resultSuccess(call: call, result: result)
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	// 无加群申请，sdk回调不会执行
	func getGroupApplicationList(call: FlutterMethodCall, result: @escaping FlutterResult) {
		V2TIMManager.sharedInstance()?.getGroupApplicationList({
			(info) -> Void in
			
			CommonUtils.resultSuccess(call: call, result: result, data: V2GroupApplicationResultEntity.getDict(info: info!))
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	func acceptGroupApplication(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String;
		let fromUser = CommonUtils.getParam(call: call, result: result, param: "fromUser") as? String;
		let reason = CommonUtils.getParam(call: call, result: result, param: "reason") as? String;
		var application = V2TIMGroupApplication();
		
		V2TIMManager.sharedInstance()?.getGroupApplicationList({
			(array) -> Void in
			
			for item in array?.applicationList ?? [] {
				let app = item as! V2TIMGroupApplication;
				if app.fromUser == fromUser && app.groupID == groupID {
					application = app
				}
			}
			
			V2TIMManager.sharedInstance()?.accept(application, reason: reason, succ: {
				() -> Void in
				
				CommonUtils.resultSuccess(call: call, result: result)
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	func refuseGroupApplication(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String;
		let fromUser = CommonUtils.getParam(call: call, result: result, param: "fromUser") as? String;
		let reason = CommonUtils.getParam(call: call, result: result, param: "reason") as? String;
		var application = V2TIMGroupApplication();
		
		V2TIMManager.sharedInstance()?.getGroupApplicationList({
			(array) -> Void in
			
			for item in array?.applicationList ?? [] {
				let app = item as! V2TIMGroupApplication;
				if app.fromUser == fromUser && app.groupID == groupID {
					application = app
				}
			}
			
			V2TIMManager.sharedInstance()?.refuse(application, reason: reason, succ: {
				() -> Void in
				
				CommonUtils.resultSuccess(call: call, result: result)
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}

	/// 初始化群属性，会清空原有的群属性列表
    public func initGroupAttributes(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String,
           let attributes = CommonUtils.getParam(call: call, result: result, param: "attributes") as? Dictionary<String, String> {
            V2TIMManager.sharedInstance().initGroupAttributes(groupID, attributes: attributes, succ: {
                CommonUtils.resultSuccess(call: call, result: result)
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
        }
    }

	/// 设置群属性
    public func setGroupAttributes(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String,
           let attributes = CommonUtils.getParam(call: call, result: result, param: "attributes") as? Dictionary<String, String> {
            V2TIMManager.sharedInstance().setGroupAttributes(groupID, attributes: attributes, succ: {
                CommonUtils.resultSuccess(call: call, result: result)
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
        }
    }

    /// 删除群属性
    public func deleteGroupAttributes(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let keys = CommonUtils.getParam(call: call, result: result, param: "keys") as? Array<String>;
        if let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String {
            V2TIMManager.sharedInstance().deleteGroupAttributes(groupID, keys: keys, succ: {
                CommonUtils.resultSuccess(call: call, result: result)
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
        }
    }

    /// 获得群属性
    public func getGroupAttributes(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let keys = CommonUtils.getParam(call: call, result: result, param: "keys") as? Array<String>;
        if let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String {
            V2TIMManager.sharedInstance().getGroupAttributes(groupID, keys: keys, succ: {
                dictionary in
				CommonUtils.resultSuccess(call: call, result: result, data: dictionary!)
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
        }
    }
	
	/// 获得群在线人数
	public func getGroupOnlineMemberCount(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String {
			V2TIMManager.sharedInstance().getGroupOnlineMemberCount(groupID, succ: {
				count in
				CommonUtils.resultSuccess(call: call, result: result, data: count)
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}
	
	func setGroupApplicationRead(call: FlutterMethodCall, result: @escaping FlutterResult) {
		V2TIMManager.sharedInstance()?.setGroupApplicationRead({
			() -> Void in
			
			CommonUtils.resultSuccess(call: call, result: result)
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}

	func searchGroups(call: FlutterMethodCall, result: @escaping FlutterResult){
        let searchParam = CommonUtils.getParam(call: call, result: result, param: "searchParam") as! [String: Any];
        let groupSearchParam = V2TIMGroupSearchParam();
        
        if(searchParam["keywordList"] != nil){
            groupSearchParam.keywordList = searchParam["keywordList"] as? [String];
        }
        if(searchParam["isSearchGroupID"] != nil){
            groupSearchParam.isSearchGroupID = searchParam["isSearchGroupID"] as! Bool;
        }
        if(searchParam["isSearchGroupName"] != nil){
            groupSearchParam.isSearchGroupName = searchParam["isSearchGroupName"] as! Bool;
        }
        
            V2TIMManager.sharedInstance().searchGroups(groupSearchParam, succ: {
				array in
                var list = [[String: Any]]();
                for item in array! {
                    list.append( V2GroupInfoEntity.getDict(info: item) );
                }
				CommonUtils.resultSuccess(call: call, result: result, data: list)
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
	}

	func searchGroupMembers(call: FlutterMethodCall, result: @escaping FlutterResult){
        let searchParam = CommonUtils.getParam(call: call, result: result, param: "param") as! [String: Any];
        let groupMemberSearchParam = V2TIMGroupMemberSearchParam();
        
        if(searchParam["keywordList"] as? [String] != nil){
            
            groupMemberSearchParam.keywordList = searchParam["keywordList"] as? [String];
        }
        if(searchParam["groupIDList"] as? [String] != nil){
            
            groupMemberSearchParam.groupIDList = searchParam["groupIDList"] as? [String];
            if groupMemberSearchParam.groupIDList.isEmpty {
                groupMemberSearchParam.groupIDList = nil;
            }
        }
        if(searchParam["isSearchMemberUserID"] as? Bool ?? false){
            
            groupMemberSearchParam.isSearchMemberUserID = searchParam["isSearchMemberUserID"] as! Bool;
        }
        if(searchParam["isSearchMemberNickName"] as? Bool ?? false){
            
            groupMemberSearchParam.isSearchMemberNickName = searchParam["isSearchMemberNickName"] as! Bool;
        }
        if(searchParam["isSearchMemberRemark"] as? Bool ?? false){
            
            groupMemberSearchParam.isSearchMemberRemark = searchParam["isSearchMemberRemark"] as! Bool;
        }
        if(searchParam["isSearchMemberNameCard"] as? Bool ?? false){
            
            groupMemberSearchParam.isSearchMemberNameCard = searchParam["isSearchMemberNameCard"] as! Bool;
        }
        print(groupMemberSearchParam)
            V2TIMManager.sharedInstance().searchGroupMembers(groupMemberSearchParam, succ: {
                (array) -> Void in
                
                var resMap = [String: [Any]]();
                // 第一层Map
                for (key, value) in array! {
                    var tempArr: [Any] = [];
                    // 第二层数组
                    for value01 in value {
                        tempArr.append(V2GroupMemberFullInfoEntity.getDict(info: value01));
                    }
                    resMap.updateValue(tempArr, forKey: key)
                }
                
                CommonUtils.resultSuccess(call: call, result: result, data: resMap)
            }, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
	}
    func setGroupCounters(call: FlutterMethodCall, result: @escaping FlutterResult){
        let counters = CommonUtils.getParam(call: call, result: result, param: "counters") as! [String: NSNumber];
        let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String ;
        V2TIMManager.sharedInstance().setGroupCounters(groupID, counters: counters) { data in
            CommonUtils.resultSuccess(call: call, result: result, data: data as Any)
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    func getGroupCounters(call: FlutterMethodCall, result: @escaping FlutterResult){
        let keys = CommonUtils.getParam(call: call, result: result, param: "keys") as! [String];
        let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String ;
        V2TIMManager.sharedInstance().getGroupCounters(groupID, keys: keys) { data in
            CommonUtils.resultSuccess(call: call, result: result, data: data as Any)
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }
    }
    func increaseGroupCounter(call: FlutterMethodCall, result: @escaping FlutterResult){
        let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String ;
        let key = CommonUtils.getParam(call: call, result: result, param: "key") as? String ;
        let value = CommonUtils.getParam(call: call, result: result, param: "value") as? Int ;
        V2TIMManager.sharedInstance().increaseGroupCounter(groupID, key: key, value: value!) { data in
            CommonUtils.resultSuccess(call: call, result: result, data: data as Any)
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    func decreaseGroupCounter(call: FlutterMethodCall, result: @escaping FlutterResult){
        let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String ;
        let key = CommonUtils.getParam(call: call, result: result, param: "key") as? String ;
        let value = CommonUtils.getParam(call: call, result: result, param: "value") as? Int ;
        V2TIMManager.sharedInstance().decreaseGroupCounter(groupID, key: key, value: value!) { data in
            CommonUtils.resultSuccess(call: call, result: result, data: data as Any)
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }
    }
    func markGroupMemberList(call: FlutterMethodCall, result: @escaping FlutterResult){
        let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String ;
        let memberIDList = CommonUtils.getParam(call: call, result: result, param: "memberIDList") as?  [String] ;
        let markType = (CommonUtils.getParam(call: call, result: result, param: "markType") as? UInt32)! ;
        let enableMark = (CommonUtils.getParam(call: call, result: result, param: "enableMark") as? Bool)! ;
        V2TIMManager.sharedInstance().markGroupMemberList(groupID, memberList: memberIDList, markType: markType, enableMark: enableMark) {
            CommonUtils.resultSuccess(call: call, result: result)
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
 }

