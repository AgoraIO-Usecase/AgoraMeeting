package io.agora.meeting.service.body.req;

import io.agora.meeting.annotaion.room.GlobalModuleState;
import io.agora.meeting.annotaion.room.MeetingState;

public class RoomReq {
    @GlobalModuleState
    public Integer muteAllChat;
    @GlobalModuleState
    public Integer muteAllAudio;
    @MeetingState
    public Integer state;
}
