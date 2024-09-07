import ImSDK_Plus
class UserFullInfo: V2TIMUserFullInfo {
    public static func getDict(info: V2TIMUserFullInfo) -> [String: Any] {
        var result: [String: Any] = [:];
        var retCustomInfo: [String: String] = [:];
        
        result["userID"] = info.userID;
        result["nickName"] = info.nickName;
        result["faceUrl"] = info.faceURL;
        result["selfSignature"] = info.selfSignature;
        result["gender"] = info.gender.rawValue;
        result["allowType"] = info.allowType.rawValue;
        result["role"] = info.role;
        result["level"] = info.level;
        result["birthday"] = info.birthday;
        
        for i in info.customInfo {
            retCustomInfo[i.key] = String(data: i.value, encoding: String.Encoding.utf8)
        }
        result["customInfo"] = retCustomInfo;
        
        return result;
    }
}
