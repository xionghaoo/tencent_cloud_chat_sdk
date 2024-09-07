import ImSDK_Plus
class FollowOperationResult: V2TIMFollowOperationResult {
    public static func getDict(info: V2TIMFollowOperationResult) -> [String: Any] {
        var result: [String: Any] = [:];
        
        result["resultInfo"] = info.resultInfo;
        result["userID"] = info.userID;
        result["resultCode"] = info.resultCode;
        
        
        
        return result;
    }
}
