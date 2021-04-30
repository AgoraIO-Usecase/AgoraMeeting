package io.agora.meeting.core.http.body.req;

import io.agora.meeting.core.annotaion.Keep;

/**
 * Description:
 *
 *
 * @since 2/15/21
 */
@Keep
public final class KickOutReq {
    public String targetUserId;

    public KickOutReq(String targetUserId) {
        this.targetUserId = targetUserId;
    }
}
