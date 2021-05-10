package io.agora.meeting.core.model;

import androidx.annotation.NonNull;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

import io.agora.meeting.core.MeetingContext;
import io.agora.meeting.core.MeetingMsgHandler;
import io.agora.meeting.core.MeetingRteService;
import io.agora.meeting.core.annotaion.CauseCmdType;
import io.agora.meeting.core.annotaion.Keep;
import io.agora.meeting.core.base.BaseModel;
import io.agora.meeting.core.bean.ActionMessage;
import io.agora.meeting.core.bean.ChatMessage;
import io.agora.meeting.core.bean.PeerMessage;
import io.agora.meeting.core.bean.RoomProperties;
import io.agora.meeting.core.http.BaseCallback;
import io.agora.meeting.core.http.body.req.JoinReq;
import io.agora.meeting.core.http.body.req.RoomUpdateReq;
import io.agora.meeting.core.log.Logger;
import io.agora.rte.AgoraRteChatMsg;
import io.agora.rte.AgoraRteUserInfo;

/**
 * Description:
 *
 *
 * @since 2/7/21
 */
@Keep
public final class RoomModel extends BaseModel<RoomModel.Callback> {
    private final MeetingContext context;

    public final String roomId;
    public final String roomName;
    public final String roomPwd;
    private long roomStartTimestamp;

    private final List<UserModel> userModels;
    private JoinReq joinReqParams;

    private String localUserId;
    private final InnerRoomObserver innerRoomObserver = new InnerRoomObserver();
    private final MeetingMsgHandler.OnMsgReceiveListener msgReceiveListener = new MeetingMsgHandler.OnMsgReceiveListener() {
        @Override
        public void onActionMsgReceived(ActionMessage actionMessage) {
            invokeCallback(callback -> callback.onActionMessageReceived(actionMessage));
        }

        @Override
        public void onChatMsgReceived(ChatMessage chatMessage) {
            invokeCallback(callback -> callback.onChatMessageReceived(chatMessage));
        }
    };

    public RoomModel(MeetingContext context, String roomName, String roomId, String roomPwd) {
        this.context = context;
        this.roomName = roomName;
        this.roomPwd = roomPwd;
        this.roomId = roomId;
        userModels = new CopyOnWriteArrayList<>();
        context.rteService.registerRoomChangerObserver(roomId, innerRoomObserver);
        context.msgHandler.setOnMsgReceiveListener(msgReceiveListener);
    }

    /**
     * 加入房间，如果房间不存在，则创建房间
     */
    public void join(String userName, String userId, boolean openMic, boolean openCamera, int durationS, int maxPeople) {
        localUserId = userId;
        context.openLocalMic = openMic;
        context.openLocalCamera = openCamera;
        JoinReq body = new JoinReq();
        body.roomName = RoomModel.this.roomName;
        body.password = RoomModel.this.roomPwd;
        body.userName = userName;
        body.userId = localUserId;
        body.micAccess = openMic;
        body.cameraAccess = openCamera;
        body.duration = durationS;
        body.totalPeople = maxPeople;
        joinReqParams = body;
        Logger.d("Enter Room >> RoomModel join userId=" + userId);
        context.roomService.join(context.config.appId, roomId, body)
                .enqueue(new BaseCallback<>(data -> {
                    roomStartTimestamp = data.startTime;
                    context.rteService.joinRoom(roomId, localUserId, userName, data.streamId, data.userRole);
                }, error -> invokeCallback(callback -> {
                    callback.onError(error);
                    release();
                })));
    }



    /**
     * @return 房间创建时间
     */
    public long getStartTimestamp(){
        return roomStartTimestamp;
    }

    /**
     * @return 是否已经加入房间
     */
    public boolean hasJoined() {
        return userModels.size() > 0;
    }


    /**
     * 退出房间
     */
    public void leave() {
        context.roomService.leave(context.config.appId, roomId, localUserId)
                .enqueue(new BaseCallback<>(data -> {
                    context.rteService.leaveRoom();
                    release();
                }, throwable -> {
                    invokeCallback(callback -> callback.onError(throwable));
                    context.rteService.leaveRoom();
                    release();
                }));

    }

    /**
     * 关闭房间
     */
    public void close() {
        context.roomService.close(context.config.appId, roomId, localUserId)
                .enqueue(new BaseCallback<>(data -> {
                    context.rteService.leaveRoom();
                    release();
                }, throwable -> {
                    invokeCallback(callback -> callback.onError(throwable));
                    context.rteService.leaveRoom();
                    release();
                }));
    }

    /**
     * 更新房间信息，目前只支持更新密码
     */
    public void updateRoomInfo(String password) {
        context.roomService.updateRoomInfo(context.config.appId, roomId,
                new RoomUpdateReq(localUserId, password))
                .enqueue(new BaseCallback<>(error -> invokeCallback(callback -> callback.onError(error))));
    }

    /**
     * @return 房间里的所有用户数据
     */
    public List<UserModel> getUserModels() {
        return userModels;
    }

    /**
     * @return 当前设备登录的用户id
     */
    public String getLocalUserId() {
        return localUserId;
    }

    /**
     * @param userId 用户id
     * @return 用户id对应的用户数据
     */
    public UserModel getUserModelByUserId(String userId) {
        for (UserModel userModel : userModels) {
            if (userId.equals(userModel.getUserId())) {
                return userModel;
            }
        }
        return null;
    }

    /**
     * @return 是否有主持人
     */
    public boolean hasHost() {
        boolean ret = false;
        for (UserModel userModel : userModels) {
            if (userModel.isHost()) {
                ret = true;
                break;
            }
        }
        return ret;
    }


    /**
     * @return 是否正在白板共享
     */
    public boolean isBoardSharing() {
        return context.rteService != null && context.rteService.getRoomProperties() != null && context.rteService.getRoomProperties().isBoardSharing();
    }

    /**
     * @return 是否正在屏幕共享
     */
    public boolean isScreenSharing() {
        return context.rteService != null && context.rteService.getRoomProperties() != null && context.rteService.getRoomProperties().isScreenSharing();
    }

    /**
     * 释放所有资源，包括RTEEngine、用户数据，及用户对应的流数据
     */
    @Override
    public void release() {
        context.rteService.unregisterRoomChangeObserver(roomId, innerRoomObserver);
        context.msgHandler.setOnMsgReceiveListener(null);
        super.release();
        releaseUserModels();
        context.rteService.leaveRoom();
    }

    private void rejoinWithoutRte(){
        if(joinReqParams == null){
            return;
        }
        context.roomService.join(context.config.appId, roomId, joinReqParams)
                .enqueue(new BaseCallback<>(error -> invokeCallback(callback -> callback.onError(error))));
    }

    private void releaseUserModels() {
        for (UserModel userModel : userModels) {
            userModel.release();
        }
        userModels.clear();
    }

    private void parseSceneUsers(List<AgoraRteUserInfo> userInfos) {
        for (AgoraRteUserInfo userInfo : userInfos) {
            UserModel userModel = new UserModel(context, userInfo);
            userModels.add(userModel);
        }
    }

    public boolean screenOwnerOnline() {
        String screenOwnerId = context.rteService.getRoomProperties().getScreenOwnerId();
        for (UserModel userModel : userModels) {
            if(userModel.getUserId().equals(screenOwnerId)){
                return true;
            }
        }
        return false;
    }

    public boolean boardOwnerOnline() {
        String boardOwnerId = context.rteService.getRoomProperties().getBoardOwnerId();
        for (UserModel userModel : userModels) {
            if(userModel.getUserId().equals(boardOwnerId)){
                return true;
            }
        }
        return false;
    }


    private class InnerRoomObserver implements MeetingRteService.RoomChangeObserver {
        @Override
        public void onJoinFailure(Throwable error) {
            invokeCallback(callback -> {
                callback.onError(error);
                release();
            });
        }

        @Override
        public void onRoomClosed() {
            invokeCallback(Callback::onRoomClosed);
            release();
        }

        @Override
        public void onRoomPropertiesChanged(RoomProperties oldValue, RoomProperties newValue) {
            context.msgHandler.handleRoomProperties(oldValue, newValue);
            invokeCallback(callback -> callback.onRoomPropertiesChanged(newValue));
        }

        @Override
        public void onJoinSuccess(List<AgoraRteUserInfo> userInfos) {
            Logger.d("Enter Room >> RoomModel onJoinSuccess=" + userInfos);
            parseSceneUsers(userInfos);
        }

        @Override
        public void onReJoinSuccess() {

        }

        @Override
        public void onReJoinFailure() {
            invokeCallback(callback -> {
                callback.onRoomClosed();
                release();
            });
        }

        @Override
        public void onJoinComplete() {
            invokeCallback(callback -> callback.onJoinSuccess(userModels));
        }

        @Override
        public void onUserJoined(AgoraRteUserInfo user) {
            Logger.d("Enter Room >> RoomModel onUserJoined=" + user);
            UserModel userM = getUserModelByUserId(user.getUserId());
            if(userM == null){
                UserModel nUM = new UserModel(context, user);
                userModels.add(nUM);
                context.msgHandler.handleUserState(nUM, false);
                invokeCallback(callback -> callback.onUserModelAdd(nUM));
            }
        }

        @Override
        public void onUserLeft(AgoraRteUserInfo userInfo) {
            UserModel userM = getUserModelByUserId(userInfo.getUserId());
            if (userM != null) {
                if(userM.isLocal()){
                    invokeCallback(Callback::onKickedOut);
                    release();
                }else{
                    userModels.remove(userM);
                    context.msgHandler.handleUserState(userM, true);
                    invokeCallback(callback -> callback.onUserModelRemove(userM));
                    userM.release();
                }
            }
        }

        @Override
        public void onSceneMsgReceived(AgoraRteChatMsg chatMessage) {
            context.msgHandler.handleSceneChatMsg(context, chatMessage);
        }

        @Override
        public void onPeerMessageReceived(PeerMessage<?> peerMsg, AgoraRteUserInfo fromUser) {
            context.msgHandler.handlePeerMsg(context, peerMsg, fromUser);
        }

        @Override
        public void onActionCauseReceived(@NonNull AgoraRteUserInfo operator, @NonNull AgoraRteUserInfo target, @CauseCmdType int type, String reason) {
            context.msgHandler.handleActionCause(
                    getUserModelByUserId(operator.getUserId()),
                    getUserModelByUserId(target.getUserId()),
                    type, reason);
        }
    }

    @Keep
    public interface Callback {
        void onError(Throwable throwable);

        void onJoinSuccess(List<UserModel> roomUsers);

        void onRoomClosed();

        void onKickedOut();

        void onUserModelAdd(UserModel userModel);

        void onUserModelRemove(UserModel userModel);

        void onRoomPropertiesChanged(RoomProperties properties);

        void onChatMessageReceived(ChatMessage chatMsg);

        void onActionMessageReceived(ActionMessage actionMsg);
    }
}
