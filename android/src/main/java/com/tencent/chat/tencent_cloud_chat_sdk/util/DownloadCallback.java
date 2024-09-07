package com.tencent.chat.tencent_cloud_chat_sdk.util;

public abstract class DownloadCallback {
    public DownloadCallback(){};
    public void onProgress(boolean isFinish,boolean isError,long currentSize,long totalSize,String msgID,int type,boolean isSnapshot,String path,int error_code,String error_desc){};
}