package io.agora.meeting.core.bean;

import io.agora.meeting.core.annotaion.RequestState;

public class ScreenToken {

    public String rtcToken;
    public @RequestState int status;

    public ScreenToken(String rtcToken) {
        this.rtcToken = rtcToken;
        this.status = RequestState.SUCCESS;
    }

    public ScreenToken(int status) {
        this.status = status;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        ScreenToken that = (ScreenToken) o;

        return status == that.status;
    }

    @Override
    public int hashCode() {
        return status;
    }
}
