package io.agora.meeting.service.body.req;

import com.google.gson.annotations.SerializedName;

import io.agora.meeting.annotaion.message.NormalAction;
import io.agora.meeting.annotaion.room.Module;

public class ApplyReq {
    @Module
    @SerializedName("type")
    public int module;
    @NormalAction
    public int action;
}
