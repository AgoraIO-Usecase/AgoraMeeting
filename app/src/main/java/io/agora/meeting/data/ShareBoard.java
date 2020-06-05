package io.agora.meeting.data;

import java.util.List;

import io.agora.meeting.annotaion.member.ModuleState;

public class ShareBoard {
    @ModuleState
    public Integer shareBoard;
    public String createBoardUserId;
    public List<Board> shareBoardUsers;

    public boolean isShareBoard() {
        return shareBoard == ModuleState.ENABLE && shareBoardUsers.size() > 0;
    }

    public static class Board extends Member {
        public Board(Member member) {
            super(member);
        }
    }
}
