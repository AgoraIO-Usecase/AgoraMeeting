package io.agora.meeting.service.body.req;

import io.agora.meeting.annotaion.member.ModuleState;

public class MemberReq {
    @ModuleState
    public Integer enableChat;
    @ModuleState
    public Integer enableVideo;
    @ModuleState
    public Integer enableAudio;
}
