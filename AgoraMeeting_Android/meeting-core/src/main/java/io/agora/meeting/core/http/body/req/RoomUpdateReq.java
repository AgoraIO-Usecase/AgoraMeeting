package io.agora.meeting.core.http.body.req;

import io.agora.meeting.core.annotaion.Keep;

/**
 * Description:
 *
 *
 * @since 2/16/21
 */
@Keep
public final class RoomUpdateReq {

    public String userId;
    public String password;

    public RoomUpdateReq(String userId, String password) {
        this.userId = userId;
        this.password = password;
    }
}
