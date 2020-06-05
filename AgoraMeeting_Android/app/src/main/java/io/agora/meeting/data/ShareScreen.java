package io.agora.meeting.data;

import java.util.List;

import io.agora.meeting.annotaion.member.ModuleState;

public class ShareScreen {
    @ModuleState
    public Integer shareScreen;
    public List<Screen> shareScreenUsers;

    public boolean isShareScreen() {
        return shareScreen == ModuleState.ENABLE;
    }

    public static class Screen extends Member {
        public Screen(Member member) {
            super(member);
        }
    }
}
