package io.agora.meeting.core;

import androidx.annotation.NonNull;

import io.agora.meeting.core.annotaion.ApproveRequest;
import io.agora.meeting.core.annotaion.CauseCmdType;
import io.agora.meeting.core.annotaion.CmdType;
import io.agora.meeting.core.annotaion.Device;
import io.agora.meeting.core.annotaion.ModuleState;
import io.agora.meeting.core.annotaion.UserRole;
import io.agora.meeting.core.bean.ActionMessage;
import io.agora.meeting.core.bean.ChatMessage;
import io.agora.meeting.core.bean.PeerMessage;
import io.agora.meeting.core.bean.RoomProperties;
import io.agora.meeting.core.log.Logger;
import io.agora.meeting.core.model.UserModel;
import io.agora.meeting.core.utils.TimeSyncUtil;
import io.agora.rte.AgoraRteChatMsg;
import io.agora.rte.AgoraRteUserInfo;

/**
 * Description:
 *
 *
 * @since 3/5/21
 */
public final class MeetingMsgHandler {
    private OnMsgReceiveListener onMsgReceiveListener;

    public void setOnMsgReceiveListener(OnMsgReceiveListener onMsgReceiveListener) {
        this.onMsgReceiveListener = onMsgReceiveListener;
    }

    public void handleActionCause(@NonNull UserModel operator, @NonNull UserModel target, @CauseCmdType int causeType, String reason) {
        Logger.d("MeetingMsgHandler >> handleActionCause type=" + causeType + ", reason=" + reason + ", operator=" + operator + ", target=" + target);
        ActionMessage actionMessage = null;
        switch (causeType) {
            case CauseCmdType.SINGLE_CAMERA_CLOSE:
            case CauseCmdType.SINGLE_MIC_CLOSE:
                if (operator.isHost() && !operator.getUserId().equals(target.getUserId())) {
                    actionMessage = new ActionMessage.AdminMute(target.isLocal(),
                            causeType == CauseCmdType.SINGLE_CAMERA_CLOSE ? Device.CAMERA : Device.MIC);
                }
                break;
            case CauseCmdType.BOARD_START:
            case CauseCmdType.BOARD_CLOSE:
                actionMessage = new ActionMessage.BoardChange(
                        operator.getUserId(),
                        operator.getUserName(),
                        causeType == CauseCmdType.BOARD_START ? ModuleState.ENABLE : ModuleState.DISABLE
                );
                break;
            case CauseCmdType.SCREEN_SHARE_START:
            case CauseCmdType.SCREEN_SHARE_CLOSE:
                actionMessage = new ActionMessage.ScreenChange(
                        operator.getUserId(),
                        operator.getUserName(),
                        causeType == CauseCmdType.SCREEN_SHARE_START ? ModuleState.ENABLE : ModuleState.DISABLE
                );
                break;
            default:
        }
        if (actionMessage != null) {
            notifyActionMsgReceived(actionMessage);
        }
    }


    public void handleSceneChatMsg(MeetingContext context, AgoraRteChatMsg chatMsg) {
        ChatMessage chatMessage = new ChatMessage(
                TimeSyncUtil.getSyncCurrentTimeMillis(),
                chatMsg.getMessageId(),
                chatMsg.getFromUser().getUserUuid(),
                chatMsg.getFromUser().getUserName(),
                chatMsg.getMessage()
        );
        notifyChatMsgReceived(chatMessage);
    }

    public void handlePeerMsg(MeetingContext context, PeerMessage<?> peerCmd, AgoraRteUserInfo fromUser) {
        ActionMessage actionMessage = null;
        if (CmdType.APPROVE == peerCmd.cmd) {
            PeerMessage.Approve.Data approveData = ((PeerMessage.Approve) peerCmd).data;
            RoomProperties roomProperties = context.rteService.getRoomProperties();
            actionMessage = new ActionMessage.Approve(
                    approveData.fromUser.getUserUuid(),
                    approveData.fromUser.getUserName(),
                    approveData.action,
                    approveData.processUuid,
                    ApproveRequest.MIC.equals(approveData.processUuid) ?
                            roomProperties.processes.micAccess.timeout : roomProperties.processes.cameraAccess.timeout
            );
        }
        else if(CmdType.MUTE_ALL == peerCmd.cmd){
            PeerMessage.MuteAll muteAll = (PeerMessage.MuteAll) peerCmd;
            PeerMessage.MuteAll.Data muteAllData = muteAll.data;
            actionMessage = new ActionMessage.AdminMuteAll(
                    "",
                    "",
                    muteAllData.device == Device.CAMERA ? Device.CAMERA : Device.MIC);
        }
        if (actionMessage != null) {
            notifyActionMsgReceived(actionMessage);
        }
    }

    public void handleRoomProperties(RoomProperties oldValue, RoomProperties newValue) {
        if(oldValue == null){
            return;
        }
        boolean micAccess = oldValue.userPermission.micAccess;
        if (Boolean.compare(micAccess, newValue.userPermission.micAccess) != 0) {
            notifyActionMsgReceived(new ActionMessage.Access(
                    Device.MIC,
                    newValue.userPermission.micAccess ? ModuleState.ENABLE : ModuleState.DISABLE
            ));
        }
        boolean cameraAccess = oldValue.userPermission.cameraAccess;
        if (Boolean.compare(cameraAccess, newValue.userPermission.cameraAccess) != 0) {
            notifyActionMsgReceived(new ActionMessage.Access(
                    Device.CAMERA,
                    newValue.userPermission.cameraAccess ? ModuleState.ENABLE : ModuleState.DISABLE
            ));
        }
    }

    public void handleBoardInteractState(String userId, String userName, boolean open) {
        notifyActionMsgReceived(new ActionMessage.BoardInteract(
                userId,
                userName,
                open ? ModuleState.ENABLE : ModuleState.DISABLE
        ));
    }

    public void handleUserState(UserModel userModel, boolean isLeft) {
        if (userModel.isLocal()) {
            if (isLeft) {
                notifyActionMsgReceived(new ActionMessage.AdminKickOut(
                        userModel.getUserId(),
                        userModel.getUserName()
                ));
            }
        } else {
            notifyActionMsgReceived(new ActionMessage.UserChange(
                    userModel.getUserId(),
                    userModel.getUserName(),
                    isLeft ? ModuleState.DISABLE : ModuleState.ENABLE
            ));
        }
    }

    public void handleUserRoleChange(AgoraRteUserInfo userInfo) {
        ActionMessage.AdminChange message = new ActionMessage.AdminChange(
                userInfo.getUserId(),
                userInfo.getUserName()
        );
        message.isAbandon = !userInfo.getRole().equals(UserRole.HOST);
        notifyActionMsgReceived(message);
    }

    private void notifyActionMsgReceived(ActionMessage message) {
        if (onMsgReceiveListener != null) {
            onMsgReceiveListener.onActionMsgReceived(message);
        }
    }

    private void notifyChatMsgReceived(ChatMessage message) {
        if (onMsgReceiveListener != null) {
            onMsgReceiveListener.onChatMsgReceived(message);
        }
    }


    public interface OnMsgReceiveListener {
        void onActionMsgReceived(ActionMessage actionMessage);

        void onChatMsgReceived(ChatMessage chatMessage);
    }
}
