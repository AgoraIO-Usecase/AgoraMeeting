package io.agora.meeting.service.body.req;

import com.google.gson.annotations.SerializedName;

import io.agora.meeting.annotaion.message.AdminAction;
import io.agora.meeting.annotaion.room.Module;

public class InviteReq {
    @Module
    @SerializedName("type")
    public int module;
    @AdminAction
    public int action;
}
