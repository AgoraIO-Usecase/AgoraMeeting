package io.agora.meeting.data;

import android.content.Context;

import com.google.gson.annotations.SerializedName;

import io.agora.meeting.annotaion.message.AdminAction;
import io.agora.meeting.annotaion.message.NormalAction;
import io.agora.meeting.annotaion.message.PeerCmd;
import io.agora.meeting.annotaion.room.Module;
import io.agora.meeting.util.TipsUtil;
import io.agora.meeting.viewmodel.MeetingViewModel;

public class PeerMsg<T> extends BaseMsg<T> {
    @PeerCmd
    public int getCmd() {
        return cmd;
    }

    public void setCmd(@PeerCmd int cmd) {
        this.cmd = cmd;
    }

    public static class Admin extends PeerMsg<Admin.SubMessage> {
        public static class SubMessage {
            public String userId;
            public String userName;
            @Module
            @SerializedName("type")
            public int module;
            @AdminAction
            public int action;
        }

        public void process(Context context, MeetingViewModel viewModel) {
            TipsUtil.processAdmin(context, this, viewModel);
        }
    }

    public static class Normal extends PeerMsg<Normal.SubMessage> {
        public static class SubMessage {
            public String userId;
            public String userName;
            @Module
            @SerializedName("type")
            public int module;
            @NormalAction
            public int action;
        }

        public void process(Context context, MeetingViewModel viewModel) {
            TipsUtil.processNormal(context, this, viewModel);
        }
    }
}
