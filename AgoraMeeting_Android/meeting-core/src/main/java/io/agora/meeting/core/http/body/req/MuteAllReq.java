package io.agora.meeting.core.http.body.req;

import io.agora.meeting.core.annotaion.Keep;

/**
 * Description:
 *
 *
 * @since 3/9/21
 */
@Keep
public final class MuteAllReq {
    public boolean micClose;
    public boolean cameraClose;
}
