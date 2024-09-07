package com.tencent.chat.tencent_cloud_chat_sdk.util;



public abstract class AbCallback {
    public AbCallback(){};
    public void onAbSuccess(){};
    public void onAbError(int code,String desc){};
}
