package io.agora.meeting.data;

import java.util.List;

import io.agora.meeting.annotaion.message.BroadcastCmd;
import io.agora.meeting.annotaion.message.ChatType;

public class BroadcastMsg<T> extends BaseMsg<T> {
    @BroadcastCmd
    public int getCmd() {
        return cmd;
    }

    public void setCmd(@BroadcastCmd int cmd) {
        this.cmd = cmd;
    }

    public static class Chat extends BroadcastMsg<Chat.SubMessage> {
        public static class SubMessage {
            public String userId;
            public String userName;
            public String message;
            @ChatType
            public int type;
            public transient boolean isMe;
            public transient boolean isRead;
        }
    }

    public static class Access extends BroadcastMsg<Access.SubMessage> {
        public static class SubMessage {
            public int total;
            public List<MemberState> list;
        }
    }

    public static class Room extends BroadcastMsg<RoomState> {
    }

    public static class User extends BroadcastMsg<Member> {
    }

    public static class Board extends BroadcastMsg<ShareBoard> {
    }

    public static class Screen extends BroadcastMsg<ShareScreen> {
    }

    public static class Host extends BroadcastMsg<List<MemberState>> {
    }

    public static class Kick extends BroadcastMsg<Kick.SubMessage> {
        public static class SubMessage {
            public String hostUserId;
            public String hostUserName;
            public String userId;
            public String userName;
        }
    }
}
