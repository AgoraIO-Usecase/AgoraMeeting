package io.agora.meeting.core.http.body.req;

import io.agora.meeting.core.annotaion.Keep;

/**
 * Description:
 *
 *
 * @since 2/15/21
 */
@Keep
public final class TargetUserIdReq {

    public String targetUserId;

    public TargetUserIdReq(String targetUserId) {
        this.targetUserId = targetUserId;
    }
}
