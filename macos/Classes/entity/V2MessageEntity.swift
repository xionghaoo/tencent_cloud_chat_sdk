import ImSDKForMac_Plus
import Hydra

public class V2MessageEntity {
	var msgID: String?;
	var timestamp: Date? = Date();
	var sender: String?;
	var nickName: String?;
	var friendRemark: String?;
	var nameCard: String?;
	var faceUrl: String?;
	var groupID: String?;
	var userID: String?;
	var status: Int?;
	var isSelf: Bool?;
	var isRead: Bool?;
	var isPeerRead: Bool?;
    var needReadReceipt: Bool?;
	var groupAtUserList: [String]?;
	var elemType: Int?;
	var textElem: [String: Any]?;
	var customElem: [String: Any]?;
	var imageElem: [String: Any]?;
	var soundElem: [String: Any]?;
	var videoElem: [String: Any]?;
	var fileElem: [String: Any]?;
	var locationElem: [String: Any]?;
	var faceElem: [String: Any]?;
	var mergerElem: [String: Any]?;
	var groupTipsElem: [String: Any]?;
    var offlinePushInfo: [String: Any]?;
	var localCustomData: String?;
	var cloudCustomData: String?;
	var localCustomInt: Int32?;
	var seq: String?;
	var random: UInt64?;
	var isExcludedFromUnreadCount: Bool?;
    var isExcludedFromLastMessage: Bool?;
    var isSupportMessageExtension: Bool?;
    var hasRiskContent: Bool?;
    var revokeReason: String?;
    var isBroadcastMessage: Bool?;
    var revokerInfo:[String: Any]?;
    var isExcludedFromContentModeration: Bool?;
    
    var id:String?; // 只有在onProgress时才能拿掉此id
	var v2message: V2TIMMessage;
	
	func getUrl(_ message: V2TIMMessage) -> Promise<String> {
		return Promise<String>(in: .main, { resolve, reject, _ in
			message.soundElem.getUrl({ resolve($0 ?? "") })
		})
	}
	
	func getVideoUrl(_ message: V2TIMMessage) -> Promise<String> {
		return Promise<String>(in: .main, { resolve, reject, _ in
			message.videoElem.getVideoUrl({ resolve($0 ?? "") })
		})
	}
	
	func getSnapshotUrl(_ message: V2TIMMessage) -> Promise<String> {
		return Promise<String>(in: .main, { resolve, reject, _ in
			message.videoElem.getSnapshotUrl({ resolve($0 ?? "") })
		})
	}
	
	func getFileUrl(_ message: V2TIMMessage) -> Promise<String> {
		return Promise<String>(in: .main, { resolve, reject, _ in
			message.fileElem.getUrl({ resolve($0 ?? "") })
		})
	}
	
	func downloadMergerMessage(_ message: V2TIMMessage) -> Promise<Array<V2TIMMessage>> {
		return Promise<Array<V2TIMMessage>>(in: .main, { resolve, reject, _ in
			message.mergerElem.downloadMergerMessage({ resolve($0 ?? []) }, fail: {_,_ in })
		})
	}
    func downloadImageMessage(_ msgID:String,_ imageElem:V2TIMImageElem,_ imageType:Int,_ callback:DownloadCallback){
        let fileManager = FileManager.default;
        
        for image in imageElem.imageList! {
            if(CommonUtils.changeToAndroid(type: image.type.rawValue) != imageType){
                continue;
            }
            let file_identify = "image_temp_"+"\(image.size)\(image.width)\(image.height)" ;
            let file_final_identify = "image_"+"\(image.size)\(image.width)\(image.height)" ;
            
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
            
            let path = "\(documentDirectory.path)/\(SDKManager.globalSDKAPPID)/\(SDKManager.globalUserID)/\(file_identify)_\(image.uuid!)"
            let finalPath = "\(documentDirectory.path)/\(SDKManager.globalSDKAPPID)/\(SDKManager.globalUserID)/\(file_final_identify)_\(image.uuid!)"
            
            if(MessageManager.downloadingMessageList.contains(path)){
                callback.onProgress(false,true,0,0, msgID,imageType,false,"",0,"");
                return;
            }
            
            if !fileManager.fileExists(atPath: finalPath) {
                
                MessageManager.downloadingMessageList.append(path);
                image.downloadImage(path, progress: {
                    (curSize, totalSize) -> Void in
                    // print(curSize);
                    callback.onProgress(false,false,curSize,totalSize, msgID,imageType,false,finalPath,0,"");
                }, succ: {
                    
                    do {
                            
                        try fileManager.moveItem(atPath: path, toPath: finalPath)
                            print("File renamed successfully.")
                            
                        } catch {
                            print("Error renaming file: \(error)")
                        }
                    MessageManager.downloadingMessageList.removeAll { item in
                        return item == path;
                    }
                    callback.onProgress(true,false,0,0, msgID,imageType,false,finalPath,0,"");
                }, fail: {
                    
                    (code, msg) -> Void in
                    
                    do {
                            
                        try fileManager.removeItem(atPath: path)
                            print("File remove successfully.")
                            
                        } catch {
                            print("Error remove file: \(error)")
                        }
                    MessageManager.downloadingMessageList.removeAll { item in
                        return item == path;
                    }
                    callback.onProgress(false,true,0,0, msgID,imageType,false,finalPath,code,msg);
                    print("下载失败：desc:"+(msg ?? ""))
                })

            } else {
                MessageManager.downloadingMessageList.removeAll { item in
                    return item == path;
                }
                callback.onProgress(true,false,0,0, msgID,imageType,false,finalPath,0,"");
                // 图片存在，无需处理
            }
        }
        
    }
    func urlEncodeString(_ input: String) -> String? {
        
            return input
    }
  
    
    func downloadFileMessage(_ msgID:String,_ fileElem:V2TIMFileElem,_ callback:DownloadCallback){
        let fileManager = FileManager.default;
        
        // let ext = fileElem.filename.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let ext = urlEncodeString(fileElem.filename);
        
        let uuid = fileElem.uuid ?? "";
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
        
        let path = "\(documentDirectory.path)/\(SDKManager.globalSDKAPPID)/\(SDKManager.globalUserID)/\(uuid)/file_temp/\(ext ?? "")";
        let finalPath = "\(documentDirectory.path)/\(SDKManager.globalSDKAPPID)/\(SDKManager.globalUserID)/\(uuid)/\(ext ?? "")";
        print(finalPath);
        
        if(MessageManager.downloadingMessageList.contains(path)){
            callback.onProgress(false,true,0,0, msgID,0,false,"",0,"");
            return;
        }
           
            if !fileManager.fileExists(atPath: finalPath) {
                MessageManager.downloadingMessageList.append(path);
                fileElem.downloadFile(path, progress: {
                    (curSize, totalSize) -> Void in
                    callback.onProgress(false,false,curSize,totalSize, msgID,0,false,finalPath,0,"");
                }, succ: {
                    do {
                            
                        try fileManager.moveItem(atPath: path, toPath: finalPath)
                            print("File renamed successfully.")
                            
                        } catch {
                            print("Error renaming file: \(error)")
                        }
                    MessageManager.downloadingMessageList.removeAll { item in
                        return item == path;
                    }
                    callback.onProgress(true,false,0,0, msgID,0,false,finalPath,0,"");
                }, fail: {
                    
                    (code, msg) -> Void in
                    do {
                            
                        try fileManager.removeItem(atPath: path)
                            print("File remove successfully.")
                            
                        } catch {
                            print("Error remove file: \(error)")
                        }
                    MessageManager.downloadingMessageList.removeAll { item in
                       return item == path;
                    }
                    callback.onProgress(false,true,0,0, msgID,0,false,finalPath,code,msg);
                    print("下载失败：desc:"+(msg ?? ""))
                })

            } else {
                MessageManager.downloadingMessageList.removeAll { item in
                    return item == path;
                }
                callback.onProgress(true,false,0,0, msgID,0,false,finalPath,0,"");
                // 图片存在，无需处理
            }
        
        
    }
    func downloadSoundMessage(_ msgID:String,_ soundElem:V2TIMSoundElem,_ callback:DownloadCallback){
        let fileManager = FileManager.default;
        let uuid = soundElem.uuid ?? "";
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
        
        let path = "\(documentDirectory.path)/\(SDKManager.globalSDKAPPID)/\(SDKManager.globalUserID)/sound_temp_\(uuid)"
        let finalPath = "\(documentDirectory.path)/\(SDKManager.globalSDKAPPID)/\(SDKManager.globalUserID)/sound_\(uuid)"
        
        if(MessageManager.downloadingMessageList.contains(path)){
            callback.onProgress(false,true,0,0, msgID,0,false,"",0,"");
            return;
        }
            if !fileManager.fileExists(atPath: finalPath) {
                MessageManager.downloadingMessageList.append(path);
                soundElem.downloadSound(path, progress: {
                                (curSize, totalSize) -> Void in
                    callback.onProgress(false,false,curSize,totalSize, msgID,0,false,finalPath,0,"");
                            }, succ: {
                                do {
                                        
                                    try fileManager.moveItem(atPath: path, toPath: finalPath)
                                        print("File renamed successfully.")
                                        
                                    } catch {
                                        print("Error renaming file: \(error)")
                                    }
                                MessageManager.downloadingMessageList.removeAll { item in
                                   return item == path;
                                }
                                callback.onProgress(true,false,0,0, msgID,0,false,finalPath,0,"");
                            }, fail: {
                                (code, msg) -> Void in
                                do {
                                        
                                    try fileManager.removeItem(atPath: path)
                                        print("File remove successfully.")
                                        
                                    } catch {
                                        print("Error remove file: \(error)")
                                    }
                                MessageManager.downloadingMessageList.removeAll { item in
                                   return item == path;
                                }
                                callback.onProgress(false,true,0,0, msgID,0,false,finalPath,code,msg);
                                print("下载失败：desc:"+(msg ?? ""))
                            })
                

            } else {
                MessageManager.downloadingMessageList.removeAll { item in
                   return item == path;
                }
                callback.onProgress(true,false,0,0, msgID,0,false,finalPath,0,"");
                // 图片存在，无需处理
            }
        
    }
    func downloadVideoMessage(_ msgID:String,_ videoElem:V2TIMVideoElem,_ issnapshot:Bool,_ callback:DownloadCallback){
        let fileManager = FileManager.default;
        let suuid = videoElem.snapshotUUID ?? "";
        let vuuid = videoElem.videoUUID ?? "";
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
        
        let dpath = documentDirectory.path;
        
        let pathSnapshot = "\(dpath)/\(SDKManager.globalSDKAPPID)/\(SDKManager.globalUserID)/video_temp_\(suuid)";
        let pathVideo = "\(dpath)/\(SDKManager.globalSDKAPPID)/\(SDKManager.globalUserID)/video_temp_\(vuuid)";
        let fianlPathSnapshot = "\(dpath)/\(SDKManager.globalSDKAPPID)/\(SDKManager.globalUserID)/video_\(suuid)";
        let finalPathVideo = "\(dpath)/\(SDKManager.globalSDKAPPID)/\(SDKManager.globalUserID)/video_\(vuuid)";
        
        
        
        if(MessageManager.downloadingMessageList.contains(pathSnapshot)){
            callback.onProgress(false,true,0,0, msgID,0,false,"",0,"");
            return;
        }
        if(MessageManager.downloadingMessageList.contains(pathVideo)){
            callback.onProgress(false,true,0,0, msgID,0,false,"",0,"");
            return;
        }
        
        
        if(issnapshot){
            if !fileManager.fileExists(atPath: fianlPathSnapshot) {
                MessageManager.downloadingMessageList.append(pathSnapshot);
                videoElem.downloadSnapshot(pathSnapshot, progress: {
                    (curSize, totalSize) -> Void in
                    callback.onProgress(false,false,curSize,totalSize, msgID,0,true,fianlPathSnapshot,0,"");
                }, succ: {
                    do {
                            
                        try fileManager.moveItem(atPath: pathSnapshot, toPath: fianlPathSnapshot)
                            print("File renamed successfully.")
                            
                        } catch {
                            print("Error renaming file: \(error)")
                        }
                    MessageManager.downloadingMessageList.removeAll { item in
                        return item == pathSnapshot;
                    }
                    callback.onProgress(true,false,0,0, msgID,0,true,fianlPathSnapshot,0,"");
                }, fail: {
                    (code, msg) -> Void in
                    do {
                            
                        try fileManager.removeItem(atPath: pathSnapshot)
                            print("File remove successfully.")
                            
                        } catch {
                            print("Error remove file: \(error)")
                        }
                    MessageManager.downloadingMessageList.removeAll { item in
                       return item == pathSnapshot;
                    }
                    callback.onProgress(false,true,0,0, msgID,0,true,fianlPathSnapshot,code,msg);
                                                    print("下载失败：desc:"+(msg ?? ""))
                })
            } else {
                MessageManager.downloadingMessageList.removeAll { item in
                   return item == pathSnapshot;
                }
                callback.onProgress(true,false,0,0, msgID,0,true,fianlPathSnapshot,0,"");
            }
        }else{
            
                    if !fileManager.fileExists(atPath: finalPathVideo) {
                        MessageManager.downloadingMessageList.append(pathVideo);
                        videoElem.downloadVideo(pathVideo, progress: {
                            (curSize, totalSize) -> Void in
                            callback.onProgress(false,false,curSize,totalSize, msgID,0,false,finalPathVideo,0,"");
                        }, succ: {
                            do {
                                    
                                try fileManager.moveItem(atPath: pathVideo, toPath: finalPathVideo)
                                    print("File renamed successfully.")
                                    
                                } catch {
                                    print("Error renaming file: \(error)")
                                }
                            MessageManager.downloadingMessageList.removeAll { item in
                               return item == pathVideo;
                            }
                            callback.onProgress(true,false,0,0, msgID,0,false,finalPathVideo,0,"");
                        }, fail: {
                            (code, msg) -> Void in
                            do {
                                    
                                try fileManager.removeItem(atPath: pathVideo)
                                    print("File remove successfully.")
                                    
                                } catch {
                                    print("Error remove file: \(error)")
                                }
                            MessageManager.downloadingMessageList.removeAll { item in
                              return  item == pathVideo;
                            }
                            callback.onProgress(false,true,0,0, msgID,0,false,finalPathVideo,code,msg);
                                                            print("下载失败：desc:"+(msg ?? ""))
                        })
                    } else {
                        MessageManager.downloadingMessageList.removeAll { item in
                           return item == pathVideo;
                        }
                        callback.onProgress(true,false,0,0, msgID,0,false,finalPathVideo,0,"");
                    }
        }
        
    }
	// ios差异化问题，message不会返回这两个字段就不进行设置
	func getDictAll(progress: Int? = 100, status: Int? = nil) -> Promise<Dictionary<String, Any>> {
		return async({
			_ -> Dictionary<String, Any> in
			
			var dict = self.getDict(progress: progress, status: status)
			
			if self.v2message.soundElem != nil {
				let url = try Hydra.await(self.getUrl(self.v2message))
				self.soundElem!["url"] = url
				dict["soundElem"] = self.soundElem
			}
			
			if self.v2message.fileElem != nil {
				let url = try Hydra.await(self.getFileUrl(self.v2message))
				self.fileElem!["url"] = url
				dict["fileElem"] = self.fileElem
			}
			
			if self.v2message.videoElem != nil {
				let videoUrl = try Hydra.await(self.getVideoUrl(self.v2message))
				let snapshotUrl = try Hydra.await(self.getSnapshotUrl(self.v2message))
				self.videoElem!["videoUrl"] = videoUrl
				self.videoElem!["snapshotUrl"] = snapshotUrl
				dict["videoElem"] = self.videoElem
			}
			
			if self.mergerElem != nil {
				let messageList = try Hydra.await(self.downloadMergerMessage(self.v2message))
				var list: Array<Dictionary<String, Any>> = []
				for item in messageList {
					let msg = V2MessageEntity.init(message: item).getDict()
					list.append(msg)
				}
				self.mergerElem!["messageList"] = list
				dict["mergerElem"] = self.mergerElem
			}
            
            if self.v2message.groupAtUserList == nil {
                dict["groupAtUserList"] = []
            }	
			
			return dict
		}).then({ $0 })
	}
	
	func getDict(progress: Int? = nil, status: Int? = nil) -> [String: Any] {
		var result: [String: Any] = [:]
		result["msgID"] = self.msgID
		result["sender"] = self.sender
		result["nickName"] = self.nickName
		result["friendRemark"] = self.friendRemark
		result["nameCard"] = self.nameCard
		result["faceUrl"] = self.faceUrl
		result["groupID"] = self.groupID
		result["userID"] = self.userID
		result["status"] = self.status
		result["isSelf"] = self.isSelf
		result["isRead"] = self.isRead
		result["isPeerRead"] = self.isPeerRead
        result["needReadReceipt"] = self.needReadReceipt;
		result["groupAtUserList"] = self.groupAtUserList
		result["elemType"] = self.elemType
		result["localCustomInt"] = self.localCustomInt
		result["textElem"] = self.textElem;
		result["customElem"] = self.customElem;
		result["imageElem"] = self.imageElem;
		result["soundElem"] = self.soundElem;
		result["videoElem"] = self.videoElem;
		result["fileElem"] = self.fileElem;
		result["locationElem"] = self.locationElem;
		result["faceElem"] = self.faceElem;
		result["mergerElem"] = self.mergerElem;
		result["groupTipsElem"] = self.groupTipsElem;
		result["localCustomData"] = self.localCustomData;
		result["localCustomInt"] = self.localCustomInt;
		result["cloudCustomData"] = self.cloudCustomData;
        result["seq"] = String(self.seq!)
		result["random"] = self.random;
		result["isExcludedFromUnreadCount"] = self.isExcludedFromUnreadCount;
        result["isExcludedFromLastMessage"] = self.isExcludedFromLastMessage;
        result["isSupportMessageExtension"] = self.isSupportMessageExtension;
        result["id"] = self.id;
		result["timestamp"] = (self.timestamp == nil) ? Int(Date().timeIntervalSince1970) : Int(self.timestamp!.timeIntervalSince1970)
		result["offlinePushInfo"] = self.offlinePushInfo;
        result["hasRiskContent"] = self.hasRiskContent;
        result["revokeReason"] = self.revokeReason;
        result["isBroadcastMessage"] = self.isBroadcastMessage;
        result["isExcludedFromContentModeration"] = self.isExcludedFromContentModeration;
        result["revokerInfo"] = self.revokerInfo;
		return result
	}
    
    func convertTextMessage(textElem:V2TIMTextElem) -> [String: Any] {
        return [
            "text": textElem.text ?? ""
        ];
    }
    
    func convertCustomMessageElem(customElem:V2TIMCustomElem) -> [String:Any] {
        return [
            "data": String.init(data: customElem.data, encoding: String.Encoding.utf8) ?? "",
            "desc": customElem.desc  as Any,
            "extension": customElem.ext  as Any
        ]
    }
    
    func convertImageMessageElem(imageElem:V2TIMImageElem) -> [String:Any] {
        var result:[String:Any] = [:];
        var list:[[String: Any]] = [];
        result["path"] = imageElem.path ?? "";
        
        if imageElem.imageList.isEmpty {
            result["imageList"] = [["img": ""]]
        }
        let fileManager = FileManager.default;
        
        for image in imageElem.imageList! {
            var item: [String: Any] = [:];
            
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
            
            let dpath = documentDirectory.path;
            
            let file_identify = "image_"+"\(image.size)\(image.width)\(image.height)" ;
            let path = "\(NSTemporaryDirectory())/\(SDKManager.globalSDKAPPID)/\(SDKManager.globalUserID)/\(file_identify)_\(image.uuid!)"
            let latestpPath = "\(dpath)/\(SDKManager.globalSDKAPPID)/\(SDKManager.globalUserID)/\(file_identify)_\(image.uuid!)"
            
            item["uuid"] = image.uuid;
            item["type"] = CommonUtils.changeToAndroid(type: image.type.rawValue);
            item["size"] = image.size;
            item["width"] = image.width;
            item["height"] = image.height;
            item["url"] = image.url;
            if fileManager.fileExists(atPath: latestpPath) {
                item["localUrl"] = latestpPath;
            }else{
                if fileManager.fileExists(atPath: path) {
                    item["localUrl"] = path;
                }
            }
            list.append(item);
            result["imageList"] = list;
            
        }
      
        return result;
    }
    
    func convertSoundMessageElem(soundElem:V2TIMSoundElem) -> [String:Any] {
        let uuid = soundElem.uuid ?? "";
        let fileManager = FileManager.default;
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
        
        let dpath = documentDirectory.path;
        
        let path = "\(NSTemporaryDirectory())\(SDKManager.globalSDKAPPID)/\(SDKManager.globalUserID)/sound_\(uuid)"
        let latestPath = "\(dpath)/\(SDKManager.globalSDKAPPID)/\(SDKManager.globalUserID)/sound_\(uuid)"
        
        var item: [String: Any] = [:];
        item["UUID"] = soundElem.uuid as Any;
        item["dataSize"] = soundElem.dataSize;
        item["duration"] = soundElem.duration;
        // item["url"] = soundElem.url;
        item["path"] = soundElem.path;
        if fileManager.fileExists(atPath: latestPath) {
            item["localUrl"] = latestPath;
        }else {
            if fileManager.fileExists(atPath: path) {
                item["localUrl"] = path;
            }
        }

        return item;

    }
    
    func convertVideoMessageElem(videoElem:V2TIMVideoElem) -> [String:Any] {
        
        let fileManager = FileManager.default;
        let vuuid = videoElem.videoUUID ?? "";
        let suuid = videoElem.snapshotUUID ?? "";
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
        
        let dpath = documentDirectory.path;
        
        let pathSnapshot = "\(NSTemporaryDirectory())\(SDKManager.globalSDKAPPID)/\(SDKManager.globalUserID)/video_\(suuid)";
        let pathVideo = "\(NSTemporaryDirectory())\(SDKManager.globalSDKAPPID)/\(SDKManager.globalUserID)/video_\(vuuid)";
        
        let latestpathSnapshot = "\(dpath)/\(SDKManager.globalSDKAPPID)/\(SDKManager.globalUserID)/video_\(suuid)";
        let latestpathVideo = "\(dpath)/\(SDKManager.globalSDKAPPID)/\(SDKManager.globalUserID)/video_\(vuuid)";
        
        var item: [String: Any] = [:];
        item["snapshotUUID"] = videoElem.snapshotUUID as Any;
        item["snapshotPath"] = videoElem.snapshotPath as Any;
        // item["snapshotUrl"] = videoElem.snapshotUrl as Any;
        item["snapshotSize"] = videoElem.snapshotSize;
        item["snapshotWidth"] = videoElem.snapshotWidth;
        item["snapshotHeight"] = videoElem.snapshotHeight;
        item["UUID"] = videoElem.videoUUID as Any;
        item["videoPath"] = videoElem.videoPath as Any;
        // item["videoUrl"] = videoElem.videoUrl as Any;
        item["videoSize"] = videoElem.videoSize;
        item["duration"] = videoElem.duration;
        if fileManager.fileExists(atPath: latestpathSnapshot) {
            item["localSnapshotUrl"] = latestpathSnapshot;
        }else {
            if fileManager.fileExists(atPath: pathSnapshot) {
                item["localSnapshotUrl"] = pathSnapshot;
            }
        }
        if fileManager.fileExists(atPath: latestpathVideo) {
            item["localVideoUrl"] = latestpathVideo;
        }else {
            if fileManager.fileExists(atPath: pathVideo) {
                item["localVideoUrl"] = pathVideo;
            }
        }

        
       return item;
    }
    
    func convertFileElem(fileElem:V2TIMFileElem) -> [String:Any] {
        
        let fileManager = FileManager.default;
        
        // let ext = fileElem.filename.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let ext = urlEncodeString(fileElem.filename);
        let uuid = fileElem.uuid ?? "";
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
        
        let dpath = documentDirectory.path;
        
        let path = "\(NSTemporaryDirectory())\(SDKManager.globalSDKAPPID)/\(SDKManager.globalUserID)/\(uuid)/\(ext ?? "")";
        let latestPath = "\(dpath)/\(SDKManager.globalSDKAPPID)/\(SDKManager.globalUserID)/\(uuid)/\(ext ?? "")";
        
        var item: [String: Any] = [:];
        item["UUID"] = fileElem.uuid ?? "";
        item["path"] = fileElem.path;
        // item["url"] = fileElem.url;
        item["fileName"] = fileElem.filename;
        item["fileSize"] = fileElem.fileSize;
        if fileManager.fileExists(atPath: latestPath) {
            item["localUrl"] = latestPath;
        }else{
            if fileManager.fileExists(atPath: path) {
                item["localUrl"] = path;
            }
        }
        return  item;
    }
    
    func convertLocationElem(locationElem:V2TIMLocationElem) -> [String:Any] {
        return [
            "desc": locationElem.desc ?? "",
            "longitude": locationElem.longitude,
            "latitude": locationElem.latitude
        ];
    }
    
    func convertFaceElem(faceElem:V2TIMFaceElem) -> [String:Any] {
        return [
            "index": faceElem.index,
            "data": String.init(data: faceElem.data!, encoding: String.Encoding.utf8)!
        ];
    }
    
    func convertMergerElem(mergerElem:V2TIMMergerElem) -> [String:Any] {
        return [
            "layersOverLimit": mergerElem.layersOverLimit,
            "title": mergerElem.title ?? "",
            "abstractList": mergerElem.abstractList ?? []
        ];
    }
    
    func convertGroupTipsElem(groupTipsElem:V2TIMGroupTipsElem) -> [String:Any] {
        var result:[String:Any] = [:];
        var memberList: [[String: Any]] = []
        var groupChangeInfoList: [[String: Any]] = []
        var memberChangeInfoList: [[String: Any]] = []
        
        result = [
            "groupID": groupTipsElem.groupID!,
            "type": groupTipsElem.type.rawValue,
            "opMember": TIMGroupMemberInfo.getDict(simpleInfo: groupTipsElem.opMember!),
            "memberCount": groupTipsElem.memberCount
        ];
        
        for info in groupTipsElem.memberList {
            let item = TIMGroupMemberInfo.getDict(simpleInfo: info)
            memberList.append(item)
        }
        
        for info in groupTipsElem.groupChangeInfoList {
            let item: [String: Any] = [
                "type": info.type.rawValue,
                "value": info.value as Any,
                "key": info.key as Any,
                "boolValue": info.boolValue as Bool,
            ]
            groupChangeInfoList.append(item)
        }
        
        for info in groupTipsElem.memberChangeInfoList {
            let item: [String: Any] = [
                "userID": info.userID!,
                "muteTime": info.muteTime
            ]
            memberChangeInfoList.append(item)
        }
        
       
        result["memberList"] = memberList
        result["groupChangeInfoList"] = groupChangeInfoList
        result["memberChangeInfoList"] = memberChangeInfoList
        return result;
    }
    
    func convertMessageElem(nextElem:V2TIMElem) -> [String: Any] {
        var result: [String: Any] = [:];
        
            if nextElem is V2TIMTextElem {
                let textElem:V2TIMTextElem = nextElem as! V2TIMTextElem;
                result = self.convertTextMessage(textElem: textElem);
                result["elemType"] = V2TIMElemType.ELEM_TYPE_TEXT.rawValue;
            } else if nextElem is V2TIMCustomElem {
                let customElem:V2TIMCustomElem = nextElem as! V2TIMCustomElem;
                result = self.convertCustomMessageElem(customElem: customElem);
                result["elemType"] = V2TIMElemType.ELEM_TYPE_CUSTOM.rawValue;
            } else if nextElem is V2TIMImageElem {
                let imageElem:V2TIMImageElem = nextElem as! V2TIMImageElem;
                result = self.convertImageMessageElem(imageElem: imageElem);
                result["elemType"] = V2TIMElemType.ELEM_TYPE_IMAGE.rawValue;
            } else if nextElem is V2TIMSoundElem {
                let soundElem:V2TIMSoundElem = nextElem as! V2TIMSoundElem;
                result = self.convertSoundMessageElem(soundElem: soundElem);
                result["elemType"] = V2TIMElemType.ELEM_TYPE_SOUND.rawValue;
            } else if nextElem is V2TIMVideoElem {
                let videoElem:V2TIMVideoElem = nextElem as! V2TIMVideoElem;
                result = self.convertVideoMessageElem(videoElem: videoElem);
                result["elemType"] = V2TIMElemType.ELEM_TYPE_VIDEO.rawValue;
            } else if nextElem is V2TIMFileElem {
                let fileElem:V2TIMFileElem = nextElem as! V2TIMFileElem;
                result = self.convertFileElem(fileElem: fileElem);
                result["elemType"] = V2TIMElemType.ELEM_TYPE_FILE.rawValue;
            } else if nextElem is V2TIMLocationElem {
                let locationElem = nextElem as! V2TIMLocationElem;
                result = self.convertLocationElem(locationElem: locationElem);
                result["elemType"] = V2TIMElemType.ELEM_TYPE_LOCATION.rawValue;
            } else if nextElem is V2TIMFaceElem {
                let faceElem:V2TIMFaceElem = nextElem as! V2TIMFaceElem;
                result = self.convertFaceElem(faceElem: faceElem);
                result["elemType"] = V2TIMElemType.ELEM_TYPE_FACE.rawValue;
            } else if nextElem is V2TIMMergerElem {
                let meregerElem:V2TIMMergerElem = nextElem as! V2TIMMergerElem;
                result = self.convertMergerElem(mergerElem: meregerElem);
                result["elemType"] = V2TIMElemType.ELEM_TYPE_MERGER.rawValue;
            }
            if nextElem.next() != nil {
                result["nextElem"] = self.convertMessageElem(nextElem: nextElem.next());
            }
        
        return result;
    }
	// V2TIMMessage没有 progress和priority 字段
	init(message : V2TIMMessage) {
        _ = NSTemporaryDirectory()
		self.msgID = message.msgID;
		self.timestamp = message.timestamp as Date?;
		self.sender = message.sender;
		self.nickName = message.nickName;
		self.friendRemark = message.friendRemark;
		self.nameCard = message.nameCard;
		self.faceUrl = message.faceURL;
		self.groupID = message.groupID;
		self.userID = message.userID;
		self.status = message.status.rawValue;
		self.isSelf = message.isSelf;
		self.isRead = message.isRead;
        self.needReadReceipt = message.needReadReceipt;
		self.groupAtUserList = message.groupAtUserList as? [String] ?? [];
		self.isPeerRead = message.isPeerRead;
		self.elemType = message.elemType.rawValue;
		self.localCustomInt = message.localCustomInt;
		self.seq = String(message.seq);
		self.random = message.random;
		self.isExcludedFromUnreadCount = message.isExcludedFromUnreadCount;
        self.isExcludedFromLastMessage = message.isExcludedFromLastMessage;
        self.isSupportMessageExtension = message.supportMessageExtension;
        //        var hasRiskContent: Bool?;
        //        var revokeReason: String?;
        //        var isBroadcastMessage: Bool?;
        //        var revokerInfo:[String: Any]?;
        //        var isExcludedFromContentModeration: Bool?;
        self.hasRiskContent = message.hasRiskContent;
        self.revokeReason = message.revokeReason;
        self.isBroadcastMessage = message.isBroadcastMessage;
        self.isExcludedFromContentModeration = message.isExcludedFromContentModeration;
        
		self.v2message = message
        if message.offlinePushInfo != nil {
           
            self.offlinePushInfo = [
                "title": message.offlinePushInfo?.title as Any,
                "desc": message.offlinePushInfo?.desc as Any,
                "ext": message.offlinePushInfo?.ext as Any,
                "disablePush": message.offlinePushInfo?.disablePush as Any,
                "iOSSound": message.offlinePushInfo?.iOSSound as Any,
                "ignoreIOSBadge": message.offlinePushInfo?.ignoreIOSBadge as Any,
                "androidOPPOChannelID": message.offlinePushInfo?.androidOPPOChannelID as Any,
                "androidVIVOClassification": message.offlinePushInfo?.androidVIVOClassification as Any,
                "androidSound": message.offlinePushInfo?.androidSound  as Any,
                "androidVIVOCategory": message.offlinePushInfo?.androidVIVOCategory as Any,
                "iOSImage": message.offlinePushInfo?.iOSImage as Any,
                "androidHuaWeiImage": message.offlinePushInfo?.androidHuaWeiImage as Any,
                "androidHonorImage": message.offlinePushInfo?.androidHonorImage as Any,
                "androidFCMImage": message.offlinePushInfo?.androidFCMImage as Any,
            ]
        }
        if(message.revokerInfo != nil){
            self.revokerInfo = V2UserFullInfoEntity.getDict(info: message.revokerInfo)
        }
		if message.localCustomData != nil {
            if let localCustomData = message.localCustomData {
                let dataStr = String(data: localCustomData, encoding: .utf8) ?? "";
                self.localCustomData = dataStr;
            }
		}
		if message.cloudCustomData != nil {
            if let cloudCustomData = message.cloudCustomData {
                let dataStr = String(data: cloudCustomData, encoding: .utf8) ?? "";
                self.cloudCustomData = dataStr;
            }
		}
		// 文本消息
		if message.textElem != nil {
            var textElem = self.convertTextMessage(textElem: message.textElem);
            if message.textElem.next() != nil {
                textElem["nextElem"] = self.convertMessageElem(nextElem: message.textElem.next());
            }
            self.textElem = textElem;
		}
		// 自定义消息
		if let elem = message.customElem {
            var customElem = self.convertCustomMessageElem(customElem: elem);
            if message.customElem.next() != nil {
                customElem["nextElem"] = self.convertMessageElem(nextElem: elem.next());
            };
            self.customElem = customElem;
		}

		// 3图片消息
		/*
        native 图片下type字段不统一
		ios返回1、2、4 安卓返回0、1、2 对应 原图、缩略图、大图
		全部统一化为安卓的类型
		*/
		if let elem = message.imageElem {
            var imageElem = self.convertImageMessageElem(imageElem: elem);
            if elem.next() != nil {
                imageElem["nextElem"] = self.convertMessageElem(nextElem: elem.next());
            }
			self.imageElem = [:];
            self.imageElem = imageElem;
		}
		// 4语音消息
		if message.soundElem != nil {
            var soundElem = self.convertSoundMessageElem(soundElem: message.soundElem);
            if message.soundElem.next() != nil {
                soundElem["nextElem"] = self.convertMessageElem(nextElem: message.soundElem.next());
            }
            self.soundElem = soundElem;
		}
		
		// 5视频消息
		if let elem = message.videoElem {
            var videoElem = self.convertVideoMessageElem(videoElem: elem);
            if elem.next() != nil {
                videoElem["nextElem"] = self.convertMessageElem(nextElem: elem.next());
            };
            self.videoElem = videoElem;
		}
		// 6文件消息
		if let elem = message.fileElem {
            var fileElem = self.convertFileElem(fileElem: elem);
            if elem.next() != nil {
                fileElem["nextElem"] = self.convertMessageElem(nextElem: elem.next());
            }
            self.fileElem = fileElem;
		}
		
		// 7地理位置消息
		if let elem = message.locationElem {
            var locationElem = self.convertLocationElem(locationElem: elem);
            if elem.next() != nil {
                locationElem["nextElem"] = self.convertMessageElem(nextElem: elem.next());
            }
			self.locationElem = locationElem
		}
		
		// 8表情消息
		if let elem = message.faceElem {
            var faceElem = self.convertFaceElem(faceElem: elem);
            if elem.next() != nil {
                faceElem["nextElem"] = self.convertMessageElem(nextElem: elem.next());
            }
			self.faceElem = faceElem
		}
		
		// 9群tips消息
		if message.groupTipsElem != nil {
            self.groupTipsElem = self.convertGroupTipsElem(groupTipsElem: message.groupTipsElem);
		}
		// 10合并消息
		if let elem = message.mergerElem {
            var mergerElem = self.convertMergerElem(mergerElem: elem);
            if elem.next() != nil {
                mergerElem["nextElem"] = self.convertMessageElem(nextElem: elem.next())
            }
            self.mergerElem = mergerElem;
		}
		
	}
}
