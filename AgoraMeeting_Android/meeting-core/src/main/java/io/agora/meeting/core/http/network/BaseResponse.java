package io.agora.meeting.core.http.network;

import io.agora.meeting.core.annotaion.Keep;

@Keep
public class BaseResponse<T> {
    public int code;
    public T msg;
    public long ts;
}
