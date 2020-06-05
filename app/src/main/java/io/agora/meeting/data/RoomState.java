package io.agora.meeting.data;

import io.agora.meeting.annotaion.room.GlobalModuleState;
import io.agora.meeting.annotaion.room.MeetingState;
import io.agora.meeting.service.body.res.RoomRes;

public class RoomState {
    @GlobalModuleState
    public Integer muteAllChat;
    @GlobalModuleState
    public Integer muteAllAudio;
    @MeetingState
    public Integer state;

    public RoomState(RoomRes.Room room) {
        muteAllChat = room.muteAllChat;
        muteAllAudio = room.muteAllAudio;
        state = MeetingState.NORMAL;
    }
}
