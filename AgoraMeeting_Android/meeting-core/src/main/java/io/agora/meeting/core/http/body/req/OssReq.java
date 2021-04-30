package io.agora.meeting.core.http.body.req;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.agora.meeting.core.annotaion.Keep;

@Keep
public final class OssReq {
    public String appVersion;
    public String deviceName;
    public String deviceVersion;
    public String fileExt;
    public String platform;
    public Object tag;

    public OssReq(
            @Nullable String appVersion,
            @Nullable String deviceName,
            @NonNull String deviceVersion,
            /**
             * zip/log; 扩展名，如果传扩展名则以扩展名为准，如果不传，terminalType=3为log，其他为zip
             */
            @Nullable String fileExt,
            @NonNull String platform,
            @Nullable Object tag) {
        this.appVersion = appVersion;
        this.deviceName = deviceName;
        this.deviceVersion = deviceVersion;
        this.fileExt = fileExt;
        this.platform = platform;
        this.tag = tag;
    }
}
