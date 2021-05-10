package io.agora.meeting.core.http.network;

import androidx.annotation.Nullable;

import io.agora.meeting.core.annotaion.Keep;

@Keep
public class HttpException extends RuntimeException {
    private final int code;
    private final String message;

    public HttpException(int code, @Nullable String message) {
        this.code = code;
        this.message = message;
    }

    public int getCode() {
        return code;
    }

    @Nullable
    @Override
    public String getMessage() {
        return message;
    }
}
