package com.tencent.chat.tencent_cloud_chat_sdk.util;

import com.tencent.imsdk.v2.V2TIMMessage;

public abstract class GetMesasgeByIDCallback {
    public GetMesasgeByIDCallback(){};

    public void onSuccess(V2TIMMessage msg){};

    public void onError(int code,String desc){};
}
