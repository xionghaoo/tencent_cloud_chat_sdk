//
//  SDKManager.swift
//  tencent_im_sdk_plugin
//
//  Created by xingchenhe on 2020/12/24.
//

import Foundation
import ImSDKForMac_Plus
import FlutterMacOS


class SDKManager {
	var channel: FlutterMethodChannel
	
	private var apnsListener = APNSListener();
	
    private var simpleMsgListenerList: [String: SimpleMsgListener] = [:];
    
    private var groupListenerList: [String: GroupListener] = [:];
    
    private var conversationMsgListenerList: [String: ConversationListener] = [:];
    
    
    
    private var signalingListenerList: [String: SignalingListener] = [:];
    
    private var sdkListenerList: [String: SDKListener] = [:];
    
    private var friendShipListenerList: [String: FriendshipListener] = [:];
    public static var uc:UInt32 = 0;
    public static var globalSDKAPPID:Int32 = 0;
    public static var globalUserID = "";
	
//    public var  logListener:V2TIMLogListener;
	init(channel: FlutterMethodChannel) {
		self.channel = channel
	}
    
    public static func getAdvanceMsgListenerList() -> [String] {
        return SDKManager.listenerUuidList;
    }
    public func setComponentUse(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // let encoder = JSONEncoder()
        // let uic = ["UIComponentType":1,"UIStyleType":0]
        // do {
        //     let jsonData = try encoder.encode(uic)
        //     let jsonString = String(data: jsonData, encoding: .utf8)
        //     print(jsonString ?? "")
        //     V2TIMManager.sharedInstance().callExperimentalAPI("reportTUIComponentUsage", param: jsonString! as NSObject, succ: {_ in
                
        //         CommonUtils.resultSuccess(call: call, result: result, data: "set success");
        //     }, fail: {code,desc in
          
        //         CommonUtils.resultFailed(desc: desc, code: code,  call: call, result: result)
        //     })
        // } catch {
        //     CommonUtils.resultFailed(desc: "Error encoding dictionary to JSON", code: 0,  call: call, result: result)
        //     print("Error encoding dictionary to JSON: \(error)")
        // }
        
    }
    public static let communityListener = CommunityListener(listenerUid: "");
    
    static var communityUuidList:[String] = [];
    func addCommunityListener(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let listenerUuid = CommonUtils.getParam(call: call, result: result, param: "listenerUuid") as! String;
        if(SDKManager.communityUuidList.isEmpty){
                    V2TIMManager.sharedInstance().addCommunityListener(listener: SDKManager.communityListener);
                    print("current adapter layer communityListenerList is empty . add listener.");
                }else{
                    print("current adapter layer communityListenerList size is \(SDKManager.communityUuidList.count)")
                }
                SDKManager.communityUuidList.append(listenerUuid)

                CommonUtils.resultSuccess(call: call, result: result, data: "addCommunityListener is done");
    }
    
    func removeCommunityListener(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let listenerUuid = CommonUtils.getParam(call: call, result: result, param: "listenerUuid") as! String;
        if listenerUuid != "" {
            SDKManager.communityUuidList.removeAll { data in
                return data == listenerUuid
            }
            print("remove conversation listener. current message listener size is \(SDKManager.communityUuidList.count)" );
            if(SDKManager.communityUuidList.isEmpty){
                V2TIMManager.sharedInstance().removeCommunityListener(listener: SDKManager.communityListener)
            }
            CommonUtils.resultSuccess(call: call, result: result, data: "remove community is done");
        } else {
            SDKManager.communityUuidList.removeAll();
            V2TIMManager.sharedInstance()?.removeCommunityListener(listener: SDKManager.communityListener)
            CommonUtils.resultSuccess(call: call, result: result, data: "removed all community listener");
        }
    }
	/**
	* 登录
	*/
	public func login(call: FlutterMethodCall, result: @escaping FlutterResult) {
        
		if let userID = CommonUtils.getParam(call: call, result: result, param: "userID") as? String,
		   let userSig = CommonUtils.getParam(call: call, result: result, param: "userSig") as? String  {
			// 登录操作
            
         

			V2TIMManager.sharedInstance().login(
				userID,
				userSig: userSig,
				succ: {
                    
                    SDKManager.globalUserID = userID;
					// self.invokeListener(type: ListenerType.onConnecting, params: nil);
					CommonUtils.resultSuccess(call: call, result: result, data: "login success");
				},
				fail: TencentImUtils.returnErrorClosures(call: call, result: result)
			)
		}
	}
    public func checkAbility(call: FlutterMethodCall, result: @escaping FlutterResult){
        TencentImUtils.checkAbility(call: call, result: result,callback: AbCallback(success: {
            CommonUtils.resultSuccess(call: call, result: result, data: 1);
        }, error: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code,  call: call, result: result)
        }));
    }
	/**
	* 登出
	*/
	public func logout(call: FlutterMethodCall, result: @escaping FlutterResult) {
		V2TIMManager.sharedInstance().logout({
			CommonUtils.resultSuccess(call: call, result: result, data: "logout success");
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}

	/// 获得登录状态
    public func getLoginStatus(call: FlutterMethodCall, result: @escaping FlutterResult) {
		CommonUtils.resultSuccess(call: call, result: result, data: V2TIMManager.sharedInstance().getLoginStatus().rawValue);
    }
	
	/**
	* 初始化本地存储
	*/
	public func initStorage(call: FlutterMethodCall, result: @escaping FlutterResult) {
		// if let identifier = CommonUtils.getParam(call: call, result: result, param: "identifier") as? String {
		//     V2TIMManager.sharedInstance().initStorage(identifier, succ: {
		//         result("777");
		//     }, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
		// }
	}
	
	/**
	* 获取版本号
	*/
	public func getVersion(call: FlutterMethodCall, result: @escaping FlutterResult) {
        CommonUtils.resultSuccess(call: call, result: result, data: V2TIMManager.sharedInstance().getVersion() as Any);
	}
	
	/**
	* 获取服务器时间
	*/
	public func getServerTime(call: FlutterMethodCall, result: @escaping FlutterResult) {
		CommonUtils.resultSuccess(call: call, result: result, data: V2TIMManager.sharedInstance().getServerTime());
	}
	
	/**
	* 获取登录用户
	*/
	public func getLoginUser(call: FlutterMethodCall, result: @escaping FlutterResult) {
        CommonUtils.resultSuccess(call: call, result: result, data: V2TIMManager.sharedInstance().getLoginUser() as Any);
	}
	
	/**
	* 获取版本号
	*/
	public func unInitSDK(call: FlutterMethodCall, result: @escaping FlutterResult) {
		CommonUtils.resultSuccess(call: call, result: result, data:"");
	}
	

	
	/**
	* 初始化腾讯云IM，TODO：config需要配置更多信息
	*/
    static let sdkListenerv2 = SDKListener(listenerUid: "");
    
	public func initSDK(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let listenerUuid = CommonUtils.getParam(call: call, result: result, param: "listenerUuid") as! String;
		let uiPlatform = 27;
        
		if let sdkAppID = CommonUtils.getParam(call: call, result: result, param: "sdkAppID") as? Int32,
		   let logLevel = CommonUtils.getParam(call: call, result: result, param: "logLevel") as? Int {
            V2TIMManager.sharedInstance().callExperimentalAPI("setUIPlatform",param: uiPlatform as NSObject,succ:{_ in
				let config = V2TIMSDKConfig()
				
					
				config.logLevel = V2TIMLogLevel(rawValue: logLevel)!
          
                V2TIMManager.sharedInstance().remove(SDKManager.sdkListenerv2)
                V2TIMManager.sharedInstance().add(SDKManager.sdkListenerv2);
                
                let data = V2TIMManager.sharedInstance().initSDK(sdkAppID, config: config);
				
                SDKManager.globalSDKAPPID = sdkAppID;
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
                let lapath = documentDirectory.path;
                print("important message current download dir is \(lapath)");
				CommonUtils.resultSuccess(call: call, result: result, data: data);
            },fail:{_,_ in 
				CommonUtils.resultSuccess(call: call, result: result, data: false);
			});
			
			
		}
	}
	
    static let conversationListenerv2 = ConversationListener(listenerUid: "");
    static var conversationUuidList:[String] = [];
	public func setConversationListener(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let listenerUuid = CommonUtils.getParam(call: call, result: result, param: "listenerUuid") as! String;
        if(SDKManager.conversationUuidList.isEmpty){
            V2TIMManager.sharedInstance().addConversationListener(listener:SDKManager.conversationListenerv2);
            print("current adapter layer conversationUuidList is empty . add listener.");
        }else{
            print("current adapter layer conversationUuidList size is \(SDKManager.conversationUuidList.count)")
        }
        SDKManager.conversationUuidList.append(listenerUuid)

        CommonUtils.resultSuccess(call: call, result: result, data: "addConversationListener is done");
	}

	public func addConversationListener(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let listenerUuid = CommonUtils.getParam(call: call, result: result, param: "listenerUuid") as! String;
        if(SDKManager.conversationUuidList.isEmpty){
            V2TIMManager.sharedInstance().addConversationListener(listener:SDKManager.conversationListenerv2);
            print("current adapter layer conversationUuidList empty . add listener.");
        }else{
            print("current adapter layer conversationUuidList size is \(SDKManager.conversationUuidList.count)")
        }
        SDKManager.conversationUuidList.append(listenerUuid)

        CommonUtils.resultSuccess(call: call, result: result, data: "addConversationListener is done");
	}
	
	public func removeConversationListener(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let listenerUuid = CommonUtils.getParam(call: call, result: result, param: "listenerUuid") as! String;
        if listenerUuid != "" {
            SDKManager.conversationUuidList.removeAll { data in
                return data == listenerUuid
            }
            print("remove conversation listener. current message listener size is \(SDKManager.conversationUuidList.count)" );
            if(SDKManager.listenerUuidList.isEmpty){
                V2TIMManager.sharedInstance().removeConversationListener(listener: SDKManager.conversationListenerv2)
            }
            CommonUtils.resultSuccess(call: call, result: result, data: "removeConversationListener is done");
        } else {
            SDKManager.conversationUuidList.removeAll();
            V2TIMManager.sharedInstance()?.removeConversationListener(listener: SDKManager.conversationListenerv2)
            CommonUtils.resultSuccess(call: call, result: result, data: "removed all conversation listener");
        }
	}

	public func removeGroupListener(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let listenerUuid = CommonUtils.getParam(call: call, result: result, param: "listenerUuid") as! String;
        if listenerUuid != "" {
            let listener = groupListenerList[listenerUuid];
            V2TIMManager.sharedInstance().removeGroupListener(listener: listener);
            groupListenerList.removeValue(forKey: listenerUuid);
            CommonUtils.resultSuccess(call: call, result: result, data: "removeGroupListener is done");
        } else {
            for listener in groupListenerList {
                let callback = listener.value;
                V2TIMManager.sharedInstance().removeGroupListener(listener: callback);

            }
            groupListenerList = [:];
            CommonUtils.resultSuccess(call: call, result: result, data: "removed groupListener conversationListener");
        }
	}
    
    static let messageListenerv2 = AdvancedMsgListener(listenerUid: "");
    static var listenerUuidList:[String] = [];
	public func addAdvancedMsgListener(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let listenerUuid = CommonUtils.getParam(call: call, result: result, param: "listenerUuid") as! String;
        if(SDKManager.listenerUuidList.isEmpty){
            V2TIMManager.sharedInstance()?.addAdvancedMsgListener(listener: SDKManager.messageListenerv2)
            print("current adapter layer messagelistenerUuidList is empty . add listener.");
        }else{
            print("current adapter layer messagelistenerUuidList size is \(SDKManager.listenerUuidList.count)")
        }
        SDKManager.listenerUuidList.append(listenerUuid)

		CommonUtils.resultSuccess(call: call, result: result, data: "addAdvancedMsgListener is done");
	}

	public func removeAdvancedMsgListener(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let listenerUuid = CommonUtils.getParam(call: call, result: result, param: "listenerUuid") as! String;
        if listenerUuid != "" {
            SDKManager.listenerUuidList.removeAll { data in
                return data == listenerUuid
            }
            print("remove message listener. current message listener size is \(SDKManager.listenerUuidList.count)" );
            if(SDKManager.listenerUuidList.isEmpty){
                print("remove add message listener" );
                V2TIMManager.sharedInstance()?.removeAdvancedMsgListener(listener: SDKManager.messageListenerv2)
            }
            CommonUtils.resultSuccess(call: call, result: result, data: "removeAdvancedMsgListener is done");
        } else {
            print("remove add message listener for else");
            SDKManager.listenerUuidList.removeAll();
            V2TIMManager.sharedInstance()?.removeAdvancedMsgListener(listener: SDKManager.messageListenerv2)
            CommonUtils.resultSuccess(call: call, result: result, data: "removed all listener");
        }
	}
    static let friendListenerv2 = FriendshipListener(listenerUid: "");
    static var friendListenerUuidList:[String] = [];
    
	public func setFriendListener(call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        let listenerUuid = CommonUtils.getParam(call: call, result: result, param: "listenerUuid") as! String;
        if(SDKManager.friendListenerUuidList.isEmpty){
            V2TIMManager.sharedInstance()?.addFriendListener(listener: SDKManager.friendListenerv2)
            print("current adapter layer friendListenerUuidList is empty . add listener.");
        }else{
            print("current adapter layer friendListenerUuidList size is \(SDKManager.friendListenerUuidList.count)")
        }
        SDKManager.friendListenerUuidList.append(listenerUuid)

        CommonUtils.resultSuccess(call: call, result: result, data: "setFriendListener is done");
	}

	public func addFriendListener(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let listenerUuid = CommonUtils.getParam(call: call, result: result, param: "listenerUuid") as! String;
        if(SDKManager.friendListenerUuidList.isEmpty){
            V2TIMManager.sharedInstance()?.addFriendListener(listener: SDKManager.friendListenerv2)
            print("current adapter layer friendListenerUuidList is empty . add listener.");
        }else{
            print("current adapter layer friendListenerUuidList size is \(SDKManager.friendListenerUuidList.count)")
        }
        SDKManager.friendListenerUuidList.append(listenerUuid)

        CommonUtils.resultSuccess(call: call, result: result, data: "addFriendListener is done");
	}
    
    
    static let groupListenerv2 = GroupListener(listenerUid: "");
    static var groupListenerUuidList:[String] = [];
	public func addGroupListener(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let listenerUuid = CommonUtils.getParam(call: call, result: result, param: "listenerUuid") as! String;
        if(SDKManager.groupListenerUuidList.isEmpty){
            V2TIMManager.sharedInstance()?.addGroupListener(listener: SDKManager.groupListenerv2)
            print("current adapter layer groupListenerUuidList is empty . add listener.");
        }else{
            print("current adapter layer groupListenerUuidList size is \(SDKManager.groupListenerUuidList.count)")
        }
        SDKManager.groupListenerUuidList.append(listenerUuid)

        CommonUtils.resultSuccess(call: call, result: result, data: "addGroupListener is done");
	}
	
	public func removeFriendListener(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let listenerUuid = CommonUtils.getParam(call: call, result: result, param: "listenerUuid") as! String;
        if listenerUuid != "" {
            SDKManager.friendListenerUuidList.removeAll { data in
                return data == listenerUuid
            }
            print("remove friend listener. current message listener size is \(SDKManager.friendListenerUuidList.count)" );
            if(SDKManager.friendListenerUuidList.isEmpty){
                V2TIMManager.sharedInstance()?.removeFriendListener(listener: SDKManager.friendListenerv2)
            }
            CommonUtils.resultSuccess(call: call, result: result, data: "removeFriendListener is done");
        } else {
            SDKManager.friendListenerUuidList.removeAll();
            V2TIMManager.sharedInstance()?.removeFriendListener(listener: SDKManager.friendListenerv2)
            CommonUtils.resultSuccess(call: call, result: result, data: "removed all listener");
        }
	}
    public func doBackground(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let unreadCount = CommonUtils.getParam(call: call, result: result, param: "unreadCount") as! UInt32;
        SDKManager.uc = unreadCount
        CommonUtils.resultSuccess(call: call, result: result)
    }
    public func doForeground(call: FlutterMethodCall, result: @escaping FlutterResult) {
        SDKManager.uc = 0
        CommonUtils.resultSuccess(call: call, result: result)
    }
    
	public func setGroupListener(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let listenerUuid = CommonUtils.getParam(call: call, result: result, param: "listenerUuid") as! String;
        if(SDKManager.groupListenerUuidList.isEmpty){
            V2TIMManager.sharedInstance()?.addGroupListener(listener: SDKManager.groupListenerv2)
            print("current adapter layer groupListenerUuidList is empty . add listener.");
        }else{
            print("current adapter layer groupListenerUuidList size is \(SDKManager.groupListenerUuidList.count)")
        }
        SDKManager.groupListenerUuidList.append(listenerUuid)

        CommonUtils.resultSuccess(call: call, result: result, data: "addGroupListener is done");
	}
	
	public func setAPNSListener(call: FlutterMethodCall, result: @escaping FlutterResult) {
		V2TIMManager.sharedInstance().setAPNSListener(apnsListener)
		CommonUtils.resultSuccess(call: call, result: result, data: "setAPNSListener is done")
	}
    static let signalListenerv2 = SignalingListener(listenerUid: "");
    static var signalListenerUuidList:[String] = [];
	public func addSignalingListener(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let listenerUuid = CommonUtils.getParam(call: call, result: result, param: "listenerUuid") as! String;
        if(SDKManager.signalListenerUuidList.isEmpty){
            V2TIMManager.sharedInstance()?.addSignalingListener(listener: SDKManager.signalListenerv2)
            print("current adapter layer signalListenerUuidList is empty . add listener.");
        }else{
            print("current adapter layer signalListenerUuidList size is \(SDKManager.signalListenerUuidList.count)")
        }
        SDKManager.signalListenerUuidList.append(listenerUuid)

        CommonUtils.resultSuccess(call: call, result: result, data: "addSignalingListener is done");
	}
	
	public func removeSignalingListener(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let listenerUuid = CommonUtils.getParam(call: call, result: result, param: "listenerUuid") as! String;
        if listenerUuid != "" {
            SDKManager.signalListenerUuidList.removeAll { data in
                return data == listenerUuid
            }
            print("remove signal listener. current message listener size is \(SDKManager.signalListenerUuidList.count)" );
            if(SDKManager.signalListenerUuidList.isEmpty){
                V2TIMManager.sharedInstance()?.removeSignalingListener(listener: SDKManager.signalListenerv2)
            }
            CommonUtils.resultSuccess(call: call, result: result, data: "removeFriendListener is done");
        } else {
            SDKManager.signalListenerUuidList.removeAll();
            V2TIMManager.sharedInstance()?.removeSignalingListener(listener: SDKManager.signalListenerv2)
            CommonUtils.resultSuccess(call: call, result: result, data: "removed all listener");
        }
	}
	
	public func addSimpleMsgListener(call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        CommonUtils.resultFailed(desc: "addSimpleMsgListener is not support. use advanced message listener instead.",code: -1, call: call, result: result);
	}

	public func removeSimpleMsgListener(call: FlutterMethodCall, result: @escaping FlutterResult) {
        CommonUtils.resultFailed(desc: "removeSimpleMsgListener is not support. use advanced message listener instead.",code: -1, call: call, result: result);
	}

	
	
	public func setAPNS(call: FlutterMethodCall, result: @escaping FlutterResult) {
        TencentImUtils.checkAbility(call: call, result: result, callback: AbCallback(success: {
            if let businessID = CommonUtils.getParam(call: call, result: result, param: "businessID") as? Int32,
                let token = CommonUtils.getParam(call: call, result: result, param: "token") as? String,
                let isTPNSToken = CommonUtils.getParam(call: call, result: result, param: "isTPNSToken") as? Bool {
                let config = V2TIMAPNSConfig()
                
                if(isTPNSToken){
                    config.token = token.data(using: String.Encoding.utf8, allowLossyConversion: true)
                }else{
                    config.token = token.hexadecimal()
                }
                
                config.businessID = businessID
                // config.isTPNSToken = isTPNSToken;
                V2TIMManager.sharedInstance().setAPNS(config, succ: {
                    CommonUtils.resultSuccess(call: call, result: result);
                }, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
            }
        }, error: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }))
	}

	public func getUsersInfo(call: FlutterMethodCall, result: @escaping FlutterResult) { 
		let userIDList = CommonUtils.getParam(call: call, result: result, param: "userIDList") as? Array<String>;
		
		V2TIMManager.sharedInstance()?.getUsersInfo(userIDList, succ: {
			(array) -> Void in
			
			var res: [[String: Any]] = []
			
			for info in array ?? [] {
				let item = V2UserFullInfoEntity.getDict(info: info)
				res.append(item)
			}
			
			CommonUtils.resultSuccess(call: call, result: result, data: res);
			
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	public func callExperimentalAPI(call: FlutterMethodCall, result: @escaping FlutterResult) {
       if let api = CommonUtils.getParam(call: call, result: result, param: "api") as? String,
          let param = CommonUtils.getParam(call: call, result: result, param: "param") as? NSObject{
           V2TIMManager.sharedInstance().callExperimentalAPI(api, param: param as NSObject?, succ: {value in
            CommonUtils.resultSuccess(call: call, result: result, data: value as Any);
        }, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
       }
       
	}

	public func setUnreadCount(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let unreadCount = CommonUtils.getParam(call: call, result: result, param: "unreadCount") as? UInt32 {
			APNSListener.count = unreadCount
		}
	}
    public func getUserStatus(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let userIDList:[String] = CommonUtils.getParam(call: call, result: result, param: "userIDList") as! [String];
        
        V2TIMManager.sharedInstance().getUserStatus(userIDList) { statusList in
            var res: [[String: Any]] = []
            statusList?.forEach({ status in
                var item: [String: Any] = [:]
                item["customStatus"] = status.customStatus ?? "";
                item["statusType"] = status.statusType.rawValue;
                item["userID"] = status.userID;
                res.append(item)
            })
            print(res)
            CommonUtils.resultSuccess(desc: "ok", call: call, result: result, data: res)
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    public func setSelfStatus(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let status = CommonUtils.getParam(call: call, result: result, param: "status") as? String;
        let s = V2TIMUserStatus();
        s.customStatus = status;
        V2TIMManager.sharedInstance().setSelfStatus(s) {
            CommonUtils.resultSuccess(call: call, result: result)
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }
    }
    
    
	public func setSelfInfo(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let nickName = CommonUtils.getParam(call: call, result: result, param: "nickName") as? String;
		let faceURL = CommonUtils.getParam(call: call, result: result, param: "faceUrl") as? String;
		let selfSignature = CommonUtils.getParam(call: call, result: result, param: "selfSignature") as? String;
		let gender = CommonUtils.getParam(call: call, result: result, param: "gender") as? Int;
		let allowType = CommonUtils.getParam(call: call, result: result, param: "allowType") as? Int;
		let birthday = CommonUtils.getParam(call: call, result: result, param: "birthday") as? UInt32;
		let level = CommonUtils.getParam(call: call, result: result, param: "level") as? UInt32;
		let role = CommonUtils.getParam(call: call, result: result, param: "role") as? UInt32;
		let customInfo = CommonUtils.getParam(call: call, result: result, param: "customInfo") as? Dictionary<String, String>;
		var customInfoData: [String: Data] = [:]
		
        let info = V2TIMUserFullInfo();
		if nickName != nil {
			info.nickName = nickName
		}
		if faceURL != nil {
			info.faceURL = faceURL
		}
		if selfSignature != nil {
			info.selfSignature = selfSignature
		}
		if gender != nil {
			info.gender = V2TIMGender(rawValue: gender!)!
		}
		if allowType != nil {
			info.allowType = V2TIMFriendAllowType(rawValue: allowType!)!
		}
		if birthday != nil {
            info.birthday = birthday!
		}
		if level != nil {
            info.level = level!
		}
		if role != nil {
            info.role = role!
		}
		if customInfo != nil {
            for (key, value) in customInfo ?? [:] {
				customInfoData[key] = value.data(using: String.Encoding.utf8, allowLossyConversion: true);
			}
			info.customInfo = customInfoData
		}
		
		V2TIMManager.sharedInstance()?.setSelfInfo(info, succ: {
			() -> Void in
			
			CommonUtils.resultSuccess(call: call, result: result)
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
    public func subscribeUserStatus(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let userIDList:[String] = CommonUtils.getParam(call: call, result: result, param: "userIDList") as! [String];
        V2TIMManager.sharedInstance().subscribeUserStatus(userIDList) {
            CommonUtils.resultSuccess(call: call, result: result)
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    public func unsubscribeUserStatus(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let userIDList:[String] = CommonUtils.getParam(call: call, result: result, param: "userIDList") as! [String];
        V2TIMManager.sharedInstance().unsubscribeUserStatus(userIDList) {
            CommonUtils.resultSuccess(call: call, result: result)
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }
    }
    public func subscribeUserInfo(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let userIDList:[String] = CommonUtils.getParam(call: call, result: result, param: "userIDList") as! [String];
        V2TIMManager.sharedInstance().subscribeUserInfo(userIDList) {
            CommonUtils.resultSuccess(call: call, result: result)
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    public func unsubscribeUserInfo(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let userIDList:[String] = CommonUtils.getParam(call: call, result: result, param: "userIDList") as! [String];
        V2TIMManager.sharedInstance().unsubscribeUserInfo(userIDList) {
            CommonUtils.resultSuccess(call: call, result: result)
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }
    }
    public func setVOIP(call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        if let businessID = CommonUtils.getParam(call: call, result: result, param: "businessID") as? Int,
            let token = CommonUtils.getParam(call: call, result: result, param: "token") as? String {
            let config = V2TIMVOIPConfig()
            
            config.token = token.hexadecimal()
            
            config.certificateID = businessID
            
            V2TIMManager.sharedInstance().setVOIP(config, succ: {
                CommonUtils.resultSuccess(call: call, result: result);
            }, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
        }
    }
    public func uikitTrace(call: FlutterMethodCall, result: @escaping FlutterResult) {
         let trace = CommonUtils.getParam(call: call, result: result, param: "trace") as? String;
         let dict = NSMutableDictionary()
         dict["logLevel"] = NSNumber(value: V2TIMLogLevel.LOG_INFO.rawValue)
         dict["fileName"] = "IMFlutterUIKit"
         dict["logContent"] = trace;
         do {
             if let dataParam = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) {
                 if let strParam = String(data: dataParam, encoding: .utf8) as NSString? {
                    
                     DispatchQueue.global().async {
                         V2TIMManager.sharedInstance().callExperimentalAPI("writeLog", param: strParam) { res in
                             result("")
                         } fail: { code, desc in
                             result("")
                         }
                     }
                 }
             }
         }
    }
}


extension String {

	/// Create `Data` from hexadecimal string representation
	///
	/// This takes a hexadecimal representation and creates a `Data` object. Note, if the string has any spaces or non-hex characters (e.g. starts with '<' and with a '>'), those are ignored and only hex characters are processed.
	///
	/// - returns: Data represented by this hexadecimal string.

	func hexadecimal() -> Data? {
		var data = Data(capacity: count / 2)

		let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
		regex.enumerateMatches(in: self, range: NSMakeRange(0, utf16.count)) { match, flags, stop in
			let byteString = (self as NSString).substring(with: match!.range)
			var num = UInt8(byteString, radix: 16)!
			data.append(&num, count: 1)
		}

		guard data.count > 0 else { return nil }

		return data
	}

}
