package io.agora.meeting.core.http.body.req;

import io.agora.meeting.core.annotaion.Keep;

/**
 * Description:
 *
 *
 * @since 2/14/21
 */
@Keep
public final class UserPermCloseReq {
    public boolean micClose;
    public boolean cameraClose;
    public String targetUserId;
}
