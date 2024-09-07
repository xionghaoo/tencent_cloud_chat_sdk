import ImSDK_Plus
class FollowTypeCheckResult: V2TIMFollowTypeCheckResult {
    public static func getDict(info: V2TIMFollowTypeCheckResult) -> [String: Any] {
        var result: [String: Any] = [:];
        
        result["resultInfo"] = info.resultInfo;
        result["userID"] = info.userID;
        result["resultCode"] = info.resultCode;
        result["followType"] = info.followType.rawValue;
        
        
        
        return result;
    }
}
