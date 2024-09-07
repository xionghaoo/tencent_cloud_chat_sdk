package com.tencent.chat.tencent_cloud_chat_sdk.manager;

import com.tencent.chat.tencent_cloud_chat_sdk.util.AbCallback;
import com.tencent.chat.tencent_cloud_chat_sdk.util.CommonUtil;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMOfflinePushConfig;

import java.util.LinkedList;
import java.util.List;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class OfflinePushManager {
    private static List<MethodChannel> channels = new LinkedList<>();
    public OfflinePushManager(MethodChannel _channel){
        OfflinePushManager.channels.add(_channel);
    }
    public static void cleanChannels(){
        channels = new LinkedList<>();
    }
    public void setOfflinePushConfig(final MethodCall methodCall, final MethodChannel.Result result){
        CommonUtil.checkAbility(methodCall, new AbCallback() {
            @Override
            public void onAbSuccess() {
                Double businessID = CommonUtil.getParam(methodCall,result,"businessID");
                String token = CommonUtil.getParam(methodCall,result,"token");
                boolean isTPNSToken = CommonUtil.getParam(methodCall,result,"isTPNSToken");
                V2TIMManager.getOfflinePushManager().setOfflinePushConfig(new V2TIMOfflinePushConfig(new Double(businessID).longValue(),token), new V2TIMCallback() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtil.returnError(result,i,s);
                    }

                    @Override
                    public void onSuccess() {
                        CommonUtil.returnSuccess(result,null);
                    }
                });
            }

            @Override
            public void onAbError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void doBackground(final MethodCall methodCall, final MethodChannel.Result result){
        CommonUtil.checkAbility(methodCall, new AbCallback() {
            @Override
            public void onAbSuccess() {
                int unreadCount = CommonUtil.getParam(methodCall,result,"unreadCount");
                V2TIMManager.getOfflinePushManager().doBackground(unreadCount, new V2TIMCallback() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtil.returnError(result,i,s);
                    }

                    @Override
                    public void onSuccess() {
                        CommonUtil.returnSuccess(result,null);
                    }
                });
            }

            @Override
            public void onAbError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void doForeground(MethodCall methodCall, final MethodChannel.Result result){
        CommonUtil.checkAbility(methodCall, new AbCallback() {
            @Override
            public void onAbSuccess() {
                V2TIMManager.getOfflinePushManager().doForeground(new V2TIMCallback() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtil.returnError(result,i,s);
                    }

                    @Override
                    public void onSuccess() {
                        CommonUtil.returnSuccess(result,null);
                    }
                });
            }

            @Override
            public void onAbError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });

    }

}
