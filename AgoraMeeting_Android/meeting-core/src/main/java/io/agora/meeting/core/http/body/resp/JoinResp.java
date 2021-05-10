package io.agora.meeting.core.http.body.resp;


import io.agora.meeting.core.annotaion.Keep;
import io.agora.meeting.core.annotaion.UserRole;

/**
 * Description:
 *
 *
 * @since 2/3/21
 */
@Keep
public final class JoinResp {
    public String streamId;

    @UserRole
    public String userRole;

    public long startTime;
}
