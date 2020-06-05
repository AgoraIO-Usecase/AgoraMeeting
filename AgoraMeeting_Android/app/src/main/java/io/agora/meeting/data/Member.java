package io.agora.meeting.data;

import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.io.Serializable;

import io.agora.meeting.annotaion.member.ModuleState;
import io.agora.meeting.annotaion.member.Role;

public class Member implements Serializable {
    public String userId;
    public String userName;
    @Role
    public Integer role;
    @ModuleState
    public Integer enableChat;
    @ModuleState
    public Integer enableVideo;
    @ModuleState
    public Integer enableAudio;
    /**
     * User ID of RTC/RTM
     */
    public Integer uid;
    /**
     * User ID of screen sharing
     */
    public Integer screenId;
    @ModuleState
    public Integer grantBoard;
    @ModuleState
    public Integer grantScreen;

    public Member(Member member) {
        userId = member.userId;
        userName = member.userName;
        role = member.role;
        enableChat = member.enableChat;
        enableVideo = member.enableVideo;
        enableAudio = member.enableAudio;
        uid = member.uid;
        screenId = member.screenId;
        grantBoard = member.grantBoard;
        grantScreen = member.grantScreen;
    }

    public String getUidStr() {
        return String.valueOf(uid);
    }

    public boolean isHost() {
        return role == Role.HOST;
    }

    public boolean isChatEnable() {
        return enableChat == ModuleState.ENABLE;
    }

    public boolean isVideoEnable() {
        return enableVideo == ModuleState.ENABLE;
    }

    public boolean isAudioEnable() {
        return enableAudio == ModuleState.ENABLE;
    }

    public boolean isGrantBoard() {
        return grantBoard == ModuleState.ENABLE;
    }

    public boolean isGrantScreen() {
        return grantScreen == ModuleState.ENABLE;
    }

    @Override
    public boolean equals(@Nullable Object obj) {
        if (obj instanceof Member) {
            return TextUtils.equals(userId, ((Member) obj).userId);
        }
        return super.equals(obj);
    }

    @NonNull
    @Override
    public String toString() {
        return "Member{" +
                "userId='" + userId + '\'' +
                ", userName='" + userName + '\'' +
                '}';
    }
}
