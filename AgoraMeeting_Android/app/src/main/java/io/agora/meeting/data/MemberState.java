package io.agora.meeting.data;

import io.agora.meeting.annotaion.member.AccessState;

public class MemberState extends Member {
    @AccessState
    public int state;

    public MemberState(Member member) {
        super(member);
    }
}
