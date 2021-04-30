package io.agora.meeting.core.http.body;

import io.agora.meeting.core.annotaion.Keep;
import io.agora.meeting.core.http.network.BaseResponse;

@Keep
public class ResponseBody<T> extends BaseResponse<String> {
    public T data;

    @Override
    public String toString() {
        return "{" +
                "\"data\"=" + data +
                ", \"code\"=" + code +
                ", \"msg\"=" + msg +
                '}';
    }
}
