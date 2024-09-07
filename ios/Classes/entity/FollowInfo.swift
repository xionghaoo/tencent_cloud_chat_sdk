import ImSDK_Plus
class FollowInfo: V2TIMFollowInfo {
    public static func getDict(info: V2TIMFollowInfo) -> [String: Any] {
        
        
        var result: [String: Any] = [:];
        
        result["resultInfo"] = info.resultInfo;
        result["followersCount"] = info.followersCount;
        result["userID"] = info.userID;
        result["resultCode"] = info.resultCode;
        result["mutualFollowersCount"] = info.mutualFollowersCount;
        result["followingCount"] = info.followingCount;
        

        
        return result;
    }
}
