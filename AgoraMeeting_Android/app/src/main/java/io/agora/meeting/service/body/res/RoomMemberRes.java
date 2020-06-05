package io.agora.meeting.service.body.res;

import java.util.List;

import io.agora.meeting.data.Member;

public class RoomMemberRes {
    public int count;
    public int total;
    public String nextId;
    public List<Member> list;
}
