package io.agora.meeting.viewmodel;

import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.google.gson.Gson;

import org.jetbrains.annotations.NotNull;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

import io.agora.base.ToastManager;
import io.agora.meeting.R;
import io.agora.meeting.annotaion.member.AccessState;
import io.agora.meeting.annotaion.member.ModuleState;
import io.agora.meeting.annotaion.member.Role;
import io.agora.meeting.annotaion.message.BroadcastCmd;
import io.agora.meeting.annotaion.message.PeerCmd;
import io.agora.meeting.data.BroadcastMsg;
import io.agora.meeting.data.Me;
import io.agora.meeting.data.Member;
import io.agora.meeting.data.MemberState;
import io.agora.meeting.data.PeerMsg;
import io.agora.meeting.util.Events;
import io.agora.rtm.RtmChannelMember;
import io.agora.rtm.RtmMessage;
import io.agora.sdk.listener.RtmEventListener;

public class RtmEventHandler extends RtmEventListener {
    private static final int VERSION = 1;

    private Gson gson = new Gson();
    private MeetingViewModel meetingVM;
    private MessageViewModel messageVM;

    public RtmEventHandler(@NonNull MeetingViewModel meetingVM, @NotNull MessageViewModel messageVM) {
        this.meetingVM = meetingVM;
        this.messageVM = messageVM;
    }

    @Override
    public void onReJoinChannelSuccess(String channel) {
        meetingVM.getRoomInfo(meetingVM.getRoomId());
    }

    @Override
    public void onMessageReceived(RtmMessage rtmMessage, RtmChannelMember rtmChannelMember) {
        String json = rtmMessage.getText();
        try {
            JSONObject jsonObject = new JSONObject(json);
            int version = jsonObject.getInt("version");
            if (version != VERSION) return; // return if the version not match
            int cmd = jsonObject.getInt("cmd");
            switch (cmd) {
                case BroadcastCmd.CHAT:
                    onChatMsgReceived(json);
                    break;
                case BroadcastCmd.ACCESS:
                    onUserAccessChanged(json);
                    break;
                case BroadcastCmd.ROOM:
                    onRoomInfoUpdate(json);
                    break;
                case BroadcastCmd.USER:
                    onUserInfoUpdated(json);
                    break;
                case BroadcastCmd.BOARD:
                    onBoardInfoUpdated(json);
                    break;
                case BroadcastCmd.SCREEN:
                    onScreenInfoUpdated(json);
                    break;
                case BroadcastCmd.HOST:
                    onHostsUpdated(json);
                    break;
                case BroadcastCmd.KICK:
                    onKickOutMsgReceived(json);
                    break;
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onMessageReceived(RtmMessage rtmMessage, String s) {
        String json = rtmMessage.getText();
        try {
            JSONObject jsonObject = new JSONObject(json);
            int version = jsonObject.getInt("version");
            if (version != VERSION) return; // return if the version not match
            int cmd = jsonObject.getInt("cmd");
            switch (cmd) {
                case PeerCmd.ADMIN:
                    onAdminMsgReceived(json);
                    break;
                case PeerCmd.NORMAL:
                    onNormalMsgReceived(json);
                    break;
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void onChatMsgReceived(String json) {
        BroadcastMsg.Chat chat = gson.fromJson(json, BroadcastMsg.Chat.class);
        chat.data.isMe = meetingVM.isMe(chat.data.userId);

        List<BroadcastMsg.Chat> messages = messageVM.getChatMsgsValue();
        messages.add(chat);
        messageVM.updateChatMsgs(messages);
    }

    private void onUserAccessChanged(String json) {
        BroadcastMsg.Access access = gson.fromJson(json, BroadcastMsg.Access.class);

        List<Member> hosts = meetingVM.getHostsValue();
        List<Member> audiences = meetingVM.getAudiencesValue();

        for (MemberState memberState : access.data.list) {
            // skip myself
            if (meetingVM.isMe(memberState)) continue;

            switch (memberState.state) {
                case AccessState.EXIT:
                    if (memberState.role == Role.HOST) {
                        hosts.remove(memberState);
                    } else if (memberState.role == Role.AUDIENCE) {
                        audiences.remove(memberState);
                    }
                    ToastManager.showShort(R.string.member_leave, memberState.userName);
                    break;
                case AccessState.ENTER:
                    if (memberState.role == Role.HOST) {
                        int index = hosts.indexOf(memberState);
                        if (index > -1) {
                            hosts.set(index, memberState);
                        } else {
                            hosts.add(memberState);
                        }
                    } else if (memberState.role == Role.AUDIENCE) {
                        int index = audiences.indexOf(memberState);
                        if (index > -1) {
                            audiences.set(index, memberState);
                        } else {
                            audiences.add(memberState);
                        }
                    }
                    ToastManager.showShort(R.string.member_enter, memberState.userName);
                    break;
            }
        }

        meetingVM.updateHosts(hosts);
        meetingVM.updateAudiences(audiences);
    }

    private void onRoomInfoUpdate(String json) {
        BroadcastMsg.Room room = gson.fromJson(json, BroadcastMsg.Room.class);
        meetingVM.updateRoomState(room.data);
    }

    private void onUserInfoUpdated(String json) {
        BroadcastMsg.User user = gson.fromJson(json, BroadcastMsg.User.class);
        Member source = user.data;

        if (meetingVM.isMe(source)) {
            meetingVM.updateMe(source);
            return;
        }
        if (source.role == Role.HOST) {
            List<Member> hosts = meetingVM.getHostsValue();
            int index = hosts.indexOf(source);
            if (index > -1) {
                hosts.set(index, source);
            }
            meetingVM.updateHosts(hosts);
        } else if (source.role == Role.AUDIENCE) {
            List<Member> audiences = meetingVM.getAudiencesValue();
            int index = audiences.indexOf(source);
            if (index > -1) {
                audiences.set(index, source);
            }
            meetingVM.updateAudiences(audiences);
        }
    }

    private void onBoardInfoUpdated(String json) {
        BroadcastMsg.Board board = gson.fromJson(json, BroadcastMsg.Board.class);
        meetingVM.updateShareBoard(board.data);

        Me me = meetingVM.getMeValue();
        if (me != null) {
            boolean contains = board.data.shareBoardUsers.contains(me);
            if (me.isGrantBoard() != contains) {
                meetingVM.updateMe(new Member(me) {{
                    grantBoard = contains ? ModuleState.ENABLE : ModuleState.DISABLE;
                }});
            }
        }

        List<Member> hosts = meetingVM.getHostsValue();
        for (int i = 0; i < hosts.size(); i++) {
            Member member = hosts.get(i);
            boolean contains = board.data.shareBoardUsers.contains(member);
            if (member.isGrantBoard() != contains) {
                hosts.set(i, new Member(member) {{
                    grantBoard = contains ? ModuleState.ENABLE : ModuleState.DISABLE;
                }});
            }
        }
        meetingVM.updateHosts(hosts);

        List<Member> audiences = meetingVM.getAudiencesValue();
        for (int i = 0; i < audiences.size(); i++) {
            Member member = audiences.get(i);
            boolean contains = board.data.shareBoardUsers.contains(member);
            if (member.isGrantBoard() != contains) {
                audiences.set(i, new Member(member) {{
                    grantBoard = contains ? ModuleState.ENABLE : ModuleState.DISABLE;
                }});
            }
        }
        meetingVM.updateAudiences(audiences);
    }

    private void onScreenInfoUpdated(String json) {
        BroadcastMsg.Screen screen = gson.fromJson(json, BroadcastMsg.Screen.class);
        meetingVM.updateShareScreen(screen.data);

        Me me = meetingVM.getMeValue();
        if (me != null) {
            boolean contains = screen.data.shareScreenUsers.contains(me);
            if (me.isGrantScreen() != contains) {
                meetingVM.updateMe(new Member(me) {{
                    grantScreen = contains ? ModuleState.ENABLE : ModuleState.DISABLE;
                }});
            }
        }

        List<Member> hosts = meetingVM.getHostsValue();
        for (int i = 0; i < hosts.size(); i++) {
            Member member = hosts.get(i);
            boolean contains = screen.data.shareScreenUsers.contains(member);
            if (member.isGrantScreen() != contains) {
                hosts.set(i, new Member(member) {{
                    grantScreen = contains ? ModuleState.ENABLE : ModuleState.DISABLE;
                }});
            }
        }
        meetingVM.updateHosts(hosts);

        List<Member> audiences = meetingVM.getAudiencesValue();
        for (int i = 0; i < audiences.size(); i++) {
            Member member = audiences.get(i);
            boolean contains = screen.data.shareScreenUsers.contains(member);
            if (member.isGrantScreen() != contains) {
                audiences.set(i, new Member(member) {{
                    grantScreen = contains ? ModuleState.ENABLE : ModuleState.DISABLE;
                }});
            }
        }
        meetingVM.updateAudiences(audiences);
    }

    private void onHostsUpdated(String json) {
        List<Member> hosts = new ArrayList<>();
        List<Member> audiences = meetingVM.getAudiencesValue();

        BroadcastMsg.Host host = gson.fromJson(json, BroadcastMsg.Host.class);
        for (MemberState memberState : host.data) {
            if (meetingVM.isMe(memberState)) {
                meetingVM.updateMe(memberState);
            } else {
                switch (memberState.role) {
                    case Role.HOST:
                        hosts.add(memberState);
                        audiences.remove(memberState);
                        break;
                    case Role.AUDIENCE:
                        if (memberState.state == AccessState.ENTER) {
                            audiences.add(memberState);
                        }
                        break;
                }
            }
        }

        meetingVM.updateHosts(hosts);
        meetingVM.updateAudiences(audiences);
    }

    private void onKickOutMsgReceived(String json) {
        BroadcastMsg.Kick kick = gson.fromJson(json, BroadcastMsg.Kick.class);
        if (TextUtils.equals(kick.data.userId, meetingVM.getMyUserId())) {
            Events.KickEvent.setEvent();
        }
    }

    private void onAdminMsgReceived(String json) {
        PeerMsg.Admin admin = gson.fromJson(json, PeerMsg.Admin.class);
        List<PeerMsg.Admin> adminMsgs = messageVM.getAdminMsgsValue();
        adminMsgs.add(admin);
        messageVM.updateAdminMsgs(adminMsgs);
    }

    private void onNormalMsgReceived(String json) {
        PeerMsg.Normal normal = gson.fromJson(json, PeerMsg.Normal.class);
        List<PeerMsg.Normal> normalMsgs = messageVM.getNormalMsgsValue();
        normalMsgs.add(normal);
        messageVM.updateNormalMsgs(normalMsgs);
    }
}
