package io.agora.meeting.data;

public class Me extends Member {
    public String userUuid;
    public String rtcToken;
    public String rtmToken;
    public String screenToken;

    public Me(Me me, Member member) {
        super(member);
        userUuid = me.userUuid;
        rtcToken = me.rtcToken;
        rtmToken = me.rtmToken;
        screenToken = me.screenToken;
    }
}
