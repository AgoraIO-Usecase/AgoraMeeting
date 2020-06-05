package io.agora.meeting.service.body.req;

import io.agora.meeting.annotaion.message.ChatType;

public class ChatReq {
    public String message;
    @ChatType
    public int type;
}
