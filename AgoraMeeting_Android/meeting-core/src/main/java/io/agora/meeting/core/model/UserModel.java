package io.agora.meeting.core.model;

import android.text.TextUtils;

import androidx.annotation.Nullable;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import io.agora.meeting.core.MeetingContext;
import io.agora.meeting.core.MeetingRteService;
import io.agora.meeting.core.annotaion.Device;
import io.agora.meeting.core.annotaion.Keep;
import io.agora.meeting.core.annotaion.RequestState;
import io.agora.meeting.core.annotaion.StreamType;
import io.agora.meeting.core.annotaion.UserRole;
import io.agora.meeting.core.base.BaseModel;
import io.agora.meeting.core.bean.RoomProperties;
import io.agora.meeting.core.bean.ScreenToken;
import io.agora.meeting.core.http.BaseCallback;
import io.agora.meeting.core.http.body.req.ChatReq;
import io.agora.meeting.core.http.body.req.KickOutReq;
import io.agora.meeting.core.http.body.req.MuteAllReq;
import io.agora.meeting.core.http.body.req.TargetUserIdReq;
import io.agora.meeting.core.http.body.req.UserPermAccessReq;
import io.agora.meeting.core.http.body.req.UserUpdateReq;
import io.agora.meeting.core.http.body.resp.NullResp;
import io.agora.meeting.core.log.Logger;
import io.agora.rte.AgoraRteStreamInfo;
import io.agora.rte.AgoraRteUserInfo;

/**
 * Description:
 *
 *
 * @since 2/7/21
 */
@Keep
public final class UserModel extends BaseModel<UserModel.CallBack> {

    private final MeetingContext context;
    private AgoraRteUserInfo mUserInfo;

    private final List<StreamModel> streamModels;

    private final InnerUserObserver innerUserObserver = new InnerUserObserver();

    public UserModel(MeetingContext context, AgoraRteUserInfo userInfo) {
        this.context = context;
        this.mUserInfo = userInfo;
        streamModels = new ArrayList<>();
        context.rteService.registerUserChangerObserver(mUserInfo.getUserId(), innerUserObserver);
    }

    /**
     * @return 是否是本地设备登录的用户
     */
    public boolean isLocal() {
        return mUserInfo.getUserId().equals(context.rteService.getLocalUserId());
    }

    public String getUserId() {
        return mUserInfo.getUserId();
    }

    public String getUserName() {
        return mUserInfo.getUserName();
    }

    /**
     * @return 是否是主持人
     */
    public boolean isHost() {
        return UserRole.HOST.equals(mUserInfo.getRole());
    }

    @UserRole
    public String getUserRole() {
        return mUserInfo.getRole();
    }

    /**
     * 更新用户信息，暂只支持用户名
     */
    public void updateUserInfo(String userName) {
        context.userService.updateUserInfo(context.config.appId, context.rteService.getRoomId(), mUserInfo.getUserId(),
                new UserUpdateReq(userName)).enqueue(new BaseCallback<>(error -> invokeCallback(callBack -> callBack.onError(error))));
    }

    /**
     * 在房间里发言
     */
    public void speak(String content, BaseCallback.SuccessCallback<NullResp> success, BaseCallback.FailureCallback failure) {
        ChatReq body = new ChatReq();
        body.message = content;
        context.userService.chat(context.config.appId, context.rteService.getRoomId(), getUserId(), body).enqueue(new BaseCallback<>(success, failure));
    }

    /**
     * 取消用户摄像头/麦克风打开申请
     */
    public void cancelPermRequest(String requestId) {
        if (!isLocal()) {
            return;
        }
        context.userService.cancelUserPermissionsReq(context.config.appId, context.rteService.getRoomId(),
                getUserId(), requestId).enqueue(new BaseCallback<>(error -> invokeCallback(callBack -> callBack.onError(error))));
    }

    /**
     * 通过用户摄像头/麦克风打开申请
     */
    public void acceptPermRequest(String requestId, String userId, BaseCallback.FailureCallback failure) {
        if (!isLocal()) {
            return;
        }
        context.userService.acceptUserPermissionsReq(context.config.appId, context.rteService.getRoomId(),
                getUserId(), requestId, new TargetUserIdReq(userId)).enqueue(new BaseCallback<>(failure));
    }

    /**
     * 拒绝用户摄像头/麦克风打开申请
     */
    public void rejectPermRequest(String requestId, String userId, BaseCallback.FailureCallback failure) {
        if (!isLocal()) {
            return;
        }
        context.userService.rejectUserPermissionsReq(context.config.appId, context.rteService.getRoomId(),
                getUserId(), requestId, new TargetUserIdReq(userId)).enqueue(new BaseCallback<>(failure));
    }

    /**
     * @return 是否是屏幕共享的发起者
     */
    public boolean isScreenOwner() {
        RoomProperties roomProperties = context.rteService.getRoomProperties();
        if (roomProperties == null) {
            return false;
        }
        return roomProperties.isScreenSharing() && getUserId().equals(roomProperties.getScreenOwnerId());
    }

    /**
     * 开启屏幕共享
     */
    public void startScreenShare() {
        if (!isLocal()) {
            return;
        }
        context.screenRtcToken.setData(new ScreenToken(RequestState.REQUESTING));
        context.userService.startScreen(context.config.appId, context.rteService.getRoomId(),
                mUserInfo.getUserId())
                .enqueue(new BaseCallback<>(data -> {
                    String screenRtcToken = data.rtcToken;
                    Logger.d("ScreenShare >> " + "start request end. rtcToken=" + screenRtcToken);
                    context.screenRtcToken.setData(new ScreenToken(screenRtcToken));
                }, error -> invokeCallback(callBack -> callBack.onError(error))));
    }

    /**
     * 关闭屏幕共享
     */
    public void stopScreenShare() {
        if (!isLocal()) {
            return;
        }
        context.screenRtcToken.clean();
        context.userService.stopScreen(context.config.appId, context.rteService.getRoomId(),
                mUserInfo.getUserId())
                .enqueue(new BaseCallback<>(error -> invokeCallback(callBack -> callBack.onError(error))));
    }

    /**
     * @return 当前用户是否是白板的发起者
     */
    public boolean isBoardOwner() {
        RoomProperties roomProperties = context.rteService.getRoomProperties();
        return roomProperties.isBoardSharing() && getUserId().equals(roomProperties.getBoardOwnerId());
    }


    /**
     * 开启白板共享
     */
    public void startBoardShare() {
        if (!isLocal()) {
            return;
        }
        context.userService.startBoard(context.config.appId, context.rteService.getRoomId(),
                mUserInfo.getUserId())
                .enqueue(new BaseCallback<>(error -> invokeCallback(callBack -> callBack.onError(error))));
    }

    /**
     * 关闭白板共享
     */
    public void stopBoardShare() {
        if (!isLocal()) {
            return;
        }
        context.userService.stopBoard(context.config.appId, context.rteService.getRoomId(),
                mUserInfo.getUserId())
                .enqueue(new BaseCallback<>(error -> invokeCallback(callBack -> callBack.onError(error))));
    }

    /**
     * 申请白板互动
     */
    public void applyBoardInteract() {
        if (!isLocal()) {
            return;
        }
        context.userService.applyBoardInteract(context.config.appId, context.rteService.getRoomId(),
                mUserInfo.getUserId())
                .enqueue(new BaseCallback<>(error -> invokeCallback(callBack -> callBack.onError(error))));
    }


    /**
     * 取消白板互动
     */
    public void cancelBoardInteract() {
        if (!isLocal()) {
            return;
        }
        context.userService.cancelBoardInteract(context.config.appId, context.rteService.getRoomId(),
                mUserInfo.getUserId())
                .enqueue(new BaseCallback<>(error -> invokeCallback(callBack -> callBack.onError(error))));
    }

    public void changeUserPermission(@Device int device, boolean access) {
        changeUserPermission(device, access, null, null);
    }

    /**
     * 修改房间观众和主持人是否有打开摄像头和麦克风的权限
     */
    public void changeUserPermission(@Device int device, boolean access, @Nullable Runnable success, @Nullable Runnable failure) {
        if (mUserInfo.getRole().equals(UserRole.HOST)) {
            if (device == Device.CAMERA) {
                context.userService.changeUserPermissions(context.config.appId, context.rteService.getRoomId(),
                        mUserInfo.getUserId(),
                        new UserPermAccessReq(context.rteService.getRoomProperties().userPermission.micAccess, access))
                        .enqueue(new BaseCallback<>(data -> {
                            if (success != null) success.run();
                        }, error -> {
                            invokeCallback(callBack -> callBack.onError(error));
                            if (failure != null) failure.run();
                        }));
            } else {
                context.userService.changeUserPermissions(context.config.appId, context.rteService.getRoomId(),
                        mUserInfo.getUserId(),
                        new UserPermAccessReq(access, context.rteService.getRoomProperties().userPermission.cameraAccess))
                        .enqueue(new BaseCallback<>(data -> {
                            if (success != null) success.run();
                        }, error -> {
                            invokeCallback(callBack -> callBack.onError(error));
                            if (failure != null) failure.run();
                        }));
            }
        }
    }

    /**
     * 放弃主持人
     */
    public void giveUpHost() {
        if (mUserInfo.getRole().equals(UserRole.HOST)) {
            context.userService.hostsAbandon(context.config.appId, context.rteService.getRoomId(), mUserInfo.getUserId())
                    .enqueue(new BaseCallback<>(error -> invokeCallback(callBack -> callBack.onError(error))));
        }
    }

    /**
     * 申请成为主持人
     */
    public void applyToBeHost() {
        if (!mUserInfo.getRole().equals(UserRole.HOST)) {
            context.userService.hostsApply(context.config.appId, context.rteService.getRoomId(),
                    mUserInfo.getUserId())
                    .enqueue(new BaseCallback<>(error -> invokeCallback(callBack -> callBack.onError(error))));
        }
    }

    /**
     * 将指定用户设置为主持人
     */
    public void setAsHost(String userId) {
        if (mUserInfo.getRole().equals(UserRole.HOST)) {
            context.userService.hostsAppoint(context.config.appId, context.rteService.getRoomId(),
                    mUserInfo.getUserId(), new TargetUserIdReq(userId))
                    .enqueue(new BaseCallback<>(error -> invokeCallback(callBack -> callBack.onError(error))));
        }
    }

    /**
     * 将指定用户踢出房间
     */
    public void kickOut() {
        cleanStreams();
        context.userService.kickOut(context.config.appId, context.rteService.getRoomId(),
                context.rteService.getLocalUserId(), new KickOutReq(getUserId()))
                .enqueue(new BaseCallback<>(error -> invokeCallback(callBack -> callBack.onError(error))));
    }

    /**
     * @return 用户所持有的流列表，包含 摄像头/白板/屏幕共享 流
     */
    public List<StreamModel> getStreamModels() {
        return streamModels;
    }

    /**
     * @return 用户的主流，一般是对应用户的 摄像头的音视频流
     */
    public StreamModel getMainStreamModel() {
        StreamModel streamModel = getStreamModel(mUserInfo.getStreamId());
        if (streamModel == null && streamModels.size() > 0) {
            streamModel = streamModels.get(0);
        }
        return streamModel;
    }

    /**
     * @param streamId 流id
     * @return 流id对应的流数据
     */
    public StreamModel getStreamModel(String streamId) {
        if (TextUtils.isEmpty(streamId)) {
            return null;
        }
        for (StreamModel streamModel : streamModels) {
            if (streamModel.getStreamId().equals(streamId)) {
                return streamModel;
            }
        }
        return null;
    }

    /**
     * 全员禁音/关视频
     */
    public void muteAll(@Device int device) {
        if (!isLocal() || !isHost()) {
            throw new RuntimeException(getUserId() + " do not have the permission.");
        }
        MuteAllReq body = new MuteAllReq();
        body.cameraClose = device == Device.CAMERA;
        body.micClose = device == Device.MIC;
        context.userService.muteAll(context.config.appId, context.rteService.getRoomId(), getUserId(), body)
                .enqueue(new BaseCallback<>(error -> invokeCallback(observer -> observer.onError(error))));
    }

    @Override
    public void release() {
        context.rteService.unregisterUserChangeObserver(getUserId(), innerUserObserver);
        super.release();
        cleanStreams();
    }

    private void cleanStreams() {
        for (StreamModel streamModel : streamModels) {
            streamModel.release();
        }
        streamModels.clear();
    }

    private class InnerUserObserver implements MeetingRteService.UserChangeObserver {
        @Override
        public void onStreamAdd(AgoraRteStreamInfo streamInfo, int streamType) {
            StreamModel streamModel = getStreamModel(streamInfo.getStreamId());
            if (streamModel == null || streamModel.getStreamType() != streamType) {
                StreamModel sm = new StreamModel(context, UserModel.this, streamInfo, streamType);
                resetLocalDevices(streamType, sm);
                streamModels.add(sm);
                invokeCallback(callBack -> callBack.onStreamAdd(sm));
            }
        }

        @Override
        public void onStreamRemove(String streamId) {
            Iterator<StreamModel> iterator = streamModels.iterator();
            while (iterator.hasNext()) {
                StreamModel next = iterator.next();
                if (next.getStreamId().equals(streamId)) {
                    next.release();
                    iterator.remove();
                    invokeCallback(callBack -> callBack.onStreamRemove(next));
                }
            }
        }

        @Override
        public void onUserInfoUpdated(AgoraRteUserInfo user) {
            boolean roleChanged = Boolean.compare(UserRole.HOST.equals(user.getRole()), UserRole.HOST.equals(mUserInfo.getRole())) != 0;
            boolean userNameChanged = !user.getUserName().equals(mUserInfo.getUserName());
            if (!roleChanged && !userNameChanged) {
                return;
            }

            if (userNameChanged) {
                mUserInfo.setUserName(user.getUserName());
            }
            if (roleChanged) {
                mUserInfo.setRole(user.getRole());
                context.msgHandler.handleUserRoleChange(mUserInfo);
            }
            invokeCallback(callBack -> callBack.onUserInfoUpdate(UserModel.this));
        }
    }

    private void resetLocalDevices(int streamType, StreamModel sm) {
        if (isLocal() && streamType == StreamType.MEDIA) {
            Logger.d("UserModel resetLocalDevices mic local=" + context.openLocalMic + ",remote=" + sm.hasAudio());
            Logger.d("UserModel resetLocalDevices camera local=" + context.openLocalCamera + ",remote=" + sm.hasVideo());
            if (context.rteService.getRoomProperties().userPermission.micAccess) {
                sm.setAudioEnable(context.openLocalMic);
            }
            if (context.rteService.getRoomProperties().userPermission.cameraAccess) {
                sm.setVideoEnable(context.openLocalCamera);
            }
        }
    }


    @Keep
    public interface CallBack {

        void onError(Throwable error);

        void onStreamAdd(StreamModel streamModel);

        void onStreamRemove(StreamModel streamModel);

        void onUserInfoUpdate(UserModel userModel);

    }

}
