package io.agora.meeting.core.http.body.req;

import io.agora.meeting.core.annotaion.Keep;

/**
 * Description:
 *
 *
 * @since 2/3/21
 */
@Keep
public final class JoinReq {
    public String roomName;
    public String userId;
    public String userName;
    public String password;

    public boolean micAccess;
    public boolean cameraAccess;
    public long duration; // 会议持续时长，单位:s
    public int totalPeople;

}
