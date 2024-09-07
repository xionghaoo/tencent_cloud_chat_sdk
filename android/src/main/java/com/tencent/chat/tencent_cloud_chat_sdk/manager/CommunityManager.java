package com.tencent.chat.tencent_cloud_chat_sdk.manager;

import com.tencent.chat.tencent_cloud_chat_sdk.util.CommonUtil;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMCommunityListener;
import com.tencent.imsdk.v2.V2TIMCreateGroupMemberInfo;
import com.tencent.imsdk.v2.V2TIMGroupInfo;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMPermissionGroupInfo;
import com.tencent.imsdk.v2.V2TIMPermissionGroupInfoResult;
import com.tencent.imsdk.v2.V2TIMPermissionGroupMemberInfoResult;
import com.tencent.imsdk.v2.V2TIMPermissionGroupMemberOperationResult;
import com.tencent.imsdk.v2.V2TIMPermissionGroupOperationResult;
import com.tencent.imsdk.v2.V2TIMTopicInfo;
import com.tencent.imsdk.v2.V2TIMTopicOperationResult;
import com.tencent.imsdk.v2.V2TIMTopicPermissionResult;
import com.tencent.imsdk.v2.V2TIMValueCallback;

import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class CommunityManager {
    static List<MethodChannel> channels = new LinkedList<>();
    public CommunityManager(MethodChannel channel){
        channels.add(channel);
    }
    static V2TIMCommunityListener listener = new V2TIMCommunityListener() {
        @Override
        public void onCreateTopic(String groupID, String topicID) {
            super.onCreateTopic(groupID, topicID);
            HashMap<String,Object> data = new HashMap<>();
            data.put("groupID",groupID);
            data.put("topicID",topicID);
            makeaddCommunityListenerEventData("onCreateTopic",data,"");
        }

        @Override
        public void onDeleteTopic(String groupID, List<String> topicIDList) {

            super.onDeleteTopic(groupID, topicIDList);
            HashMap<String,Object> data = new HashMap<>();
            data.put("groupID",groupID);
            data.put("topicIDList",topicIDList);
            makeaddCommunityListenerEventData("onDeleteTopic",data,"");
        }

        @Override
        public void onChangeTopicInfo(String groupID, V2TIMTopicInfo topicInfo) {

            super.onChangeTopicInfo(groupID, topicInfo);
            HashMap<String,Object> data = new HashMap<>();
            data.put("groupID",groupID);
            data.put("topicInfo",CommonUtil.convertV2TIMTopicInfoToMap(topicInfo));
            makeaddCommunityListenerEventData("onChangeTopicInfo",data,"");
        }

        @Override
        public void onReceiveTopicRESTCustomData(String topicID, byte[] customData) {
            super.onReceiveTopicRESTCustomData(topicID, customData);
            HashMap<String,Object> data = new HashMap<>();
            data.put("topicID",topicID);
            data.put("customData",new String(customData));
            makeaddCommunityListenerEventData("onReceiveTopicRESTCustomData",data,"");
        }

        @Override
        public void onCreatePermissionGroup(String groupID, V2TIMPermissionGroupInfo permissionGroupInfo) {
            super.onCreatePermissionGroup(groupID, permissionGroupInfo);
            HashMap<String,Object> data = new HashMap<>();
            data.put("groupID",groupID);
            data.put("permissionGroupInfo",CommonUtil.convertV2TIMPermissionGroupInfoToMap(permissionGroupInfo));
            makeaddCommunityListenerEventData("onCreatePermissionGroup",data,"");
        }

        @Override
        public void onDeletePermissionGroup(String groupID, List<String> permissionGroupIDList) {
            super.onDeletePermissionGroup(groupID, permissionGroupIDList);
            HashMap<String,Object> data = new HashMap<>();
            data.put("groupID",groupID);
            data.put("permissionGroupIDList",permissionGroupIDList);
            makeaddCommunityListenerEventData("onDeletePermissionGroup",data,"");
        }

        @Override
        public void onChangePermissionGroupInfo(String groupID, V2TIMPermissionGroupInfo permissionGroupInfo) {
            super.onChangePermissionGroupInfo(groupID, permissionGroupInfo);
            HashMap<String,Object> data = new HashMap<>();
            data.put("groupID",groupID);
            data.put("permissionGroupInfo",CommonUtil.convertV2TIMPermissionGroupInfoToMap(permissionGroupInfo));
            makeaddCommunityListenerEventData("onChangePermissionGroupInfo",data,"");
        }

        @Override
        public void onAddMembersToPermissionGroup(String groupID, String permissionGroupID, List<String> memberIDList) {
            super.onAddMembersToPermissionGroup(groupID, permissionGroupID, memberIDList);
            HashMap<String,Object> data = new HashMap<>();
            data.put("groupID",groupID);
            data.put("permissionGroupID",permissionGroupID);
            data.put("memberIDList",memberIDList);
            makeaddCommunityListenerEventData("onAddMembersToPermissionGroup",data,"");
        }

        @Override
        public void onRemoveMembersFromPermissionGroup(String groupID, String permissionGroupID, List<String> memberIDList) {
            super.onRemoveMembersFromPermissionGroup(groupID, permissionGroupID, memberIDList);
            HashMap<String,Object> data = new HashMap<>();
            data.put("groupID",groupID);
            data.put("permissionGroupID",permissionGroupID);
            data.put("memberIDList",memberIDList);
            makeaddCommunityListenerEventData("onRemoveMembersFromPermissionGroup",data,"");
        }

        @Override
        public void onAddTopicPermission(String groupID, String permissionGroupID, HashMap<String, Long> topicPermissionMap) {
            super.onAddTopicPermission(groupID, permissionGroupID, topicPermissionMap);
            HashMap<String,Object> data = new HashMap<>();
            data.put("groupID",groupID);
            data.put("permissionGroupID",permissionGroupID);
            data.put("topicPermissionMap",topicPermissionMap);
            makeaddCommunityListenerEventData("onAddTopicPermission",data,"");
        }

        @Override
        public void onDeleteTopicPermission(String groupID, String permissionGroupID, List<String> topicIDList) {
            super.onDeleteTopicPermission(groupID, permissionGroupID, topicIDList);
            HashMap<String,Object> data = new HashMap<>();
            data.put("groupID",groupID);
            data.put("permissionGroupID",permissionGroupID);
            data.put("topicIDList",topicIDList);
            makeaddCommunityListenerEventData("onDeleteTopicPermission",data,"");
        }

        @Override
        public void onModifyTopicPermission(String groupID, String permissionGroupID, HashMap<String, Long> topicPermissionMap) {
            super.onModifyTopicPermission(groupID, permissionGroupID, topicPermissionMap);
            HashMap<String,Object> data = new HashMap<>();
            data.put("groupID",groupID);
            data.put("permissionGroupID",permissionGroupID);
            data.put("topicPermissionMap",topicPermissionMap);
            makeaddCommunityListenerEventData("onModifyTopicPermission",data,"");
        }
    };
    private static  <T> void  makeaddCommunityListenerEventData(String type,T data, String listenerUuid){
        for (MethodChannel channel : channels) {
            CommonUtil.emitEvent(channel,"communityListener",type,data, listenerUuid);
        }
    }
    public void addCommunityListener(MethodCall methodCall, final MethodChannel.Result result){
        V2TIMManager.getCommunityManager().addCommunityListener(listener);
        CommonUtil.returnSuccess(result,"");
    }
    public void removeCommunityListener(MethodCall methodCall, final MethodChannel.Result result){
        V2TIMManager.getCommunityManager().removeCommunityListener(listener);
        CommonUtil.returnSuccess(result,"");
    }

    public void createCommunity(MethodCall methodCall, final MethodChannel.Result result){
        HashMap<String,Object> info = methodCall.argument("info");
        LinkedList<HashMap<String,Object>> memberList = methodCall.argument("memberList");

        LinkedList<V2TIMCreateGroupMemberInfo> n_member_info = new LinkedList();
        for (HashMap<String, Object> stringObjectHashMap : memberList) {
            V2TIMCreateGroupMemberInfo role = new V2TIMCreateGroupMemberInfo();
            if(stringObjectHashMap.containsKey("role")){
                role.setRole((Integer) stringObjectHashMap.get("role"));
            }
            if(stringObjectHashMap.containsKey("userID")){
                role.setUserID((String) stringObjectHashMap.get("userID"));
            }
            n_member_info.add(role);
        }
        V2TIMManager.getCommunityManager().createCommunity(CommonUtil.HashMapToV2TIMGroupInfo(info), n_member_info, new V2TIMValueCallback<String>() {
            @Override
            public void onSuccess(String s) {
                CommonUtil.returnSuccess(result,s);
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void createPermissionGroupInCommunity (MethodCall methodCall, final MethodChannel.Result result){
        HashMap<String,Object> info = methodCall.argument("info");
        V2TIMManager.getCommunityManager().createPermissionGroupInCommunity(CommonUtil.HashMapToV2TIMPermissionGroupInfo(info), new V2TIMValueCallback<String>() {
            @Override
            public void onSuccess(String s) {
                CommonUtil.returnSuccess(result,s);
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void deletePermissionGroupFromCommunity(MethodCall methodCall, final MethodChannel.Result result){
        String groupID =  methodCall.argument("groupID");
        List<String> permissionGroupIDList = methodCall.argument("permissionGroupIDList");
        V2TIMManager.getCommunityManager().deletePermissionGroupFromCommunity(groupID, permissionGroupIDList, new V2TIMValueCallback<List<V2TIMPermissionGroupOperationResult>>() {
            @Override
            public void onSuccess(List<V2TIMPermissionGroupOperationResult> v2TIMPermissionGroupOperationResults) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMPermissionGroupOperationResultListToMap(v2TIMPermissionGroupOperationResults));
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void modifyPermissionGroupInfoInCommunity(MethodCall methodCall, final MethodChannel.Result result){
        HashMap<String,Object> info = methodCall.argument("info");
        V2TIMManager.getCommunityManager().modifyPermissionGroupInfoInCommunity(CommonUtil.HashMapToV2TIMPermissionGroupInfo(info), new V2TIMCallback() {
            @Override
            public void onSuccess() {
                CommonUtil.returnSuccess(result,"");
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void getJoinedPermissionGroupListInCommunity(MethodCall methodCall, final MethodChannel.Result result){
        String groupID =  methodCall.argument("groupID");
        V2TIMManager.getCommunityManager().getJoinedPermissionGroupListInCommunity(groupID, new V2TIMValueCallback<List<V2TIMPermissionGroupInfoResult>>() {
            @Override
            public void onSuccess(List<V2TIMPermissionGroupInfoResult> v2TIMPermissionGroupInfoResults) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMPermissionGroupInfoResultListToMap(v2TIMPermissionGroupInfoResults));
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void getPermissionGroupListInCommunity(MethodCall methodCall, final MethodChannel.Result result){
        String groupID =  methodCall.argument("groupID");
        List<String> permissionGroupIDList = methodCall.argument("permissionGroupIDList");
        V2TIMManager.getCommunityManager().getPermissionGroupListInCommunity(groupID, permissionGroupIDList, new V2TIMValueCallback<List<V2TIMPermissionGroupInfoResult>>() {
            @Override
            public void onSuccess(List<V2TIMPermissionGroupInfoResult> v2TIMPermissionGroupInfoResults) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMPermissionGroupInfoResultListToMap(v2TIMPermissionGroupInfoResults));
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void addCommunityMembersToPermissionGroup(MethodCall methodCall, final MethodChannel.Result result){

        String groupID =  methodCall.argument("groupID");
        String permissionGroupID = methodCall.argument("permissionGroupID");
        List<String> memberList = methodCall.argument("memberList");
        V2TIMManager.getCommunityManager().addCommunityMembersToPermissionGroup(groupID, permissionGroupID, memberList, new V2TIMValueCallback<List<V2TIMPermissionGroupMemberOperationResult>>() {
            @Override
            public void onSuccess(List<V2TIMPermissionGroupMemberOperationResult> v2TIMPermissionGroupMemberOperationResults) {

                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMPermissionGroupMemberOperationResultListToMap(v2TIMPermissionGroupMemberOperationResults));
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void removeCommunityMembersFromPermissionGroup(MethodCall methodCall, final MethodChannel.Result result){
        String groupID =  methodCall.argument("groupID");
        String permissionGroupID = methodCall.argument("permissionGroupID");
        List<String> memberList = methodCall.argument("memberList");
        V2TIMManager.getCommunityManager().removeCommunityMembersFromPermissionGroup(groupID, permissionGroupID, memberList, new V2TIMValueCallback<List<V2TIMPermissionGroupMemberOperationResult>>() {
            @Override
            public void onSuccess(List<V2TIMPermissionGroupMemberOperationResult> v2TIMPermissionGroupMemberOperationResults) {

                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMPermissionGroupMemberOperationResultListToMap(v2TIMPermissionGroupMemberOperationResults));
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void getCommunityMemberListInPermissionGroup(MethodCall methodCall, final MethodChannel.Result result){
        String groupID =  methodCall.argument("groupID");
        String permissionGroupID = methodCall.argument("permissionGroupID");
        String nextCursor = methodCall.argument("nextCursor");
        V2TIMManager.getCommunityManager().getCommunityMemberListInPermissionGroup(groupID, permissionGroupID, nextCursor, new V2TIMValueCallback<V2TIMPermissionGroupMemberInfoResult>() {
            @Override
            public void onSuccess(V2TIMPermissionGroupMemberInfoResult v2TIMPermissionGroupMemberInfoResult) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMPermissionGroupMemberInfoResultToMap(v2TIMPermissionGroupMemberInfoResult));
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void addTopicPermissionToPermissionGroup(MethodCall methodCall, final MethodChannel.Result result){
        String groupID =  methodCall.argument("groupID");
        String permissionGroupID = methodCall.argument("permissionGroupID");
        HashMap<String,Number> topicPermissionMap = methodCall.argument("topicPermissionMap");
        HashMap<String,Long> customInfoLong = new HashMap<String,Long>();
        Iterator<String> iterator = topicPermissionMap.keySet().iterator();
        while (iterator.hasNext()) {
            String key = iterator.next();
            customInfoLong.put(key,Long.valueOf(topicPermissionMap.get(key).longValue()));
        }
        V2TIMManager.getCommunityManager().addTopicPermissionToPermissionGroup(groupID, permissionGroupID, customInfoLong, new V2TIMValueCallback<List<V2TIMTopicOperationResult>>() {
            @Override
            public void onSuccess(List<V2TIMTopicOperationResult> v2TIMTopicOperationResults) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMTopicOperationResultListToMap(v2TIMTopicOperationResults));
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void deleteTopicPermissionFromPermissionGroup(MethodCall methodCall, final MethodChannel.Result result){
        String groupID =  methodCall.argument("groupID");
        String permissionGroupID = methodCall.argument("permissionGroupID");
        List<String> topicIDList = methodCall.argument("topicIDList");
        V2TIMManager.getCommunityManager().deleteTopicPermissionFromPermissionGroup(groupID, permissionGroupID, topicIDList, new V2TIMValueCallback<List<V2TIMTopicOperationResult>>() {
            @Override
            public void onSuccess(List<V2TIMTopicOperationResult> v2TIMTopicOperationResults) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMTopicOperationResultListToMap(v2TIMTopicOperationResults));
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void modifyTopicPermissionInPermissionGroup(MethodCall methodCall, final MethodChannel.Result result){
        String groupID =  methodCall.argument("groupID");
        String permissionGroupID = methodCall.argument("permissionGroupID");
        HashMap<String,Number> topicPermissionMap = methodCall.argument("topicPermissionMap");
        HashMap<String,Long> customInfoLong = new HashMap<String,Long>();
        Iterator<String> iterator = topicPermissionMap.keySet().iterator();
        while (iterator.hasNext()) {
            String key = iterator.next();
            customInfoLong.put(key,Long.valueOf(topicPermissionMap.get(key).longValue()));
        }
        V2TIMManager.getCommunityManager().modifyTopicPermissionInPermissionGroup(groupID, permissionGroupID, customInfoLong, new V2TIMValueCallback<List<V2TIMTopicOperationResult>>() {
            @Override
            public void onSuccess(List<V2TIMTopicOperationResult> v2TIMTopicOperationResults) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMTopicOperationResultListToMap(v2TIMTopicOperationResults));
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void getTopicPermissionInPermissionGroup(MethodCall methodCall, final MethodChannel.Result result){
        String groupID =  methodCall.argument("groupID");
        String permissionGroupID = methodCall.argument("permissionGroupID");
        List<String> topicIDList = methodCall.argument("topicIDList");
        V2TIMManager.getCommunityManager().getTopicPermissionInPermissionGroup(groupID, permissionGroupID, topicIDList, new V2TIMValueCallback<List<V2TIMTopicPermissionResult>>() {
            @Override
            public void onSuccess(List<V2TIMTopicPermissionResult> v2TIMTopicPermissionResults) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMTopicPermissionResultListToMap(v2TIMTopicPermissionResults));
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
}
