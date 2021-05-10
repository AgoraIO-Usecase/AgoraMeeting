package io.agora.meeting.core.http.body.req;

import io.agora.meeting.core.annotaion.Keep;

/**
 * Description:
 *
 *
 * @since 2/16/21
 */
@Keep
public final class UserUpdateReq {

    public String userName;

    public UserUpdateReq(String userName) {
        this.userName = userName;
    }
}
