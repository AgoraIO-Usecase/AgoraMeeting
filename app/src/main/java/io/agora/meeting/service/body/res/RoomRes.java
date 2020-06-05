package io.agora.meeting.service.body.res;

import java.util.List;

import io.agora.meeting.annotaion.room.GlobalModuleState;
import io.agora.meeting.data.Me;
import io.agora.meeting.data.Member;
import io.agora.meeting.data.ShareBoard;
import io.agora.meeting.data.ShareScreen;

public class RoomRes {
    public Room room;
    public Me user;

    public static class Room {
        public String roomId;
        public String roomUuid;
        public String roomName;
        public String channelName;
        public String password;
        @GlobalModuleState
        public Integer muteAllChat;
        @GlobalModuleState
        public Integer muteAllAudio;
        public Integer shareBoard;
        public Integer shareScreen;
        public String createBoardUserId;
        public int onlineUsers;
        public long startTime;
        public List<Member> hosts;
        public List<ShareScreen.Screen> shareScreenUsers;
        public List<ShareBoard.Board> shareBoardUsers;
    }
}
