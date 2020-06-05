package io.agora.meeting.service.body.req;

import io.agora.meeting.annotaion.member.ModuleState;

public class RoomEntryReq {
    public String userName;
    public String userUuid;
    public String roomName;
    public String roomUuid;
    public String password;
    @ModuleState
    public int enableVideo;
    @ModuleState
    public int enableAudio;
    public String avatar;
}
