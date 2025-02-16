//
//  MessageManager.swift
//  tencent_im_sdk_plugin
//
//  Created by xingchenhe on 2020/12/24.
//

import Foundation
import ImSDKForMac_Plus
import Hydra
import FlutterMacOS

class MessageManager {
	var channel: FlutterMethodChannel
    // 存放创建出的临时消息
     var messageDict =  [String: V2TIMMessage]()
    static var downloadingMessageList:[String] = [];
    
    static var groupidList:[String] = []
    static var messageList:[V2TIMMessage] = []
    static var eachGroupMessageNums:Int = 20;
    // let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    
    
    
	init(channel: FlutterMethodChannel) {
		self.channel = channel
	}
     func clearMessageMap(id:String? = nil){
        if( id != nil){
            messageDict.removeValue(forKey: id!);
        }
    }
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    func getMessageMapId() -> String{
        let timeInterval = Date().timeIntervalSince1970;
        let millisecond = CLongLong(round(timeInterval*1000));
        return String(millisecond) + randomString(length: 10);
    }

	func sendC2CTextMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let text = CommonUtils.getParam(call: call, result: result, param: "text") as? String;
		let userID = CommonUtils.getParam(call: call, result: result, param: "userID") as? String;
		
		let msgID = V2TIMManager.sharedInstance()?.sendC2CTextMessage(text, to: userID , succ: {
			() -> Void in
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
		
        if msgID != nil {

            getMessageByID(msgid: msgID ?? "", cb: GetMessageCallback(success: { msg in
                var data = V2MessageEntity.init(message: msg).getDict()
                data["progress"] = 100
                data["status"] = 2
                CommonUtils.resultSuccess(call: call, result: result, data: data)
            }, error: { code, desc in
                CommonUtils.resultFailed(desc:desc, code: code, call: call, result: result)
            }))
		}
	}
    func getElem(message:V2TIMMessage) -> V2TIMElem {
        let type = message.elemType;
        if(type == V2TIMElemType.ELEM_TYPE_TEXT){
            return message.textElem;
        } else if(type == V2TIMElemType.ELEM_TYPE_CUSTOM){
            return message.customElem;
        } else if(type == V2TIMElemType.ELEM_TYPE_FACE){
            return message.faceElem
        } else if(type == V2TIMElemType.ELEM_TYPE_FILE){
            return message.fileElem
        } else if(type == V2TIMElemType.ELEM_TYPE_GROUP_TIPS){
            return message.groupTipsElem
        } else if(type == V2TIMElemType.ELEM_TYPE_IMAGE){
            return message.imageElem
        } else if(type == V2TIMElemType.ELEM_TYPE_LOCATION){
            return message.locationElem
        } else if(type == V2TIMElemType.ELEM_TYPE_MERGER){
            return message.mergerElem
        } else if(type == V2TIMElemType.ELEM_TYPE_SOUND){
            return message.soundElem
        } else if(type == V2TIMElemType.ELEM_TYPE_VIDEO){
            return message.videoElem
        } else{
            return message.textElem
        }
       
    }
    func setAppendMessage(appendMess:V2TIMMessage,baseMessage:V2TIMMessage){
        let bElem = getElem(message: baseMessage)
        let Aelem = getElem(message: appendMess)
        bElem.append(Aelem)
    }
    func appendMessage(call: FlutterMethodCall, result: @escaping FlutterResult){
        let createMessageBaseId = CommonUtils.getParam(call: call, result: result, param: "createMessageBaseId") as? String ?? "";
        let createMessageAppendId = CommonUtils.getParam(call: call, result: result, param: "createMessageAppendId") as? String ?? "";
        
        if(messageDict.keys.contains(createMessageBaseId) && messageDict.keys.contains(createMessageAppendId)){
            let baseMessage = messageDict[createMessageBaseId]!
            let appendMessage = messageDict[createMessageAppendId]!
            setAppendMessage(appendMess: appendMessage,baseMessage: baseMessage)
            CommonUtils.resultSuccess(desc: "ok", call: call, result: result, data: V2MessageEntity.init(message: baseMessage).getDict())
        }else {
            CommonUtils.resultFailed(desc: "message not found", code: -1, call: call, result: result)
        }
    }
    
    func modifyMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let message = CommonUtils.getParam(call: call, result: result, param: "message") as? [String:Any] ;
        let msgID = message?["msgID"]
        if(msgID == nil){
            CommonUtils.resultFailed(desc: "message not found", code: -1, call: call,result: result)
            return
        }
        var msgIDList:[String] = [];
        
        msgIDList.append(msgID as! String)
        
        V2TIMManager.sharedInstance().findMessages(msgIDList) { messages in
            if(messages?.count == 1){
                
                if(message?["cloudCustomData"] != nil){
                    messages?[0].cloudCustomData = (message?["cloudCustomData"]  as! String).data(using: .utf8)
                }
                if(message?["localCustomInt"] != nil){
                    messages?[0].localCustomInt = message?["localCustomInt"] as! Int32
                }
                if(message?["localCustomData"] != nil){
                    messages?[0].localCustomData = (message?["localCustomData"] as! String ).data(using: .utf8)
                }
                if(messages?[0].elemType == V2TIMElemType.ELEM_TYPE_TEXT){
                    let textElem:[String:String] = message?["textElem"] as! [String : String];
                    messages?[0].textElem.text = textElem["text"];
                }
                if(messages?[0].elemType == V2TIMElemType.ELEM_TYPE_CUSTOM){
                    let customElem:[String:Any] = message?["customElem"] as! [String : Any];
                    messages?[0].customElem.data = (customElem["data"] as? String)?.data(using: .utf8)
                    messages?[0].customElem.desc = customElem["desc"]  as? String
                    messages?[0].customElem.ext = customElem["extension"] as? String ;
                }
                
                async({
                    _ -> Int in
                    
                   V2TIMManager.sharedInstance().modifyMessage(messages?[0]) { code,desc,modifyedMessage  in
                        
                        var res:[String:Any] = [:]
                        res["code"] = code
                        res["desc"] = desc
                        res["message"] = V2MessageEntity.init(message: modifyedMessage!).getDict()
                        
                        
                        CommonUtils.resultSuccess(call: call, result: result, data: res)
                    }
                    return 1
                }).then({
                    value in
                })
                
            }else{
                CommonUtils.resultFailed(desc: "message not found", code: -1, call: call,result: result)
            }
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call,result: result)
        }


    }
	func sendC2CCustomMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let customData = CommonUtils.getParam(call: call, result: result, param: "customData") as? String;
		let userID = CommonUtils.getParam(call: call, result: result, param: "userID") as? String;
        let data = customData?.data(using: String.Encoding.utf8, allowLossyConversion: true);
		
        var msgID = "";
		let id = V2TIMManager.sharedInstance()?.sendC2CCustomMessage(data, to: userID, succ: {
			() -> Void in
			
            V2TIMManager.sharedInstance()?.findMessages([msgID], succ: {
                (msgs) -> Void in
				if msgs?.count != nil && msgs?.count != 0 {
                    let dict = V2MessageEntity.init(message: msgs![0]).getDict()
					CommonUtils.resultSuccess(call: call, result: result, data: dict)
				} else {
					CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, call: call, result: result)
				}
            }, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
        if(id != nil){
			msgID = id!
		}
        
	}
	
	func sendGroupTextMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let text = CommonUtils.getParam(call: call, result: result, param: "text") as! String;
		let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as! String;
		let priority = CommonUtils.getParam(call: call, result: result, param: "priority") as! Int;
		var msgid = "";
		
		let msgID = V2TIMManager.sharedInstance()?.sendGroupTextMessage(text, to: groupID, priority: V2TIMMessagePriority(rawValue: priority)!, succ: {
			() -> Void in
			let msg = TencentImUtils.createMessage(call: call, result: result, type: 1);
			var data = V2MessageEntity.init(message: msg).getDict()
			data["text"] = text
			data["progress"] = 100
			data["status"] = 2
			data["msgID"] = msgid;
			data["groupID"] = groupID;
			data["priority"] = priority;
			data["sender"] = V2TIMManager.sharedInstance()?.getLoginUser();
			CommonUtils.resultSuccess(call: call, result: result, data: data)
			
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
		
        if(msgID != nil){
            msgid = msgID!;
        }
		
	}
	
	func sendGroupCustomMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let customData = CommonUtils.getParam(call: call, result: result, param: "customData") as! String;
		let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as! String;
		let priority = CommonUtils.getParam(call: call, result: result, param: "priority") as! Int;
		let data = customData.data(using: String.Encoding.utf8, allowLossyConversion: true);
		
		V2TIMManager.sharedInstance()?.sendGroupCustomMessage(data, to: groupID, priority: V2TIMMessagePriority(rawValue: priority)!, succ: {
			() -> Void in
			
			CommonUtils.resultSuccess(call: call, result: result)
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result) );
	}
    func setMessageMapProcess(call: FlutterMethodCall, result: @escaping FlutterResult,message: V2TIMMessage){
        let millisecond = self.getMessageMapId();
        messageDict.updateValue(message, forKey: millisecond);
        
        var resultDict =  [String: Any]();
        var dict = V2MessageEntity.init(message: message).getDict();
        dict["id"] = millisecond;
        
        resultDict.updateValue(millisecond, forKey: "id");
        resultDict.updateValue(dict, forKey: "messageInfo");
        
        CommonUtils.resultSuccess(call: call, result: result,data: resultDict);
    }
    
    func createMessageProcess(call: FlutterMethodCall, result: @escaping FlutterResult, type: Int){
        let message = TencentImUtils.createMessage(call: call, result: result, type: type);
        setMessageMapProcess(call: call, result: result, message: message);
    }

	func createTargetedGroupMessage(call: FlutterMethodCall, result: @escaping FlutterResult){
        if let receiverIDList = CommonUtils.getParam(call: call, result: result, param: "receiverList") as? [String],
           let id = CommonUtils.getParam(call: call, result: result, param: "id") as? String {
            let message = messageDict[id];
            
            let array: NSMutableArray = [];
            
            for receiverId in receiverIDList  {
                array.add(receiverId)
            }

            let newMsg = V2TIMManager.sharedInstance()?.createTargetedGroupMessage(message, receiverList: array)
        self.clearMessageMap(id: id);
        setMessageMapProcess(call: call, result: result, message: newMsg ?? V2TIMMessage());
        }
    }
    
    func createTextMessage(call: FlutterMethodCall, result: @escaping FlutterResult, type: Int) {
        createMessageProcess(call: call, result: result, type: type);
    }
    
    func createCustomMessage(call: FlutterMethodCall, result: @escaping FlutterResult, type: Int) {
        createMessageProcess(call: call, result: result, type: type);
    }
    
    func createImageMessage(call: FlutterMethodCall, result: @escaping FlutterResult, type: Int) {
        createMessageProcess(call: call, result: result, type: type);
    }
    
    func createSoundMessage(call: FlutterMethodCall, result: @escaping FlutterResult, type: Int) {
        createMessageProcess(call: call, result: result, type: type);
    }
    
    func createVideoMessage(call: FlutterMethodCall, result: @escaping FlutterResult, type: Int) {
        createMessageProcess(call: call, result: result, type: type);
    }
    func createFileMessage(call: FlutterMethodCall, result: @escaping FlutterResult, type: Int) {
        createMessageProcess(call: call, result: result, type: type);
    }
    func createTextAtMessage(call: FlutterMethodCall, result: @escaping FlutterResult, type: Int) {
        createMessageProcess(call: call, result: result, type: type);
    }
    
    func createLocationMessage(call: FlutterMethodCall, result: @escaping FlutterResult, type: Int) {
        createMessageProcess(call: call, result: result, type: type);
    }
    
    func createFaceMessage(call: FlutterMethodCall, result: @escaping FlutterResult, type: Int) {
        createMessageProcess(call: call, result: result, type: type);
    }
    
    

    func sendMessageOldEdition(call: FlutterMethodCall, result: @escaping FlutterResult, message: V2TIMMessage, id: String? = nil) {
		let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String;
		let receiver = CommonUtils.getParam(call: call, result: result, param: "receiver") as? String;
		let priority = CommonUtils.getParam(call: call, result: result, param: "priority") as? Int;
		let onlineUserOnly = CommonUtils.getParam(call: call, result: result, param: "onlineUserOnly") as? Bool;
        let v2TIMOfflinePushInfo = CommonUtils.getV2TIMOfflinePushInfo(call: call, result: result);
        let listenerList = SDKManager.getAdvanceMsgListenerList();
		let succ = {
			() -> Void in
            var _data = V2MessageEntity.init(message: message).getDict();
            _data["priority"] = priority;
            _data["id"] = id;
            self.clearMessageMap(id: id);
            CommonUtils.resultSuccess(call: call, result: result, data: _data)
		}
		
		let progressfn = {
			progress -> Void in
			
            var msg = V2MessageEntity.init(message: message).getDict();
            msg["id"] = id; // 只有progress时需要传递id
            msg["progress"] = progress;
            for items in listenerList {
                TencentCloudChatSdkPlugin.invokeListener(
                    type: ListenerType.onSendMessageProgress, method: "advancedMsgListener",
                    data: ["progress": progress, "message": msg], listenerUuid: items
                )
            }
		} as V2TIMProgress
		
		let fail = {
			(code: Int32, desc: Optional<String>) -> Void in
			
            var _data = V2MessageEntity.init(message: message).getDict();
            _data["id"] = id;
            _data["status"] = V2TIMMessageStatus.MSG_STATUS_SEND_FAIL.rawValue;
            self.clearMessageMap(id: id);
            CommonUtils.resultFailed(desc: desc, code: code, data: _data, call: call, result: result)
		}
		
		V2TIMManager.sharedInstance()?.send(
			message,
			receiver: receiver ?? message.userID,
			groupID: groupID ?? message.groupID,
			priority: V2TIMMessagePriority(rawValue: priority ?? 0)!,
			onlineUserOnly: onlineUserOnly ?? false,
			offlinePushInfo: v2TIMOfflinePushInfo,
			progress: progressfn,
			succ: succ,
			fail: fail
		);
	}
    
    func sendMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let id = CommonUtils.getParam(call: call, result: result, param: "id") as! String; // 自定义id
        if let message = messageDict[id] {
            self.setCustomDataBeforSend(call: call, result: result, message: message);
            sendMessageOldEdition(call: call, result: result, message: message, id: id);
        } else {
            CommonUtils.resultFailed(desc: "id not exist,please create message again", code: -1, call: call, result: result);
        };
    }
	
	func sendMessageOldEdition(call: FlutterMethodCall, result: @escaping FlutterResult, type: Int) {
        let message = TencentImUtils.createMessage(call: call, result: result, type: type)
        sendMessageOldEdition(call: call, result: result, message: message);
	}
    
    func createForwardMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let msgID = CommonUtils.getParam(call: call, result: result, param: "msgID") as? String {
            V2TIMManager.sharedInstance()?.findMessages(msgID == "" ? [""] : [msgID], succ: {
                (msgs) -> Void in
                
                if msgs?.count != nil && msgs?.count != 0 {
                    let message = V2TIMManager.sharedInstance()?.createForwardMessage(msgs![0])
                    if message != nil {
                        self.setMessageMapProcess(call: call, result: result, message: message!);
                    }else{
                        CommonUtils.resultFailed(desc: "the message status is error. cant createForwardMessage", code: -1, call: call, result: result)
                    }
                } else {
                    CommonUtils.resultFailed(desc: "msg is not exist", code: -1, call: call, result: result)
                }
            }, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
        }
    }

	func sendForwardMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let msgID = CommonUtils.getParam(call: call, result: result, param: "msgID") as? String {
			V2TIMManager.sharedInstance()?.findMessages(msgID == "" ? [""] : [msgID], succ: {
				(msgs) -> Void in
				
				if msgs?.count != nil && msgs?.count != 0 {
					let message = V2TIMManager.sharedInstance()?.createForwardMessage(msgs![0])
					self.sendMessageOldEdition(call: call, result: result, message: message!)
				} else {
					CommonUtils.resultFailed(desc: "msg is not exist", code: -1, call: call, result: result)
				}
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}
	
	func reSendMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let msgID = CommonUtils.getParam(call: call, result: result, param: "msgID") as? String {
			// 注意：这个findMessages 返回的对象是V2TIMMessage类型，其中不返回优先级 导致我们无法顺利拿到priority
			V2TIMManager.sharedInstance()?.findMessages(msgID == "" ? [""] : [msgID], succ: {
				(msgs) -> Void in
				
				if msgs != nil && msgs?.count != 0 {
					let msg = msgs![0] as V2TIMMessage
					self.sendMessageOldEdition(call: call, result: result, message: msg)
				} else {
					CommonUtils.resultFailed(desc: "msg is not exist", code: -1, call: call, result: result)
				}
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}
    
    static var mergeMessageDict =  [String: V2TIMMessage]()
	
    func downloadMergerMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let msgID = CommonUtils.getParam(call: call, result: result, param: "msgID") as? String {
			V2TIMManager.sharedInstance()?.findMessages(msgID == "" ? [""] :[msgID],succ:{
						(msgs) -> Void in
						
						if msgs?.count != nil && msgs?.count != 0 {
							let msg = msgs![0] as V2TIMMessage
							if let elem = msg.mergerElem {
								elem.downloadMergerMessage({
									msgList -> Void in
									var messageList: [[String: Any]] = []
                                    for i in msgList! {
                                        MessageManager.mergeMessageDict.updateValue(i, forKey: i.msgID);
                                        messageList.append(V2MessageEntity.init(message: i).getDict())
                                    }
                                    CommonUtils.resultSuccess(call: call, result: result, data: messageList)
								},fail:TencentImUtils.returnErrorClosures(call: call, result: result))
							} else {
								CommonUtils.resultFailed(desc: "this message is not merge element", code: -1, call: call, result: result)
							}
						} else {
							CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, call: call, result: result)
						}
					},fail:TencentImUtils.returnErrorClosures(call: call, result: result))
		}
        
    }
    
    func createMergerMessage(call: FlutterMethodCall, result: @escaping FlutterResult){
        if let msgIDList = CommonUtils.getParam(call: call, result: result, param: "msgIDList") as? [String],
           let abstractList = CommonUtils.getParam(call: call, result: result, param: "abstractList") as? [String],
           let compatibleText = CommonUtils.getParam(call: call, result: result, param: "compatibleText") as? String,
           let title = CommonUtils.getParam(call: call, result: result, param: "title") as? String {
            V2TIMManager.sharedInstance()?.findMessages(msgIDList, succ: {
                (msgs) -> Void in
                
                if msgs?.count != nil && msgs?.count != 0 {
                    if let message = V2TIMManager.sharedInstance()?.createMergerMessage(msgs, title: title, abstractList: abstractList, compatibleText: compatibleText){
                        self.setMessageMapProcess(call: call, result: result, message: message);
                    }
                    else
                        {CommonUtils.resultFailed(desc: "create merge msgs fail", code: -1, call: call, result: result)}
                } else {
                    CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, call: call, result: result)
                }
            }, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
        }
    }

	func sendMergerMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let msgIDList = CommonUtils.getParam(call: call, result: result, param: "msgIDList") as? [String],
		   let abstractList = CommonUtils.getParam(call: call, result: result, param: "abstractList") as? [String],
		   let compatibleText = CommonUtils.getParam(call: call, result: result, param: "compatibleText") as? String,
		   let title = CommonUtils.getParam(call: call, result: result, param: "title") as? String {
			V2TIMManager.sharedInstance()?.findMessages(msgIDList, succ: {
				(msgs) -> Void in
				
				if msgs?.count != nil && msgs?.count != 0 {
					let message = V2TIMManager.sharedInstance()?.createMergerMessage(msgs, title: title, abstractList: abstractList, compatibleText: compatibleText)
					self.sendMessageOldEdition(call: call, result: result, message: message!)
				} else {
					CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, call: call, result: result)
				}
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}
	
	func setC2CReceiveMessageOpt(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let userIDList = CommonUtils.getParam(call: call, result: result, param: "userIDList") as? [String],
		   let opt = CommonUtils.getParam(call: call, result: result, param: "opt") as? Int {
			V2TIMManager.sharedInstance()?.setC2CReceiveMessageOpt(userIDList, opt: V2TIMReceiveMessageOpt.init(rawValue: opt)!, succ: {
					() -> Void in
					CommonUtils.resultSuccess(call: call, result: result, data: "ok")
				}, fail: TencentImUtils.returnErrorClosures(call: call, result: result)
			)
		}
	}
	
	func setGroupReceiveMessageOpt(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String,
		   let opt = CommonUtils.getParam(call: call, result: result, param: "opt") as? Int {
			V2TIMManager.sharedInstance()?.setGroupReceiveMessageOpt(groupID, opt: V2TIMReceiveMessageOpt.init(rawValue: opt)!, succ: {
					() -> Void in
					CommonUtils.resultSuccess(call: call, result: result, data: "ok")
				}, fail: TencentImUtils.returnErrorClosures(call: call, result: result)
			)
		}
	}
	
	func getC2CReceiveMessageOpt(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let userIDList = CommonUtils.getParam(call: call, result: result, param: "userIDList") as? [String] {
			V2TIMManager.sharedInstance()?.getC2CReceiveMessageOpt(userIDList, succ: {
				let dict = $0!.map { [
                    "c2CReceiveMessageOpt": Int($0.receiveOpt.rawValue),
					"userID": $0.userID ?? "",
                    "allReceiveMessageOpt": $0.receiveOpt.rawValue,
                    "startHour": $0.startHour,
                    "startMinute":$0.startMinute,
                    "startSecond":$0.startSecond,
                    "startTimeStamp":$0.startTimeStamp,
                    "duration": $0.duration
                    
				] }
				CommonUtils.resultSuccess(call: call, result: result, data: dict)
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}
	
	func getC2CHistoryMessageList(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let count = CommonUtils.getParam(call: call, result: result, param: "count") as? Int32,
		   let userID = CommonUtils.getParam(call: call, result: result, param: "userID") as? String {
			let lastMsgID = CommonUtils.getParam(call: call, result: result, param: "lastMsgID") as? String
			
			if lastMsgID != nil {
				V2TIMManager.sharedInstance()?.findMessages(lastMsgID == nil ? [""] : [lastMsgID!], succ: {
					(msgs) -> Void in
					
					let lastMsg = msgs!.isEmpty ? nil : msgs![0]
					if lastMsg != nil {
						self.getC2CHistoryMessageListFn(userID: userID, count: count, lastMsg: lastMsg!, result: result, call: call)
					}
					
				}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
			} else {
				getC2CHistoryMessageListFn(userID: userID, count: count, lastMsg: nil, result: result, call: call)
			}
			
		}
	}
	
	func getC2CHistoryMessageListFn(userID: String, count: Int32, lastMsg: V2TIMMessage?, result: @escaping FlutterResult, call: FlutterMethodCall) {
		V2TIMManager.sharedInstance()?.getC2CHistoryMessageList(userID, count: count, lastMsg: lastMsg, succ: {
			msgs -> Void in
			
			var messageList: [[String: Any]] = []
			
            for i in msgs! {
                
                messageList.append(V2MessageEntity.init(message: i).getDict())
            }
            CommonUtils.resultSuccess(call: call, result: result, data: messageList)
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
	}
	
	
	func getHistoryMessageList(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let lastMsgID = CommonUtils.getParam(call: call, result: result, param: "lastMsgID") as? String
		let count = CommonUtils.getParam(call: call, result: result, param: "count") as? UInt
	    let userID = CommonUtils.getParam(call: call, result: result, param: "userID") as? String
		let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String
		let getType = CommonUtils.getParam(call: call, result: result, param: "getType") as? Int
        let lastMsgSeq = CommonUtils.getParam(call: call, result: result, param: "lastMsgSeq") as? Int
        let messageTypeList = CommonUtils.getParam(call: call, result: result, param: "messageTypeList") as? Array<Int> ?? []
        let messageSeqList = CommonUtils.getParam(call: call, result: result, param: "messageSeqList") as? Array<Int> ?? []
        let timeBegin = CommonUtils.getParam(call: call, result: result, param: "timeBegin") as? Int ?? 0
        let timePeriod = CommonUtils.getParam(call: call, result: result, param: "timePeriod") as? Int ?? 0
		let option = V2TIMMessageListGetOption();
        
        if (groupID != nil||((groupID?.isEmpty) != nil)) && (userID != nil || ((userID?.isEmpty) != nil)) {
            CommonUtils.resultFailed(desc: "groupID和userID只能设置一个", code: -1, call: call, result: result)
        }
        
        if(!messageSeqList.isEmpty){
            
            option.messageSeqList = messageSeqList.map({ value in
                return NSNumber.init(value: value)
            });
        }
        if(timeBegin > 0){
            option.getTimeBegin = UInt(timeBegin);
        }
        if(timePeriod > 0){
            option.getTimePeriod = UInt(timePeriod);
        }
       
		if count != nil {
			option.count = count!
		}
		if userID != nil {
			option.userID = userID
		}
		if groupID != nil {
			option.groupID = groupID
		}
		if getType != nil {
			option.getType = V2TIMMessageGetType.init(rawValue: getType!)!
		}
        if let lastMsgSeq = lastMsgSeq {
            if (lastMsgSeq >= 0) {
                option.lastMsgSeq = UInt(lastMsgSeq)
            }
        }
        if(!messageTypeList.isEmpty){
            option.messageTypeList = messageTypeList.map({ value in
                return NSNumber.init(value: value)
            });
        }
		if lastMsgID != nil {
			V2TIMManager.sharedInstance()?.findMessages(lastMsgID == nil ? [""] : [lastMsgID!], succ: {
				(msgs) -> Void in
				let lastMsg = msgs!.isEmpty ? nil : msgs![0]
				if lastMsg != nil {
					option.lastMsg = lastMsg
					self.getHistoryMessageListFn(option: option, result: result, call: call,isV2: false)
				}else{
                    CommonUtils.resultFailed(desc: "last message not found", code: -1, call: call, result: result)
                }
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
		} else {
			getHistoryMessageListFn(option: option, result: result, call: call,isV2: false)
		}
	}
    func getHistoryMessageListV2(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let lastMsgID = CommonUtils.getParam(call: call, result: result, param: "lastMsgID") as? String
        let count = CommonUtils.getParam(call: call, result: result, param: "count") as? UInt
        let userID = CommonUtils.getParam(call: call, result: result, param: "userID") as? String
        let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String
        let getType = CommonUtils.getParam(call: call, result: result, param: "getType") as? Int
        let lastMsgSeq = CommonUtils.getParam(call: call, result: result, param: "lastMsgSeq") as? Int
        let messageTypeList = CommonUtils.getParam(call: call, result: result, param: "messageTypeList") as? Array<Int>
        let messageSeqList = CommonUtils.getParam(call: call, result: result, param: "messageSeqList") as? Array<Int> ?? []
        let timeBegin = CommonUtils.getParam(call: call, result: result, param: "timeBegin") as? Int ?? 0
        let timePeriod = CommonUtils.getParam(call: call, result: result, param: "timePeriod") as? Int ?? 0
        
        let option = V2TIMMessageListGetOption();
        
        if (groupID != nil || ((groupID?.isEmpty) != nil)) && (userID != nil||((userID?.isEmpty) != nil)) {
            CommonUtils.resultFailed(desc: "groupID和userID只能设置一个", code: -1, call: call, result: result)
        }
        if(!messageSeqList.isEmpty){
            
            option.messageSeqList = messageSeqList.map({ value in
                return NSNumber.init(value: value)
            });
        }
        if(timeBegin > 0){
            option.getTimeBegin = UInt(timeBegin);
        }
        if(timePeriod > 0){
            option.getTimePeriod = UInt(timePeriod);
        }

        if count != nil {
            option.count = count!
        }
        if userID != nil {
            option.userID = userID
        }
        if groupID != nil {
            option.groupID = groupID
        }
        if getType != nil {
            option.getType = V2TIMMessageGetType.init(rawValue: getType!)!
        }
        if let lastMsgSeq = lastMsgSeq {
            if (lastMsgSeq >= 0) {
                option.lastMsgSeq = UInt(lastMsgSeq)
            }
        }
        if(messageTypeList != nil){
            option.messageTypeList = messageTypeList?.map({ value in
                return NSNumber.init(value: value)
            });
        }
        if lastMsgID != nil {
            V2TIMManager.sharedInstance()?.findMessages(lastMsgID == nil ? [""] : [lastMsgID!], succ: {
                (msgs) -> Void in
                let lastMsg = msgs!.isEmpty ? nil : msgs![0]
                if lastMsg != nil {
                    option.lastMsg = lastMsg
                    self.getHistoryMessageListFn(option: option, result: result, call: call,isV2: true)
                }else{
                    CommonUtils.resultFailed(desc: "last message not found", code: -1, call: call, result: result)
                }
            }, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
        } else {
            getHistoryMessageListFn(option: option, result: result, call: call,isV2: true)
        }
    }

    func getHistoryMessageListFn(option: V2TIMMessageListGetOption, result: @escaping FlutterResult, call: FlutterMethodCall,isV2:Bool) {
        
        
        V2TIMManager.sharedInstance()?.getHistoryMessageList(option, succ: {
            msgs -> Void in
            
            
            
            var messageList: [[String: Any]] = []
            
            for i in msgs! {
                messageList.append(V2MessageEntity.init(message: i).getDict())
            }
            if(isV2){
                var isFinish:Bool = false;
                
                if(msgs!.count < option.count){
                    isFinish = true;
                }
                var res:[String:Any] = [:];
                res["isFinished"] = isFinish;
                res["messageList"] = messageList;
                CommonUtils.resultSuccess(call: call, result: result, data: res)
            }else{
                CommonUtils.resultSuccess(call: call, result: result, data: messageList)
            }
            
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
	}
	
	func getGroupHistoryMessageList(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let count = CommonUtils.getParam(call: call, result: result, param: "count") as? Int32,
		   let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String {
			let lastMsgID = CommonUtils.getParam(call: call, result: result, param: "lastMsgID") as? String
			
			if lastMsgID != nil {
				V2TIMManager.sharedInstance()?.findMessages(lastMsgID == nil ? [""] : [lastMsgID!], succ: {
					(msgs) -> Void in
					
					let lastMsg = msgs!.isEmpty ? nil : msgs![0]
					if lastMsg != nil {
						self.getGroupHistoryMessageListFn(groupID: groupID, count: count, lastMsg: lastMsg!, result: result, call: call)
					}
				}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
			} else {
				getGroupHistoryMessageListFn(groupID: groupID, count: count, lastMsg: nil, result: result, call: call)
			}
		}
	}
	
	func getGroupHistoryMessageListFn(groupID: String, count: Int32, lastMsg: V2TIMMessage?, result: @escaping FlutterResult, call: FlutterMethodCall) {
		V2TIMManager.sharedInstance()?.getGroupHistoryMessageList(groupID, count: count, lastMsg: lastMsg, succ: {
			msgs -> Void in
			
			var messageList: [[String: Any]] = []
			
            for i in msgs ?? [] {
                
                messageList.append(V2MessageEntity.init(message: i).getDict())
            }
            CommonUtils.resultSuccess(call: call, result: result, data: messageList)
			
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
	}
	
	public func revokeMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let msgID = CommonUtils.getParam(call: call, result: result, param: "msgID") as? String {
			V2TIMManager.sharedInstance()?.findMessages([msgID], succ: {
				(msgs) -> Void in
				if msgs?.count != nil && msgs?.count != 0 {
				V2TIMManager.sharedInstance().revokeMessage(msgs![0], succ: {
					CommonUtils.resultSuccess(call: call, result: result)
				}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
				} else {
					CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, call: call, result: result)
				}
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
		}
	}
	
	
	public func markC2CMessageAsRead(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let userID = CommonUtils.getParam(call: call, result: result, param: "userID") as? String {
			V2TIMManager.sharedInstance().markC2CMessage(asRead: userID, succ: {
				CommonUtils.resultSuccess(call: call, result: result)
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}
	
	func markGroupMessageAsRead(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String;
		
		V2TIMManager.sharedInstance()?.markGroupMessage(asRead: groupID, succ: {
			() -> Void in
			
			CommonUtils.resultSuccess(call: call, result: result)
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}

	func markAllMessageAsRead(call: FlutterMethodCall, result: @escaping FlutterResult) {
        V2TIMManager.sharedInstance()?.markAllMessage(asRead: {
            () -> Void in
            
            CommonUtils.resultSuccess(call: call, result: result)
        }, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
	}
	
	func deleteMessageFromLocalStorage(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let msgID = CommonUtils.getParam(call: call, result: result, param: "msgID") as? String {
			V2TIMManager.sharedInstance()?.findMessages([msgID], succ: {
				(msgs) -> Void in
				if msgs?.count != nil && msgs?.count != 0 {
				V2TIMManager.sharedInstance().deleteMessage(fromLocalStorage: msgs![0], succ: {
					CommonUtils.resultSuccess(call: call, result: result)
				}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
				} else {
					CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, call: call, result: result)
				}
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
		}
	}
	
	func deleteMessages(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let msgIDs = CommonUtils.getParam(call: call, result: result, param: "msgIDs") as? Array<String> {
			V2TIMManager.sharedInstance()?.findMessages(msgIDs, succ: {
				(msgs) -> Void in
				if msgs?.count != nil && msgs?.count != 0 {
				V2TIMManager.sharedInstance().delete(msgs, succ: {
					CommonUtils.resultSuccess(call: call, result: result)
				}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
				} else {
					CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, call: call, result: result)
				}
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
		}
	}

	func sendMessageReadReceipts(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let msgIDs = CommonUtils.getParam(call: call, result: result, param: "messageIDList") as? Array<String> {
			V2TIMManager.sharedInstance()?.findMessages(msgIDs, succ: {
				(msgs) -> Void in
                if msgs?.count != nil && msgs?.count != 0 {
				V2TIMManager.sharedInstance().sendMessageReadReceipts(msgs, succ: {
					CommonUtils.resultSuccess(call: call, result: result)
				}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
				} else {
					CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, call: call, result: result)
				}
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
		}
	}

	func getMessageReadReceipts(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let msgIDs = CommonUtils.getParam(call: call, result: result, param: "messageIDList") as? Array<String> {
			V2TIMManager.sharedInstance()?.findMessages(msgIDs, succ: {
				(msgs) -> Void in
                if msgs?.count != nil && msgs?.count != 0 {
				V2TIMManager.sharedInstance().getMessageReadReceipts(msgs, succ: {
					(_ receiptList: [V2TIMMessageReceipt]!) -> Void in
			
					var data: [[String: Any]] = [];
					for item in receiptList {
						data.append(V2MessageReceiptEntity.getDict(info: item));
					}
					CommonUtils.resultSuccess(call: call, result: result,data: data)
				}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
				} else {
					CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, call: call, result: result)
				}
            }, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
		}
	}

	func getGroupMessageReadMemberList(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let msgIDs = CommonUtils.getParam(call: call, result: result, param: "messageID") as? String,
		   let filter = CommonUtils.getParam(call: call, result: result, param: "filter") as? Int,
		   let seq = CommonUtils.getParam(call: call, result: result, param: "nextSeq") as? UInt64,
		   let count = CommonUtils.getParam(call: call, result: result, param: "count") as? UInt32 {
			V2TIMManager.sharedInstance()?.findMessages([msgIDs], succ: {
				(msgs) -> Void in
				if msgs?.count != nil  && msgs?.count != 0 {
					let f = V2TIMGroupMessageReadMembersFilter.init(rawValue: filter)!
                    let message = msgs![0]
                    V2TIMManager.sharedInstance().getGroupMessageReadMemberList(message, filter: f, nextSeq: seq, count: count, succ: {
                        (members,nextSeq,isFinished) -> Void in
                            var res: [String: Any] = [:];
                            res["nextSeq"] = nextSeq;
                            res["isFinished"] = isFinished;
                            var data: [[String: Any]] = [];
                            for item in members! {
                                data.append(V2GroupMemberFullInfoEntity.getDict(simpleInfo: item as! V2TIMGroupMemberInfo));
                            }
                            res["memberInfoList"] = data;
                            CommonUtils.resultSuccess(call: call, result: result,data: res)
                    }, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
				} else {
					CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, call: call, result: result)
				}
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
		}
	}
	

	func clearC2CHistoryMessage(call: FlutterMethodCall, result: @escaping FlutterResult){
		if let userID = CommonUtils.getParam(call: call, result: result, param: "userID") as? String {
            V2TIMManager.sharedInstance().clearC2CHistoryMessage(userID, succ: {
                () -> Void in
                CommonUtils.resultSuccess(call: call, result: result);
            }, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}
	
	func clearGroupHistoryMessage(call: FlutterMethodCall, result: @escaping FlutterResult){
		if let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String {
            V2TIMManager.sharedInstance().clearGroupHistoryMessage(groupID, succ: {
                CommonUtils.resultSuccess(call: call, result: result);
            }, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}

	func insertGroupMessageToLocalStorage(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String,
		   let sender = CommonUtils.getParam(call: call, result: result, param: "sender") as? String {
			let message = TencentImUtils.createMessage(call: call, result: result, type: 2);
			
			var msgID = ""
			let id = V2TIMManager.sharedInstance()?.insertGroupMessage(toLocalStorage: message, to: groupID, sender: sender, succ: {
			   () -> Void in
				
				V2TIMManager.sharedInstance()?.findMessages([msgID], succ: {
					(msgs) -> Void in
				if msgs?.count != nil && msgs?.count != 0 {
					let dict = V2MessageEntity.init(message: msgs![0]).getDict()
					CommonUtils.resultSuccess(call: call, result: result, data: dict)
				} else {
					CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, call: call, result: result)
				}
					
				}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
			 }, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
			
			if(id != nil){
				msgID = id!
			}
			
		}
	}
	
	func insertC2CMessageToLocalStorage(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let userID = CommonUtils.getParam(call: call, result: result, param: "userID") as? String,
		   let sender = CommonUtils.getParam(call: call, result: result, param: "sender") as? String {
			let message = TencentImUtils.createMessage(call: call, result: result, type: 2);
			
			var msgID = ""
			let id = V2TIMManager.sharedInstance()?.insertC2CMessage(toLocalStorage: message, to: userID, sender: sender, succ: {
			   () -> Void in
				
				V2TIMManager.sharedInstance()?.findMessages([msgID], succ: {
					(msgs) -> Void in
				if msgs?.count != nil && msgs?.count != 0 {
					let dict = V2MessageEntity.init(message: msgs![0]).getDict()
					CommonUtils.resultSuccess(call: call, result: result, data: dict)
				} else {
					CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, call: call, result: result)
				}
				}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
			 }, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
			if(id != nil){
				msgID = id!
			}
			
		}
	}
    // 发送消息前，我们可以对消息 自定义设置云端数据和本地自定义消息
    func setCustomDataBeforSend(call: FlutterMethodCall, result: @escaping FlutterResult, message: V2TIMMessage) {
        if let data = CommonUtils.getParam(call: call, result: result, param: "cloudCustomData") as? String {
            message.cloudCustomData = data.data(using: String.Encoding.utf8, allowLossyConversion: true)
        }
        if let data = CommonUtils.getParam(call: call, result: result, param: "localCustomData") as? String {
            message.localCustomData = data.data(using: String.Encoding.utf8, allowLossyConversion: true)
        }
		if let data = CommonUtils.getParam(call: call, result: result, param: "isExcludedFromUnreadCount") as? Bool {
            message.isExcludedFromUnreadCount = data;
        }
		if let data = CommonUtils.getParam(call: call, result: result, param: "isExcludedFromLastMessage") as? Bool {
            message.isExcludedFromLastMessage = data;
        }
        if let data = CommonUtils.getParam(call: call, result: result, param: "isSupportMessageExtension") as? Bool {
            message.supportMessageExtension = data;
        }
        if let data = CommonUtils.getParam(call: call, result: result, param: "isExcludedFromContentModeration") as? Bool {
            message.isExcludedFromContentModeration = data;
        }
        if let data = CommonUtils.getParam(call: call, result: result, param: "needReadReceipt") as? Bool {
            message.needReadReceipt = data;
        }
        
    }
    
	// 3.6.0后不推荐使用,必须在message发送钱调用才能生效
	func setCloudCustomData(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let msgID = CommonUtils.getParam(call: call, result: result, param: "msgID") as? String,
		   let data = CommonUtils.getParam(call: call, result: result, param: "data") as? String {
			V2TIMManager.sharedInstance()?.findMessages([msgID], succ: {
				if $0?.count ?? 0 > 0 {
					$0![0].cloudCustomData = data.data(using: String.Encoding.utf8, allowLossyConversion: true)
					CommonUtils.resultSuccess(call: call, result: result, data: "ok")
				} else {
					CommonUtils.resultFailed(desc: "msg is not exist", code: -1, call: call, result: result)
				}
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}
	
	func setLocalCustomInt(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let msgID = CommonUtils.getParam(call: call, result: result, param: "msgID") as? String,
		   let localCustomInt = CommonUtils.getParam(call: call, result: result, param: "localCustomInt") as? Int32 {
			V2TIMManager.sharedInstance()?.findMessages([msgID], succ: {
				if $0?.count ?? 0 > 0 {
					$0![0].localCustomInt = localCustomInt
					CommonUtils.resultSuccess(call: call, result: result, data: "ok")
				} else {
					CommonUtils.resultFailed(desc: "msg is not exist", code: -1, call: call, result: result)
				}
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}
	
	func setLocalCustomData(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let msgID = CommonUtils.getParam(call: call, result: result, param: "msgID") as? String,
		   let localCustomData = CommonUtils.getParam(call: call, result: result, param: "localCustomData") as? String {
			V2TIMManager.sharedInstance()?.findMessages([msgID], succ: {
				if $0?.count ?? 0 > 0 {
					$0![0].localCustomData = localCustomData.data(using: String.Encoding.utf8, allowLossyConversion: true)
					CommonUtils.resultSuccess(call: call, result: result, data: "ok")
				} else {
					CommonUtils.resultFailed(desc: "msg is not exist", code: -1, call: call, result: result)
				}
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}

	func searchLocalMessages(call: FlutterMethodCall, result: @escaping FlutterResult){

        let searchParam = CommonUtils.getParam(call: call, result: result, param: "searchParam") as! [String: Any];
        //var l = searchParam["xx"] as! Int;
        let messageSearchParam = V2TIMMessageSearchParam();
        
        if(searchParam["keywordList"] != nil){
            messageSearchParam.keywordList = searchParam["keywordList"] as? [String];
        }
        if(searchParam["conversationID"] != nil){
            messageSearchParam.conversationID = searchParam["conversationID"] as? String ?? nil;
        }
        if(searchParam["messageTypeList"] != nil){
            let messageTypeListLength = (searchParam["messageTypeList"] as! [Any]).count;
            messageSearchParam.messageTypeList = messageTypeListLength == 0 ? nil : searchParam["messageTypeList"] as? [NSNumber];
        }
        if(searchParam["type"] != nil){

            messageSearchParam.keywordListMatchType = searchParam["type"] as! Int == 0 ? V2TIMKeywordListMatchType.KEYWORD_LIST_MATCH_TYPE_OR : V2TIMKeywordListMatchType.KEYWORD_LIST_MATCH_TYPE_AND;
        }
        if(searchParam["pageSize"] != nil){
            messageSearchParam.pageSize = searchParam["pageSize"] as? UInt ?? 20;
        }

        if let searchTimePosition = searchParam["searchTimePosition"] as? UInt {
            messageSearchParam.searchTimePosition = searchTimePosition;
        }
        else {
           messageSearchParam.searchTimePosition = 0;
        }


        if(searchParam["pageIndex"] != nil){
            messageSearchParam.pageIndex = searchParam["pageIndex"] as? UInt ?? 0;
        }

        if let searchTimePeriod = searchParam["searchTimePeriod"] as? UInt {
            messageSearchParam.searchTimePeriod = searchTimePeriod;
        }
        else {
           messageSearchParam.searchTimePeriod = 0;
        }
        
        if(searchParam["userIDList"] != nil){
            let userIDListLength = (searchParam["userIDList"] as! [String]).count;
            messageSearchParam.senderUserIDList = userIDListLength == 0 ? nil : searchParam["userIDList"] as? [String];
        }
        if(searchParam["searchCount"] != nil){
            messageSearchParam.searchCount = searchParam["searchCount"] as? UInt ?? 10;
        }
        if(searchParam["searchCursor"] != nil){
            messageSearchParam.searchCursor = searchParam["searchCursor"] as? String ?? "";
        }
        
        V2TIMManager.sharedInstance().searchLocalMessages(messageSearchParam, succ: {
                (res) -> Void in
            let list = res?.messageSearchResultItems ?? [];
            var messageSearchResultItems:[Any] = [];
            var map = [String: Any]();
            
            
            for(_,element) in list.enumerated(){
                var messageSearchResultItemMap = [String: Any]();
                messageSearchResultItemMap.updateValue(element.conversationID!, forKey: "conversationID");
                messageSearchResultItemMap.updateValue(element.messageCount, forKey: "messageCount");
                messageSearchResultItemMap.updateValue(CommonUtils.parseMessageListDict(list: element.messageList) , forKey: "messageList");
                messageSearchResultItems.append(messageSearchResultItemMap);
            };
            map.updateValue(res!.totalCount, forKey: "totalCount");
            map.updateValue(messageSearchResultItems, forKey: "messageSearchResultItems")
            map.updateValue(res?.searchCursor as Any, forKey: "searchCursor")
            CommonUtils.resultSuccess(call: call, result: result, data: map);
            }, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
        
	}
    func searchCloudMessages(call: FlutterMethodCall, result: @escaping FlutterResult){

        let searchParam = CommonUtils.getParam(call: call, result: result, param: "searchParam") as! [String: Any];
        //var l = searchParam["xx"] as! Int;
        let messageSearchParam = V2TIMMessageSearchParam();
        
        if(searchParam["keywordList"] != nil){
            messageSearchParam.keywordList = searchParam["keywordList"] as? [String];
        }
        if(searchParam["conversationID"] != nil){
            messageSearchParam.conversationID = searchParam["conversationID"] as? String ?? nil;
        }
        if(searchParam["messageTypeList"] != nil){
            let messageTypeListLength = (searchParam["messageTypeList"] as! [Any]).count;
            messageSearchParam.messageTypeList = messageTypeListLength == 0 ? nil : searchParam["messageTypeList"] as? [NSNumber];
        }
        if(searchParam["type"] != nil){

            messageSearchParam.keywordListMatchType = searchParam["type"] as! Int == 0 ? V2TIMKeywordListMatchType.KEYWORD_LIST_MATCH_TYPE_OR : V2TIMKeywordListMatchType.KEYWORD_LIST_MATCH_TYPE_AND;
        }
        if(searchParam["pageSize"] != nil){
            messageSearchParam.pageSize = searchParam["pageSize"] as? UInt ?? 20;
        }

        if let searchTimePosition = searchParam["searchTimePosition"] as? UInt {
            messageSearchParam.searchTimePosition = searchTimePosition;
        }
        else {
           messageSearchParam.searchTimePosition = 0;
        }


        if(searchParam["pageIndex"] != nil){
            messageSearchParam.pageIndex = searchParam["pageIndex"] as? UInt ?? 0;
        }

        if let searchTimePeriod = searchParam["searchTimePeriod"] as? UInt {
            messageSearchParam.searchTimePeriod = searchTimePeriod;
        }
        else {
           messageSearchParam.searchTimePeriod = 0;
        }
        
        if(searchParam["userIDList"] != nil){
            let userIDListLength = (searchParam["userIDList"] as! [String]).count;
            messageSearchParam.senderUserIDList = userIDListLength == 0 ? nil : searchParam["userIDList"] as? [String];
        }
        if(searchParam["searchCount"] != nil){
            messageSearchParam.searchCount = searchParam["searchCount"] as? UInt ?? 10;
        }
        if(searchParam["searchCursor"] != nil){
            messageSearchParam.searchCursor = searchParam["searchCursor"] as? String ?? "";
        }
        
        V2TIMManager.sharedInstance().searchCloudMessages(messageSearchParam, succ: {
                (res) -> Void in
            let list = res?.messageSearchResultItems ?? [];
            var messageSearchResultItems:[Any] = [];
            var map = [String: Any]();
            
            
            for(_,element) in list.enumerated(){
                var messageSearchResultItemMap = [String: Any]();
                messageSearchResultItemMap.updateValue(element.conversationID!, forKey: "conversationID");
                messageSearchResultItemMap.updateValue(element.messageCount, forKey: "messageCount");
                messageSearchResultItemMap.updateValue(CommonUtils.parseMessageListDict(list: element.messageList) , forKey: "messageList");
                messageSearchResultItems.append(messageSearchResultItemMap);
            };
            map.updateValue(res?.totalCount as Any, forKey: "totalCount");
            map.updateValue(messageSearchResultItems, forKey: "messageSearchResultItems")
            map.updateValue(res?.searchCursor as Any, forKey: "searchCursor")
            CommonUtils.resultSuccess(call: call, result: result, data: map);
            }, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
        
    }
    
	func findMessages(call: FlutterMethodCall, result: @escaping FlutterResult){
		if let messageIDList = CommonUtils.getParam(call: call, result: result, param: "messageIDList") as? [String] {
            V2TIMManager.sharedInstance().findMessages(messageIDList, succ: {
				(msgs) -> Void in
                var messageList: [[String: Any]] = []
                
                for i in msgs! {
                    
                    messageList.append(V2MessageEntity.init(message: i).getDict())
                }
                CommonUtils.resultSuccess(call: call, result: result, data: messageList) 
            }, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}
	func setMessageExtensions(call: FlutterMethodCall, result: @escaping FlutterResult){
        let msgID = CommonUtils.getParam(call: call, result: result, param: "msgID") as? String;
        let extensions = CommonUtils.getParam(call: call, result: result, param: "extensions") as? [[String:String]] ?? [];
        var exList:[V2TIMMessageExtension] = [];
        for item:[String:String] in extensions {
            let key:String = item["key"] ?? "";
            let value:String = item["value"] ?? ""
            if(key.isEmpty || value.isEmpty){
                continue;
            }
            let ex:V2TIMMessageExtension = V2TIMMessageExtension();
            ex.extensionKey = key;
            ex.extensionValue = value;
            exList.append(ex);
        }
        V2TIMManager.sharedInstance().findMessages([msgID ?? ""]) { messageList in
            if(messageList?.count == 1){
                let cumessage:V2TIMMessage = (messageList?.first)!;
                print(cumessage)
                if(cumessage.supportMessageExtension && cumessage.status.rawValue == 2){
                    V2TIMManager.sharedInstance().setMessageExtensions(cumessage, extensions: exList) { extResList in
                        var resList = [[String:Any]]();
                        for res:V2TIMMessageExtensionResult in extResList ?? [] {
                            var resItem = [String: Any]();
                            resItem["resultCode"] = res.resultCode as Any;
                            resItem["resultInfo"] = res.resultInfo as Any;
                            var extentionDict = [String:String]();
                            extentionDict["extensionKey"] = res.ext.extensionKey;
                            extentionDict["extensionValue"] = res.ext.extensionValue;
                            resItem["extension"] = extentionDict;
                            resList.append(resItem);
                        }
                        CommonUtils.resultSuccess(call: call, result: result, data: resList)
                    } fail: { code, desc in
                        CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
                    }

                }else{
                    CommonUtils.resultFailed(desc: "msg info error", code: -1, call: call, result: result)
                }
            }else{
                CommonUtils.resultFailed(desc: "msg is not exist", code: -1, call: call, result: result)
            }
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    func getMessageExtensions(call: FlutterMethodCall, result: @escaping FlutterResult){
        let msgID = CommonUtils.getParam(call: call, result: result, param: "msgID") as? String;
        
        V2TIMManager.sharedInstance().findMessages([msgID ?? ""]) { messageList in
            if(messageList?.count == 1){
                let cumessage:V2TIMMessage = (messageList?.first)!;
                if(cumessage.supportMessageExtension && cumessage.status.rawValue == 2){
                    V2TIMManager.sharedInstance().getMessageExtensions(cumessage) { extList in
                        var resList = [[String:Any]]();
                        for res:V2TIMMessageExtension in extList ?? [] {
                            var resItem = [String: Any]();
                            resItem["extensionKey"] = res.extensionKey as Any;
                            resItem["extensionValue"] = res.extensionValue as Any;
                            resList.append(resItem);
                        }
                        CommonUtils.resultSuccess(call: call, result: result, data: resList)
                    } fail: { code, desc in
                        CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
                    }


                }else{
                    CommonUtils.resultFailed(desc: "msg info error", code: -1, call: call, result: result)
                }
            }else{
                CommonUtils.resultFailed(desc: "msg is not exist", code: -1, call: call, result: result)
            }
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }
    }
    func deleteMessageExtensions(call: FlutterMethodCall, result: @escaping FlutterResult){
        let msgID = CommonUtils.getParam(call: call, result: result, param: "msgID") as? String;
        let keys = CommonUtils.getParam(call: call, result: result, param: "keys") as? [String] ?? [];
        
        V2TIMManager.sharedInstance().findMessages([msgID ?? ""]) { messageList in
            if(messageList?.count == 1){
                let cumessage:V2TIMMessage = (messageList?.first)!;
                if(cumessage.supportMessageExtension && cumessage.status.rawValue == 2){
                    V2TIMManager.sharedInstance().deleteMessageExtensions(cumessage, keys: keys) { extResList in
                        var resList = [[String:Any]]();
                        for res:V2TIMMessageExtensionResult in extResList ?? [] {
                            var resItem = [String: Any]();
                            resItem["resultCode"] = res.resultCode as Any;
                            resItem["resultInfo"] = res.resultInfo as Any;
                            var extentionDict = [String:String]();
                            extentionDict["extensionKey"] = res.ext.extensionKey;
                            extentionDict["extensionValue"] = res.ext.extensionValue;
                            resItem["extension"] = extentionDict;
                            resList.append(resItem);
                        }
                        CommonUtils.resultSuccess(call: call, result: result, data: resList)
                    } fail: { code, desc in
                        CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
                    }

                }else{
                    CommonUtils.resultFailed(desc: "msg info error", code: -1, call: call, result: result)
                }
            }else{
                CommonUtils.resultFailed(desc: "msg is not exist", code: -1, call: call, result: result)
            }
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }
    }
    func getMessageOnlineUrl(call: FlutterMethodCall, result: @escaping FlutterResult){
        let msgID = CommonUtils.getParam(call: call, result: result, param: "msgID") as? String;
        let allowList:[Int] = [V2TIMElemType.ELEM_TYPE_IMAGE.rawValue,V2TIMElemType.ELEM_TYPE_FILE.rawValue,V2TIMElemType.ELEM_TYPE_SOUND.rawValue,V2TIMElemType.ELEM_TYPE_VIDEO.rawValue];
        
        
        getMessageByID(msgid: msgID ?? "", cb: GetMessageCallback(success: { msg in
            
            var res:[String:[String:Any]] = [:];
            if(allowList.contains(msg.elemType.rawValue) && msg.msgID == msgID){
                if(msg.elemType == V2TIMElemType.ELEM_TYPE_IMAGE){
                    res["imageElem"] = V2MessageEntity.init(message: msg).convertImageMessageElem(imageElem: msg.imageElem)
                    CommonUtils.resultSuccess(call: call, result: result, data: res)
                    
                }else if(msg.elemType == V2TIMElemType.ELEM_TYPE_VIDEO){
                    var video:[String:Any] = V2MessageEntity.init(message: msg).convertVideoMessageElem(videoElem: msg.videoElem) ;
                    async({
                                    _ -> Int in
                                    
                        video["videoUrl"] = try Hydra.await(V2MessageEntity.init(message: msg).getVideoUrl(msg))
                        video["snapshotUrl"] = try Hydra.await(V2MessageEntity.init(message: msg).getSnapshotUrl(msg))
                                    res["videoElem"] = video
                        
                                    CommonUtils.resultSuccess(call: call, result: result, data: res)
                                    
                                    return 1
                                }).then({
                                    value in
                                })
                    
                    
                    
                }else if(msg.elemType == V2TIMElemType.ELEM_TYPE_SOUND){
                    var sound:[String:Any] = V2MessageEntity.init(message: msg).convertSoundMessageElem(soundElem: msg.soundElem);
                    async({
                                    _ -> Int in
                                    
                        sound["url"] = try Hydra.await(V2MessageEntity.init(message: msg).getUrl(msg))
                        
                                    res["soundElem"] = sound
                        
                                    CommonUtils.resultSuccess(call: call, result: result, data: res)
                                    
                                    return 1
                                }).then({
                                    value in
                                })
                }else if(msg.elemType == V2TIMElemType.ELEM_TYPE_FILE){
                    var file:[String:Any] = V2MessageEntity.init(message: msg).convertFileElem(fileElem:  msg.fileElem);
                    async({
                                    _ -> Int in
                                    
                        file["url"] = try Hydra.await(V2MessageEntity.init(message: msg).getFileUrl(msg))
                        
                                    res["fileElem"] = file
                        
                                    CommonUtils.resultSuccess(call: call, result: result, data: res)
                                    
                                    return 1
                                }).then({
                                    value in
                                })
                }
            }else {
                CommonUtils.resultFailed(desc: "message invalid", code: -1, call: call, result: result)
            }
        }, error: { code, desc in
            CommonUtils.resultFailed(desc:desc, code: code, call: call, result: result)
        }))
        
        

    }
    func sendDownloadProgress(_ isFinish:Bool, _ isError:Bool, _ currentSize:Int, _ totalSize:Int,  _ msgID:String,_ type:Int,_ isSnapshot:Bool,_ path:String,_ error_code:Int32,_ error_desc:String?){
        let listenerList = SDKManager.getAdvanceMsgListenerList();
        
        
        for items in listenerList {
            TencentCloudChatSdkPlugin.invokeListener(
                type: ListenerType.onMessageDownloadProgressCallback, method: "advancedMsgListener",
                data: ["isFinish": isFinish, "isError": isError,"currentSize":currentSize,"totalSize":totalSize,"msgID":msgID,"type":type,"isSnapshot":isSnapshot,"path":path,"errorCode":error_code,"errorDesc":error_desc ?? ""], listenerUuid: items
            )
        }
    }
    func downloadMessage(call: FlutterMethodCall, result: @escaping FlutterResult){
        let msgID = CommonUtils.getParam(call: call, result: result, param: "msgID") as? String;
        var imageType = CommonUtils.getParam(call: call, result: result, param: "imageType") as? Int ?? 0;
        let isSnapshot = CommonUtils.getParam(call: call, result: result, param: "isSnapshot") as? Bool ?? false;
        let allowList:[Int] = [V2TIMElemType.ELEM_TYPE_IMAGE.rawValue,V2TIMElemType.ELEM_TYPE_FILE.rawValue,V2TIMElemType.ELEM_TYPE_SOUND.rawValue,V2TIMElemType.ELEM_TYPE_VIDEO.rawValue];
        
        
        getMessageByID(msgid: msgID ?? "", cb: GetMessageCallback(success: { msg in
            if(allowList.contains(msg.elemType.rawValue) && msg.msgID == msgID){
                
                
                CommonUtils.resultSuccess(call: call, result: result)
                if(msg.elemType == V2TIMElemType.ELEM_TYPE_IMAGE){
                    
                    V2MessageEntity.init(message: msg).downloadImageMessage(msgID!, msg.imageElem, imageType, DownloadCallback(onProgress: { isFinish, isError, currentSize, totalSize, msgID, type, isSnapshot, path ,error_code,error_desc in
                        self.sendDownloadProgress(isFinish,isError,currentSize,totalSize,msgID,type,isSnapshot,path,error_code,error_desc)
                    }))
                }else if(msg.elemType == V2TIMElemType.ELEM_TYPE_VIDEO){
                    V2MessageEntity.init(message: msg).downloadVideoMessage(msgID!, msg.videoElem, isSnapshot, DownloadCallback(onProgress: { isFinish, isError, currentSize, totalSize, msgID, type, isSnapshot, path,error_code,error_desc in
                        self.sendDownloadProgress(isFinish,isError,currentSize,totalSize,msgID,type,isSnapshot,path,error_code,error_desc)
                    }))
                }else if(msg.elemType == V2TIMElemType.ELEM_TYPE_SOUND){
                    V2MessageEntity.init(message: msg).downloadSoundMessage(msgID!, msg.soundElem, DownloadCallback(onProgress: { isFinish, isError, currentSize, totalSize, msgID, type, isSnapshot, path,error_code,error_desc in
                        self.sendDownloadProgress(isFinish,isError,currentSize,totalSize,msgID,type,isSnapshot,path,error_code,error_desc)
                    }))
                }else if(msg.elemType == V2TIMElemType.ELEM_TYPE_FILE){
                    V2MessageEntity.init(message: msg).downloadFileMessage(msgID!, msg.fileElem, DownloadCallback(onProgress: { isFinish, isError, currentSize, totalSize, msgID, type, isSnapshot, path,error_code,error_desc in
                        self.sendDownloadProgress(isFinish,isError,currentSize,totalSize,msgID,type,isSnapshot,path,error_code,error_desc)
                    }))
                }
            }else{
                CommonUtils.resultFailed(desc: "message invalid", code: -1, call: call, result: result)
            }
        }, error: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }))
    }
    func translateText(call: FlutterMethodCall, result: @escaping FlutterResult){
        let texts = CommonUtils.getParam(call: call, result: result, param: "texts") as? Array<String>;
        let targetLanguage = CommonUtils.getParam(call: call, result: result, param: "targetLanguage") as? String;
        let sourceLanguage = CommonUtils.getParam(call: call, result: result, param: "sourceLanguage") as? String;
        V2TIMManager.sharedInstance().translateText(texts, sourceLanguage: sourceLanguage, targetLanguage: targetLanguage) { code, desc, data in
            if(code == 0){
                CommonUtils.resultSuccess(call: call, result: result,data: data as Any)
            }else{
                CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
            }
            
        }
    }
    
    func setAvChatRoomCanFindMessage (call: FlutterMethodCall, result: @escaping FlutterResult){
        
        let avchatroomIDs = CommonUtils.getParam(call: call, result: result, param: "avchatroomIDs") as? Array<String>;
        let num = CommonUtils.getParam(call: call, result: result, param: "eachGroupMessageNums") as? Int;
        if(!(avchatroomIDs?.isEmpty ?? false)){
            avchatroomIDs?.forEach({ gid in
                if(!MessageManager.groupidList.contains(gid)){
                    MessageManager.groupidList.append(gid)
                }
            })
        }
        MessageManager.eachGroupMessageNums = num ?? 20
        CommonUtils.resultSuccess(call: call, result: result,data: MessageManager.groupidList as Any)
    }
    func getMessageByID(msgid :String,cb:GetMessageCallback){
        var finded = false;
        if(MessageManager.messageList.count > 0){
            for msg in MessageManager.messageList {
                if(msg.msgID == msgid){
                    print("find message from av caht room cache.")
                    cb.success(msg)
                    finded = true;
                    break;
                }
            }
        }
        if(MessageManager.mergeMessageDict.contains{ $0.key == msgid }){
            if let msg = MessageManager.mergeMessageDict.first(where: { $0.key == msgid }) {
                print("find message from merge message cache.")
                cb.success(msg.value)
                finded = true;
            }
            
        }
        if(!finded){
            var ids:[String] = [];
            ids.append(msgid)
            V2TIMManager.sharedInstance().findMessages(ids) { msgs in
                
                if(!(msgs?.isEmpty ?? true)){
                    if(msgs![0].msgID == msgid){
                        cb.success(msgs![0])
                    }else{
                        cb.error(-3,"find message id error")
                    }
                }else{
                    cb.error(-3,"find message length error")
                }
            } fail: { code, desc in
                cb.error(code,desc)
            }

        }
    }
    func convertVoiceToText(call: FlutterMethodCall, result: @escaping FlutterResult){
        let msgID = CommonUtils.getParam(call: call, result: result, param: "msgID") as? String;
        let language = CommonUtils.getParam(call: call, result: result, param: "language") as? String;
        getMessageByID(msgid: msgID ?? "", cb: GetMessageCallback(success: { msg in
            if(msg.elemType != V2TIMElemType.ELEM_TYPE_SOUND){
                CommonUtils.resultFailed(desc: "error message elem type", code: -3, call: call, result: result)
            }else{
                msg.soundElem.convertVoice(toText: language ?? "") { code, desc, text in
                    if(code == 0){
                        CommonUtils.resultSuccess(call: call, result: result,data: text as Any)
                    }else{
                        CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
                    }
                }
            }
        }, error: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }))
    }
    func setAllReceiveMessageOpt(call: FlutterMethodCall, result: @escaping FlutterResult){
        let opt = CommonUtils.getParam(call: call, result: result, param: "opt") as? Int;
        let startHour = CommonUtils.getParam(call: call, result: result, param: "startHour") as? Int32;
        let startMinute = CommonUtils.getParam(call: call, result: result, param: "startMinute") as? Int32;
        let startSecond = CommonUtils.getParam(call: call, result: result, param: "startSecond") as? Int32;
        let duration = CommonUtils.getParam(call: call, result: result, param: "duration") as? UInt32;
        let optEnum:V2TIMReceiveMessageOpt = V2TIMReceiveMessageOpt.init(rawValue: opt ?? 0) ?? V2TIMReceiveMessageOpt.RECEIVE_MESSAGE;
        V2TIMManager.sharedInstance().setAllReceiveMessageOpt(optEnum , startHour: startHour ?? 0, startMinute: startMinute ?? 0, startSecond: startSecond ?? 0, duration: duration ?? 0) {
            CommonUtils.resultSuccess(call: call, result: result)
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    func setAllReceiveMessageOptWithTimestamp(call: FlutterMethodCall, result: @escaping FlutterResult){
        let opt = CommonUtils.getParam(call: call, result: result, param: "opt") as? Int;
        let startTimeStamp = CommonUtils.getParam(call: call, result: result, param: "startTimeStamp") as? UInt32;
        let duration = CommonUtils.getParam(call: call, result: result, param: "duration") as? UInt32;

        let optEnum:V2TIMReceiveMessageOpt = V2TIMReceiveMessageOpt.init(rawValue: opt ?? 0) ?? V2TIMReceiveMessageOpt.RECEIVE_MESSAGE;
        V2TIMManager.sharedInstance().setAllReceiveMessageOpt(optEnum, startTimeStamp: startTimeStamp ?? 0, duration: duration ?? 0) {
            CommonUtils.resultSuccess(call: call, result: result)
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    func getAllReceiveMessageOpt(call: FlutterMethodCall, result: @escaping FlutterResult){
        V2TIMManager.sharedInstance().getAllReceiveMessageOpt { optinfo in
            var data = [String:Any]();
            
            data["c2CReceiveMessageOpt"] = optinfo?.receiveOpt.rawValue;
            data["allReceiveMessageOpt"] = optinfo?.receiveOpt.rawValue;
            data["duration"] = optinfo?.duration;
            data["startHour"] = optinfo?.startHour;
            data["startMinute"] = optinfo?.startMinute;
            data["startSecond"] = optinfo?.startSecond;
            data["startTimeStamp"] = optinfo?.startTimeStamp;
            data["userID"] = optinfo?.userID;
            CommonUtils.resultSuccess(call: call, result: result,data: data as Any)
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    func addMessageReaction(call: FlutterMethodCall, result: @escaping FlutterResult){
        let msgID = CommonUtils.getParam(call: call, result: result, param: "msgID") as? String;
        let reactionID = CommonUtils.getParam(call: call, result: result, param: "reactionID") as? String;
        getMessageByID(msgid: msgID ?? "", cb: GetMessageCallback(success: { msg in
            V2TIMManager.sharedInstance().addMessageReaction(msg, reactionID: reactionID) {
                CommonUtils.resultSuccess(call: call, result: result)
            } fail: { code, desc in
                CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
            }

        }, error: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }))
    }
    func removeMessageReaction(call: FlutterMethodCall, result: @escaping FlutterResult){
        let msgID = CommonUtils.getParam(call: call, result: result, param: "msgID") as? String;
        let reactionID = CommonUtils.getParam(call: call, result: result, param: "reactionID") as? String;
        getMessageByID(msgid: msgID ?? "", cb: GetMessageCallback(success: { msg in
            V2TIMManager.sharedInstance().removeMessageReaction(msg, reactionID: reactionID) {
                CommonUtils.resultSuccess(call: call, result: result)
            } fail: { code, desc in
                CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
            }

        }, error: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }))
    }
    func getMessageReactions(call: FlutterMethodCall, result: @escaping FlutterResult){
        let msgIDList = CommonUtils.getParam(call: call, result: result, param: "msgIDList") as? Array<String>;
        let maxUserCountPerReaction = CommonUtils.getParam(call: call, result: result, param: "maxUserCountPerReaction") as? UInt32;
        V2TIMManager.sharedInstance().findMessages(msgIDList) { msgs in
            V2TIMManager.sharedInstance().getMessageReactions(msgs, maxUserCountPerReaction: maxUserCountPerReaction ?? 100) { reactresult in
                var resList = [[String:Any]]();
                for res:V2TIMMessageReactionResult in reactresult ?? [] {
                    var resItem = [String: Any]();
                    resItem["messageID"] = res.msgID as Any;
                    resItem["resultCode"] = res.resultCode as Any;
                    resItem["resultInfo"] = res.resultInfo as Any;
                    var reactionList = [[String:Any]]();
                    for rec:V2TIMMessageReaction in res.reactionList ?? [] {
                        var reaction = [String:Any]();
                        reaction["reactionID"] = rec.reactionID;
                        reaction["reactedByMyself"] = rec.reactedByMyself;
                        reaction["totalUserCount"] = rec.totalUserCount;
                        var partialUserList = [[String:Any]]();
                        for uif:V2TIMUserInfo in rec.partialUserList ?? [] {
                            var uini = [String:Any]();
                            uini["userID"] = uif.userID;
                            uini["faceUrl"] = uif.faceURL;
                            uini["nickName"] = uif.nickName;
                            partialUserList.append(uini)
                        }
                        reaction["partialUserList"] = partialUserList;
                        reactionList.append(reaction)
                    }
                    resItem["reactionList"] = reactionList as Any;
                    resList.append(resItem);
                }
                CommonUtils.resultSuccess(call: call, result: result,data: resList as Any)
            } fail: { code, desc in
                CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
            }

        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    func getAllUserListOfMessageReaction(call: FlutterMethodCall, result: @escaping FlutterResult){
        
               
        let msgID = CommonUtils.getParam(call: call, result: result, param: "msgID") as? String;
        let reactionID = CommonUtils.getParam(call: call, result: result, param: "reactionID") as? String;
        let nextSeq = CommonUtils.getParam(call: call, result: result, param: "nextSeq") as? UInt32;
        let count = CommonUtils.getParam(call: call, result: result, param: "count") as? UInt32;
        getMessageByID(msgid: msgID ?? "", cb: GetMessageCallback(success: { msg in
            V2TIMManager.sharedInstance().getAllUserList(ofMessageReaction: msg, reactionID: reactionID, nextSeq: nextSeq ?? 0, count: count ?? 10) { userinfo, next, isfinis in
                var data = [String: Any]();
                data["nextSeq"] = next;
                data["isFinished"] = isfinis;
                var userInfoList = [[String:Any]]();
                for info:V2TIMUserInfo in userinfo ?? [] {
                    userInfoList.append(V2UserInfoEntity.getDict(info: info))
                }
                data["userInfoList"] = userInfoList;
                CommonUtils.resultSuccess(call: call, result: result,data: data as Any)
            } fail: { code, desc in
                CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
            }

            
        }, error: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }))
    }
    func pinGroupMessage(call: FlutterMethodCall, result: @escaping FlutterResult){
        let msgID = CommonUtils.getParam(call: call, result: result, param: "msgID") as? String;
        let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String;
        let isPinned = (CommonUtils.getParam(call: call, result: result, param: "isPinned") as? Bool)!;
        getMessageByID(msgid: msgID ?? "", cb: GetMessageCallback(success: { msg in
            V2TIMManager.sharedInstance().pinGroupMessage(groupID, message: msg, isPinned: isPinned) {
                CommonUtils.resultSuccess(call: call, result: result)
            } fail: { code, desc in
                CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
            }


            
        }, error: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }))
    }
    func getPinnedGroupMessageList(call: FlutterMethodCall, result: @escaping FlutterResult){
        let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String;
        V2TIMManager.sharedInstance().getPinnedGroupMessageList(groupID) { msgList in
            
            var messageList: [[String: Any]] = []
            for i in msgList! {

                messageList.append(V2MessageEntity.init(message: i).getDict())
            }
            CommonUtils.resultSuccess(call: call, result: result, data: messageList)
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    func insertGroupMessageToLocalStorageV2(call: FlutterMethodCall, result: @escaping FlutterResult){
        let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String;
        let senderID = CommonUtils.getParam(call: call, result: result, param: "senderID") as? String;
        let createdMsgID = CommonUtils.getParam(call: call, result: result, param: "createdMsgID") as? String;
        if(!messageDict.contains{ $0.key == createdMsgID }){
            CommonUtils.resultFailed(desc: "created message not found", code: -1, call: call, result: result)
            return
        }
        var msgID  = "";
        if let msg = messageDict.first(where: { $0.key == createdMsgID }) {
            msgID  = V2TIMManager.sharedInstance().insertGroupMessage(toLocalStorage: msg.value, to: groupID, sender: senderID) {
                self.messageDict.removeValue(forKey: createdMsgID!)
                if(msgID.isEmpty){
                    CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, call: call, result: result)
                    return;
                }
                
                
                V2TIMManager.sharedInstance()?.findMessages([msgID], succ: {
                    (msgs) -> Void in
                    if (msgs?.count ?? 0 > 0) {
                    let dict = V2MessageEntity.init(message: msgs![0]).getDict()
                    CommonUtils.resultSuccess(call: call, result: result, data: dict)
                } else {
                    CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, call: call, result: result)
                }
                    
                }, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
            } fail: { code, desc in
                CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
            }
        }else{
            CommonUtils.resultFailed(desc: "created message not found", code: -1, call: call, result: result)
        }
    }
    func insertC2CMessageToLocalStorageV2(call: FlutterMethodCall, result: @escaping FlutterResult){
        let userID = CommonUtils.getParam(call: call, result: result, param: "userID") as? String;
        let senderID = CommonUtils.getParam(call: call, result: result, param: "senderID") as? String;
        let createdMsgID = CommonUtils.getParam(call: call, result: result, param: "createdMsgID") as? String;
        if(!messageDict.contains{ $0.key == createdMsgID }){
            CommonUtils.resultFailed(desc: "created message not found", code: -1, call: call, result: result)
            return
        }
        var msgID  = "";
        if let msg = messageDict.first(where: { $0.key == createdMsgID }) {
            msgID  = V2TIMManager.sharedInstance().insertC2CMessage(toLocalStorage: msg.value, to: userID, sender: senderID) {
                self.messageDict.removeValue(forKey: createdMsgID!)
                if(msgID.isEmpty){
                    CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, call: call, result: result)
                    return;
                }
                
                V2TIMManager.sharedInstance()?.findMessages([msgID], succ: {
                    (msgs) -> Void in
                    if (msgs?.count ?? 0 > 0) {
                    let dict = V2MessageEntity.init(message: msgs![0]).getDict()
                    CommonUtils.resultSuccess(call: call, result: result, data: dict)
                } else {
                    CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, call: call, result: result)
                }
                    
                }, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
            } fail: { code, desc in
                CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
            }
        }else{
            CommonUtils.resultFailed(desc: "created message not found", code: -1, call: call, result: result)
        }
    }
    func createAtSignedGroupMessage(call: FlutterMethodCall, result: @escaping FlutterResult){
        let createdMsgID = CommonUtils.getParam(call: call, result: result, param: "createdMsgID") as? String;
        let atUserList = CommonUtils.getParam(call: call, result: result, param: "atUserList") as? NSMutableArray ?? [];
        if(!messageDict.contains{ $0.key == createdMsgID }){
            CommonUtils.resultFailed(desc: "created message not found", code: -1, call: call, result: result)
            return
        }
        if let msg = messageDict.first(where: { $0.key == createdMsgID }) {
            if(atUserList.contains("__kImSDK_MessageAtALL__")){
                atUserList.remove("__kImSDK_MessageAtALL__");
                atUserList.add(kImSDK_MesssageAtALL)
            }else if(atUserList.contains("__kImSDK_MesssageAtALL__")){
                atUserList.remove("__kImSDK_MesssageAtALL__");
                atUserList.add(kImSDK_MesssageAtALL)
            }
            let message = V2TIMManager.sharedInstance().create(atSignedGroupMessage: msg.value, atUserList: atUserList)
            if(message != nil){
                setMessageMapProcess(call: call, result: result, message: message!);
            }else{
                CommonUtils.resultFailed(desc: "create message failed", code: -1, call: call, result: result)
            }
            
        }else{
            CommonUtils.resultFailed(desc: "created message not found", code: -1, call: call, result: result)
        }
    }
    
	/*
					V2TIMManager.sharedInstance()?.findMessages([msgID], succ: {
					(msgs) -> Void in
					
					let dict = V2MessageEntity.init(message: msgs![0]).getDict()
					CommonUtils.resultSuccess(call: call, result: result, data: dict)
				}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
			 }, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
	
	*/

}	
