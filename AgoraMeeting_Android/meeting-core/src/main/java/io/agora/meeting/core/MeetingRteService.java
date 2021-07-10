package io.agora.meeting.core;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.view.SurfaceView;
import android.view.TextureView;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.Gson;

import org.jetbrains.annotations.NotNull;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.agora.meeting.core.annotaion.CauseCmdType;
import io.agora.meeting.core.annotaion.CmdType;
import io.agora.meeting.core.annotaion.DataState;
import io.agora.meeting.core.annotaion.ModuleState;
import io.agora.meeting.core.annotaion.StreamType;
import io.agora.meeting.core.annotaion.UserRole;
import io.agora.meeting.core.base.CallbackInvoker;
import io.agora.meeting.core.bean.PeerMessage;
import io.agora.meeting.core.bean.RoomProperties;
import io.agora.meeting.core.bean.UserProperties;
import io.agora.meeting.core.http.network.HttpException;
import io.agora.meeting.core.log.Logger;
import io.agora.rtc.ss.utils.SimpleSafeData;
import io.agora.rte.AgoraRteAudioSourceType;
import io.agora.rte.AgoraRteCallback;
import io.agora.rte.AgoraRteCameraVideoTrack;
import io.agora.rte.AgoraRteChatMsg;
import io.agora.rte.AgoraRteEngine;
import io.agora.rte.AgoraRteEngineConfig;
import io.agora.rte.AgoraRteEngineCreator;
import io.agora.rte.AgoraRteEngineEventListener;
import io.agora.rte.AgoraRteError;
import io.agora.rte.AgoraRteLocalAudioStats;
import io.agora.rte.AgoraRteLocalUser;
import io.agora.rte.AgoraRteLocalUserChannelEventListener;
import io.agora.rte.AgoraRteLocalVideoStats;
import io.agora.rte.AgoraRteMediaStreamType;
import io.agora.rte.AgoraRteMessage;
import io.agora.rte.AgoraRteMicAudioTrack;
import io.agora.rte.AgoraRteRemoteAudioStats;
import io.agora.rte.AgoraRteRemoteVideoStats;
import io.agora.rte.AgoraRteRenderConfig;
import io.agora.rte.AgoraRteRtcStats;
import io.agora.rte.AgoraRteScene;
import io.agora.rte.AgoraRteSceneConfig;
import io.agora.rte.AgoraRteSceneConnectionChangeReason;
import io.agora.rte.AgoraRteSceneConnectionState;
import io.agora.rte.AgoraRteSceneEventListener;
import io.agora.rte.AgoraRteSceneInfo;
import io.agora.rte.AgoraRteSceneJoinOptions;
import io.agora.rte.AgoraRteStreamEvent;
import io.agora.rte.AgoraRteStreamInfo;
import io.agora.rte.AgoraRteSubscribeOptions;
import io.agora.rte.AgoraRteUserEvent;
import io.agora.rte.AgoraRteUserInfo;
import io.agora.rte.AgoraRteVideoSourceType;
import io.agora.rte.AgoraRteVideoStreamType;
import io.agora.rte.NetworkQuality;

/**
 * Description:
 *
 * @since 2/23/21
 */
public final class MeetingRteService {
    private final Map<String, ArrayList<RoomChangeObserver>> mRoomObservers = new HashMap<>();
    private final Map<String, ArrayList<UserChangeObserver>> mUserObservers = new HashMap<>();
    private final Map<String, ArrayList<StreamChangeObserver>> mStreamObservers = new HashMap<>();

    private final Handler mMainHandler = new Handler(Looper.getMainLooper());

    private AgoraRteEngine mRteEngine;
    private AgoraRteScene mRteScene;
    private RoomProperties mRoomProperties;

    private final Context context;
    private final MeetingConfig config;
    private final ConnectionHandler connectionChangeHandler = new ConnectionHandler();

    private final Map<String, Integer> streamVolumeMap = new HashMap<>();
    private final SimpleSafeData<Boolean> screenStatusChange = new SimpleSafeData<>();

    // 本地流添加回调，只会回调一次
    private volatile boolean isLocalStreamAdded = false;

    public MeetingRteService(Context context, MeetingConfig config) {
        this.context = context;
        this.config = config;
    }

    /**
     * 加入房间
     */
    public void joinRoom(String roomId,
                         String userId,
                         String userName,
                         String streamId,
                         @UserRole String userRole) {
        new AgoraRteEngineCreator(context,
                new AgoraRteEngineConfig(
                        config.appId,
                        config.customId,
                        config.customCer,
                        userId,
                        false
                ),
                new AgoraRteCallback<AgoraRteEngine>() {
                    @Override
                    public void success(@Nullable AgoraRteEngine engine) {
                        mRteEngine = engine;
                        joinScene(roomId, userName, streamId, userRole);
                    }

                    @Override
                    public void fail(@NotNull AgoraRteError error) {
                        callObservers(roomId, mRoomObservers, callback -> callback.onJoinFailure(error));
                    }
                }).create();
    }

    /**
     * 退出房间并销毁房间资源
     */
    public void leaveRoom() {
        if (mRteScene != null) {
            mRteScene.leave();
            mRteScene.destroy();
            mRteScene = null;
        }
        if (mRteEngine != null) {
            mRteEngine.destroy();
            mRteEngine = null;
        }
        mRoomProperties = null;
        mMainHandler.removeCallbacksAndMessages(null);
        streamVolumeMap.clear();
        connectionChangeHandler.release();
        isLocalStreamAdded = false;
    }

    /**
     * @return 本地设备登录的用户id
     */
    public String getLocalUserId() {
        if (mRteScene == null) {
            return "";
        }
        AgoraRteLocalUser localUser = mRteScene.getLocalUser();
        if (localUser == null) {
            return "";
        }
        return localUser.getUserId();
    }

    public String getLocalUserName() {
        if (mRteScene == null) {
            return "";
        }
        AgoraRteLocalUser localUser = mRteScene.getLocalUser();
        if (localUser == null) {
            return "";
        }
        return localUser.getUserName();
    }

    /**
     * @return 本地设备登录的用户是否是主持人
     */
    public boolean isLocalHost() {
        if (mRteScene == null) {
            return false;
        }
        AgoraRteLocalUser localUser = mRteScene.getLocalUser();
        if (localUser == null) {
            return false;
        }
        return localUser.getRole().equals(UserRole.HOST);
    }


    /**
     * @return 房间id
     */
    public String getRoomId() {
        if (mRteScene == null) {
            return "";
        }
        AgoraRteSceneInfo sceneInfo = mRteScene.getSceneInfo();
        return sceneInfo.getSceneId();
    }

    /**
     * 获取房间信息
     *
     * @return
     */
    public RoomProperties getRoomProperties() {
        return mRoomProperties;
    }

    /**
     * 发送消息到房间里
     */
    public void sendMessageToRoom(AgoraRteMessage agoraRteMessage) {
        if (mRteScene == null) {
            return;
        }
        AgoraRteLocalUser localUser = mRteScene.getLocalUser();
        if (localUser == null) {
            return;
        }
        localUser.sendSceneMessage(agoraRteMessage, new AgoraRteCallback<Void>() {
            @Override
            public void success(@Nullable Void param) {

            }

            @Override
            public void fail(@NotNull AgoraRteError error) {

            }
        });
    }

    /**
     * @return 本地设备登录的用户是否可以操作白板
     */
    public boolean canBoardInteractByMe() {
        if (mRoomProperties == null) {
            return false;
        }
        return mRoomProperties.canBoardInteract(getLocalUserId());
    }

    public boolean canBoardInteractBy(String userId) {
        if (mRoomProperties == null) {
            return false;
        }
        return mRoomProperties.canBoardInteract(userId);
    }

    public AgoraRteCameraVideoTrack getLocalVideoMediaTrack() {
        return mRteEngine.getAgoraRteMediaControl().getVideoMediaTrack();
    }

    public AgoraRteMicAudioTrack getLocalAudioMediaTrack() {
        return mRteEngine.getAgoraRteMediaControl().getAudioMediaTrack();
    }

    public void enableDualStreamMode(boolean enable) {
        if (mRteScene == null) {
            return;
        }
        AgoraRteLocalUser localUser = mRteScene.getLocalUser();
        if (localUser == null) {
            return;
        }
        AgoraRteError ret = localUser.enableDualStreamMode(enable);
        Logger.d("enableDualStreamMode ret=" + (ret == null ? 0 : ret.getCode()));
    }

    public void enableRemoteVideoHighStream(String streamId, boolean enable) {
        if (mRteScene == null) {
            return;
        }
        AgoraRteLocalUser localUser = mRteScene.getLocalUser();
        if (localUser == null) {
            return;
        }

        AgoraRteError ret = localUser.subscribeRemoteVideoStreamOptions(streamId,
                new AgoraRteSubscribeOptions(enable ? AgoraRteVideoStreamType.high : AgoraRteVideoStreamType.low));
        Logger.d("enableRemoteVideoHighStream streamId= " + streamId + ",highStream=" + enable + ",ret=" + (ret == null ? 0 : ret.getCode()));
    }

    public void subscribeRemoteStream(String streamId, AgoraRteMediaStreamType type) {
        if (mRteScene == null) {
            return;
        }
        AgoraRteLocalUser localUser = mRteScene.getLocalUser();
        if (localUser == null) {
            return;
        }
        localUser.subscribeRemoteStream(streamId, type);
    }

    public void unsubscribeRemoteStream(String streamId, AgoraRteMediaStreamType type) {
        if (mRteScene == null) {
            return;
        }
        AgoraRteLocalUser localUser = mRteScene.getLocalUser();
        if (localUser == null) {
            return;
        }
        localUser.unsubscribeRemoteStream(streamId, type);
    }

    public void destroy() {
        leaveRoom();
        unregisterAll();
    }

    private void joinScene(String roomId,
                           String localUserId,
                           String localStreamId,
                           @UserRole String localUserRole) {
        if (mRteEngine == null) {
            return;
        }
        mRteEngine.getAgoraRteMediaControl().getAudioMediaTrack().setAudioEncoderConfig(config.audioEncoderConfig);
        mRteScene = mRteEngine.createAgoraRteScene(new AgoraRteSceneConfig(roomId));

        mRteScene.join(new AgoraRteSceneJoinOptions(
                        localUserId,
                        localUserRole,
                        localStreamId
                ),
                new AgoraRteCallback<AgoraRteLocalUser>() {
                    @Override
                    public void success(@Nullable AgoraRteLocalUser param) {
                        runInMainThread(() -> {
                            listenUserChange();
                            callObservers(getRoomId(), mRoomObservers, observer -> observer.onJoinSuccess(mRteScene.getAllUsers()));

                            parseRoomProperties(null, null);
                            boolean success = parseSceneUsers();
                            if (success) {
                                callObservers(getRoomId(), mRoomObservers, RoomChangeObserver::onJoinComplete);
                            } else {
                                callObservers(getRoomId(), mRoomObservers, observer -> observer.onJoinFailure(new HttpException(-100, "no user or stream found.")));
                            }
                        });

                    }

                    @Override
                    public void fail(@NonNull AgoraRteError error) {
                        callObservers(roomId, mRoomObservers, callback -> callback.onJoinFailure(error));
                    }
                });
    }

    private void parseRoomProperties(@Nullable String cause, @Nullable AgoraRteUserInfo operator) {
        if (mRteScene == null) {
            return;
        }
        Logger.d("parseRoomProperties cause=" + cause);

        RoomProperties newValue = RoomProperties.parse(mRteScene.getSceneProperties());
        RoomProperties oldValue = mRoomProperties;
        mRoomProperties = newValue;
        handleCause(cause, operator, operator);
        if (ifMeetingEnd(newValue)) return;

        AgoraRteUserInfo boardOperator = findBoardOperator(oldValue, newValue);

        runInMainThread(() -> {
            callObservers(getRoomId(), mRoomObservers, callback -> callback.onRoomPropertiesChanged(oldValue, newValue));
            renewBoardStream(oldValue, newValue, boardOperator);
            renewScreenStream(oldValue, newValue);
        });
    }

    private boolean ifMeetingEnd(RoomProperties newValue) {
        if (newValue.isMeetingEnded()) {
            // 房间被关闭
            runInMainThread(() -> callObservers(getRoomId(), mRoomObservers, RoomChangeObserver::onRoomClosed));
            return true;
        }
        return false;
    }

    private void renewScreenStream(RoomProperties oldValue, RoomProperties newValue) {
        if (oldValue == null || Boolean.compare(oldValue.isScreenSharing(), newValue.isScreenSharing()) != 0) {
            if (screenStatusChange.getRunnableSize() == 0) {
                if (newValue.isScreenSharing()) {
                    changeScreenStream(newValue.share.screen.ownerInfo.getUserId(), newValue.share.screen.streamInfo.getStreamId(),
                            new AgoraRteStreamInfo(newValue.share.screen.ownerInfo, newValue.share.screen.streamInfo.getStreamId(), "ScreenScreen", AgoraRteVideoSourceType.none, AgoraRteAudioSourceType.none, true, false, System.currentTimeMillis()),
                            true);
                } else if (oldValue != null) {
                    changeScreenStream(oldValue.share.screen.ownerInfo.getUserId(), oldValue.share.screen.streamInfo.getStreamId(), null, false);
                }
            }
            screenStatusChange.setData(newValue.isScreenSharing());
        }
    }

    private void runInMainThread(Runnable runnable) {
        if (Thread.currentThread() == mMainHandler.getLooper().getThread()) {
            runnable.run();
        } else {
            mMainHandler.post(runnable);
        }
    }

    private void renewBoardStream(RoomProperties oldValue, @NotNull RoomProperties newValue, AgoraRteUserInfo operator) {
        if (newValue.isBoardSharing()) {
            boolean hasBoardShared = oldValue != null && oldValue.isBoardSharing();
            RoomProperties.WhiteBoard board = newValue.board;
            AgoraRteStreamInfo streamInfo = createBoardStream(board);

            if (hasBoardShared) {
                callObservers(streamInfo.getStreamId(), mStreamObservers, observer -> observer.onStreamUpdate(streamInfo, operator));
            } else {
                if (board.ownerInfo != null) {
                    dealStreamAdd(board.ownerInfo.getUserId(), streamInfo, StreamType.BOARD);
                }
            }
        } else if (oldValue != null && oldValue.isBoardSharing()) {
            RoomProperties.WhiteBoard board = oldValue.board;
            if (board.ownerInfo != null && board.info != null) {
                dealStreamRemove(board.ownerInfo.getUserId(), board.info.boardId, StreamType.BOARD);
            }
        }
    }

    @Nullable
    private AgoraRteUserInfo findBoardOperator(RoomProperties oldValue, @NotNull RoomProperties newValue) {
        if (oldValue == null || !newValue.isBoardSharing() || !oldValue.isBoardSharing()) {
            return null;
        }
        List<String> newGrantUsers = newValue.board.state.grantUsers;
        List<String> oldGrantUsers = oldValue.board.state.grantUsers;

        String changeUserId = "";
        AgoraRteUserInfo operator = null;
        if (newGrantUsers.size() > oldGrantUsers.size()) {
            for (String newGrantUser : newGrantUsers) {
                if (!oldGrantUsers.contains(newGrantUser)) {
                    changeUserId = newGrantUser;
                    break;
                }
            }
        } else if (newGrantUsers.size() < oldGrantUsers.size()) {
            for (String oldGrantUser : oldGrantUsers) {
                if (!newGrantUsers.contains(oldGrantUser)) {
                    changeUserId = oldGrantUser;
                    break;
                }
            }
        }
        if (!TextUtils.isEmpty(changeUserId)) {
            for (AgoraRteUserInfo user : mRteScene.getAllUsers()) {
                if (user.getUserId().equals(changeUserId)) {
                    operator = user;
                    break;
                }
            }
        }
        return operator;
    }

    @NotNull
    private AgoraRteStreamInfo createBoardStream(RoomProperties.WhiteBoard board) {
        return new AgoraRteStreamInfo(
                board.ownerInfo,
                board.info.boardId,
                board.info.boardToken,
                AgoraRteVideoSourceType.none,
                AgoraRteAudioSourceType.none,
                true,
                false,
                System.currentTimeMillis()
        );
    }

    private AgoraRteStreamInfo createPlaceHolderStream(AgoraRteUserInfo userInfo) {
        String streamId = userInfo.getStreamId();
        if (TextUtils.isEmpty(streamId)) {
            streamId = getUserStreamId(userInfo.getUserId());
        }
        return new AgoraRteStreamInfo(
                userInfo,
                streamId,
                "",
                AgoraRteVideoSourceType.camera,
                AgoraRteAudioSourceType.mic,
                false,
                false,
                System.currentTimeMillis()
        );
    }


    private boolean parseSceneUsers() {
        if (mRteScene == null) {
            return false;
        }
        boolean success = false;
        List<AgoraRteUserInfo> userInfos = mRteScene.getAllUsers();
        for (AgoraRteUserInfo userInfo : userInfos) {
            List<AgoraRteStreamInfo> userStreams = mRteScene.getUserStreams(userInfo.getUserId());

            boolean containerMainStream = false;
            for (AgoraRteStreamInfo userStream : userStreams) {
                success = true;
                dealStreamAdd(userInfo.getUserId(), userStream, judgeStreamType(userStream));
                if (userStream.getStreamId().equals(userInfo.getStreamId())) {
                    containerMainStream = true;
                }
            }

            if (!containerMainStream) {
                success = true;
                dealStreamAdd(userInfo.getUserId(), createPlaceHolderStream(userInfo), StreamType.MEDIA);
            }
        }
        return success;
    }


    private void dealStreamRemove(String userId, String streamId, @StreamType int streamType) {
        if (streamType == StreamType.SCREEN) {
            changeScreenStream(userId, streamId, null, false);
        } else if (streamType == StreamType.BOARD) {
            runInMainThread(() -> callObservers(userId, mUserObservers, observer -> observer.onStreamRemove(streamId)));
        }
    }

    private void dealStreamAdd(String userId, AgoraRteStreamInfo streamInfo, @StreamType int streamType) {
        if (streamType == StreamType.SCREEN) {
            changeScreenStream(userId, streamInfo.getStreamId(), streamInfo, true);
        } else if (userId.equals(getLocalUserId()) && streamType == StreamType.MEDIA) {
            if (isLocalStreamAdded) {
                runInMainThread(() -> callObservers(streamInfo.getStreamId(), mStreamObservers, observer -> observer.onStreamUpdate(streamInfo, null)));
            } else {
                isLocalStreamAdded = true;
                runInMainThread(() -> callObservers(userId, mUserObservers, observer -> observer.onStreamAdd(streamInfo, streamType)));
            }
        } else {
            runInMainThread(() -> callObservers(userId, mUserObservers, observer -> observer.onStreamAdd(streamInfo, streamType)));
        }
    }

    private void changeScreenStream(String userId, String streamId, AgoraRteStreamInfo streamInfo, boolean open) {
        screenStatusChange.execWhen(
                status -> {
                    if (open) {
                        runInMainThread(() -> callObservers(userId, mUserObservers, observer -> observer.onStreamAdd(streamInfo, StreamType.SCREEN)));
                    } else {
                        runInMainThread(() -> callObservers(userId, mUserObservers, observer -> observer.onStreamRemove(streamId)));
                    }
                },
                open);
    }

    @StreamType
    private int judgeStreamType(AgoraRteStreamInfo userStream) {
        return userStream.getVideoSourceType() == AgoraRteVideoSourceType.screen ? StreamType.SCREEN : StreamType.MEDIA;
    }

    private void handleCause(String cause, @Nullable AgoraRteUserInfo operator, @Nullable AgoraRteUserInfo target) {
        if (TextUtils.isEmpty(cause) || operator == null || target == null) {
            Logger.w("skip cause --- cause=" + cause + ",operator=" + operator + ",target=" + target);
            return;
        }
        int type = CauseCmdType.NONE;
        String reason = "";
        try {
            JSONObject causeObject = new JSONObject(cause);
            type = causeObject.getInt("cmd");
            reason = causeObject.getString("data");
        } catch (JSONException e) {
            Logger.d(e.toString());
        }
        String _reason = reason;
        int _type = type;
        runInMainThread(() -> callObservers(getRoomId(), mRoomObservers, observer -> observer.onActionCauseReceived(operator, target, _type, _reason)));
        ;
    }

    private void listenUserChange() {
        final Gson gson = new Gson();
        connectionChangeHandler.setReConnectListener(new ConnectionHandler.ReConnectListener() {
            @Override
            public void onUserChanged(AgoraRteUserInfo userInfo, @DataState int state) {
                runInMainThread(() -> {
                    switch (state) {
                        case DataState.ADD:
                            dealUserJoin(userInfo);
                            break;
                        case DataState.REMOVE:
                            callObservers(getRoomId(), mRoomObservers, observer -> observer.onUserLeft(userInfo));
                            break;
                        case DataState.UPDATE:
                            callObservers(userInfo.getUserId(), mUserObservers, observer -> observer.onUserInfoUpdated(userInfo));
                            break;
                    }
                });
            }

            @Override
            public void onStreamChanged(AgoraRteStreamInfo streamInfo, @DataState int state) {
                runInMainThread(() -> {
                    switch (state) {
                        case DataState.ADD:
                            dealStreamAdd(streamInfo.getOwner().getUserId(), streamInfo, judgeStreamType(streamInfo));
                            break;
                        case DataState.REMOVE:
                            dealStreamRemove(streamInfo.getOwner().getUserId(), streamInfo.getStreamId(), judgeStreamType(streamInfo));
                            break;
                        case DataState.UPDATE:
                            callObservers(streamInfo.getStreamId(), mStreamObservers, observer -> observer.onStreamUpdate(streamInfo, null));
                            break;
                    }
                });
            }

            @Override
            public void onRoomPropertiesChanged(Map<String, Object> sceneProperties) {
                runInMainThread(() -> {
                    parseRoomProperties(null, null);
                });
            }

            @Override
            public void onComplete() {
                runInMainThread(() -> {
                    callObservers(getRoomId(), mRoomObservers, RoomChangeObserver::onReJoinSuccess);
                });
            }

            @Override
            public void onError() {
                runInMainThread(() -> {
                    callObservers(getRoomId(), mRoomObservers, RoomChangeObserver::onReJoinFailure);
                });
            }
        });
        AgoraRteEngineEventListener engineEventListener = message -> {
            Logger.d("Engine Event Message : " + message.getMessage());
            parseCustomMessage(gson, message.getMessage(), message.getFromUser());
        };
        mRteEngine.setEngineEventListener(engineEventListener);
        AgoraRteSceneEventListener sceneEventListener = new AgoraRteSceneEventListener() {
            @Override
            public void onRemoteUsersInitialized(@NotNull List<? extends AgoraRteUserInfo> users,
                                                 @NotNull AgoraRteScene scene) {

            }

            @Override
            public void onRemoteUsersJoined(@NotNull List<? extends AgoraRteUserInfo> users,
                                            @NotNull AgoraRteScene scene) {
                runInMainThread(() -> {
                    for (AgoraRteUserInfo user : users) {
                        dealUserJoin(user);
                    }
                });
            }

            @Override
            public void onRemoteUserLeft(@NotNull List<AgoraRteUserEvent> userEvents,
                                         @NotNull AgoraRteScene scene) {
                runInMainThread(() -> {
                    for (AgoraRteUserEvent ue : userEvents) {
                        AgoraRteUserInfo userInfo = ue.getUserInfo();
                        callObservers(getRoomId(), mRoomObservers, observer -> observer.onUserLeft(userInfo));
                    }
                });
            }

            @Override
            public void onRemoteUserInfoUpdated(@NotNull AgoraRteUserEvent userEvent,
                                                @NotNull AgoraRteScene scene) {
                AgoraRteUserInfo userInfo = userEvent.getUserInfo();
                // 用户角色、用户名、用户头像变化
                callObservers(userInfo.getUserId(), mUserObservers, observer -> observer.onUserInfoUpdated(userInfo));
            }

            @Override
            public void onRemoteUserPropertyUpdated(@NotNull AgoraRteUserInfo userInfo,
                                                    @NotNull AgoraRteScene scene,
                                                    @Nullable String cause) {

            }

            @Override
            public void onSceneMessageReceived(@NotNull AgoraRteMessage message,
                                               @NotNull AgoraRteScene scene) {

            }

            @Override
            public void onSceneChatMessageReceived(@NotNull AgoraRteChatMsg chatMsg,
                                                   @NotNull AgoraRteScene scene) {
                callObservers(getRoomId(), mRoomObservers, observer -> observer.onSceneMsgReceived(chatMsg));
            }

            @Override
            public void onChannelCustomMessageReceived(@NotNull String message,
                                                       @NotNull AgoraRteUserInfo fromUser) {
                parseCustomMessage(gson, message, fromUser);
            }

            @Override
            public void onRemoteStreamsInitialized(@NotNull List<AgoraRteStreamInfo> streams,
                                                   @NotNull AgoraRteScene scene) {

            }

            @Override
            public void onRemoteStreamsAdded(@NotNull List<AgoraRteStreamEvent> streamEvents,
                                             @NotNull AgoraRteScene scene) {
                for (AgoraRteStreamEvent streamEvent : streamEvents) {
                    AgoraRteStreamInfo streamInfo = streamEvent.getStreamInfo();
                    String userId = streamInfo.getOwner().getUserId();
                    dealStreamAdd(userId, streamInfo, judgeStreamType(streamInfo));
                }
            }

            @Override
            public void onRemoteStreamUpdated(@NotNull List<AgoraRteStreamEvent> streamEvents,
                                              @NotNull AgoraRteScene scene) {
                for (AgoraRteStreamEvent streamEvent : streamEvents) {
                    AgoraRteStreamInfo streamInfo = streamEvent.getStreamInfo();
                    AgoraRteUserInfo operator = streamEvent.getOperator();
                    if (!streamInfo.getHasAudio()) {
                        synchronized (streamVolumeMap) {
                            streamVolumeMap.remove(streamInfo.getStreamId());
                        }
                    }
                    Logger.d("onRemoteStreamUpdated streamId=" + streamInfo.getStreamId() + ",cause=" + streamEvent.getCause());
                    handleCause(streamEvent.getCause(), operator, streamInfo.getOwner());
                    callObservers(streamInfo.getStreamId(), mStreamObservers, observer -> observer.onStreamUpdate(streamInfo, operator));
                }
            }

            @Override
            public void onRemoteStreamsRemoved(@NotNull List<AgoraRteStreamEvent> streamEvents,
                                               @NotNull AgoraRteScene scene) {
                for (AgoraRteStreamEvent streamEvent : streamEvents) {
                    AgoraRteStreamInfo streamInfo = streamEvent.getStreamInfo();
                    AgoraRteUserInfo operator = streamEvent.getOperator();
                    String userId = streamInfo.getOwner().getUserId();

                    // 清除音量
                    synchronized (streamVolumeMap) {
                        streamVolumeMap.remove(streamInfo.getStreamId());
                    }
                    String streamId = getUserStreamId(userId);
                    if (streamInfo.getStreamId().equals(streamId)) {
                        callObservers(streamInfo.getStreamId(), mStreamObservers, observer -> observer.onStreamUpdate(createPlaceHolderStream(streamInfo.getOwner()), operator));
                    } else {
                        dealStreamRemove(userId, streamInfo.getStreamId(), judgeStreamType(streamInfo));
                    }
                }
            }

            @Override
            public void onScenePropertyUpdated(@NotNull AgoraRteScene scene,
                                               @NotNull List<String> changedProperties,
                                               boolean remove, @Nullable String cause, @Nullable AgoraRteUserInfo operator) {
                parseRoomProperties(cause, operator);
            }

            @Override
            public void onNetworkQualityChanged(@NotNull NetworkQuality quality,
                                                @NotNull AgoraRteUserInfo user,
                                                @NotNull AgoraRteScene scene) {

            }

            @Override
            public void onConnectionStateChanged(@NotNull AgoraRteSceneConnectionState state,
                                                 @Nullable AgoraRteSceneConnectionChangeReason reason,
                                                 @NotNull AgoraRteScene scene) {
                connectionChangeHandler.handleConnectionState(state, scene);
            }

            @Override
            public void onRemoteVideoStats(@NotNull AgoraRteRemoteVideoStats stats) {

            }

            @Override
            public void onRemoteAudioStats(@NotNull AgoraRteRemoteAudioStats stats) {

            }

            @Override
            public void onRtcStats(@NotNull AgoraRteRtcStats stats) {

            }
        };
        mRteScene.setSceneEventListener(sceneEventListener);
        mRteScene.getLocalUser().setLocalUserListener(new AgoraRteLocalUserChannelEventListener() {
            @Override
            public void onLocalUserInfoUpdated(@NotNull AgoraRteUserEvent userEvent) {
                AgoraRteUserInfo userInfo = userEvent.getUserInfo();
                callObservers(userInfo.getUserId(), mUserObservers, observer -> observer.onUserInfoUpdated(userInfo));
            }

            @Override
            public void onLocalUserPropertyUpdated(@NotNull AgoraRteUserInfo userInfo, @Nullable String cause, @Nullable AgoraRteUserInfo operator) {
                Logger.d("onLocalUserPropertyUpdated cause=" + cause);
                UserProperties userProperties = UserProperties.parse(mRteScene.getLocalUser().getUserProperties());
                runInMainThread(() -> {
                    handleCause(cause, operator, userInfo);
                    if (userProperties.dirty != null) {
                        if (userProperties.dirty.state == ModuleState.ENABLE) {
                            // 被主持人移除的用户
                            callObservers(getRoomId(), mRoomObservers, observer -> observer.onUserLeft(userInfo));
                        }
                    } else {
                        callObservers(userInfo.getUserId(), mUserObservers, observer -> observer.onUserInfoUpdated(userInfo));
                    }
                });
            }

            @Override
            public void onLocalStreamAdded(@NotNull AgoraRteStreamEvent streamEvent) {
                AgoraRteStreamInfo streamInfo = streamEvent.getStreamInfo();
                String userId = streamInfo.getOwner().getUserId();
                Logger.d("StreamChange >> onLocalStreamAdded: streamId= " + streamInfo.getStreamId() + ",video=" + streamInfo.getHasVideo() + ",audio=" + streamInfo.getHasAudio());
                dealStreamAdd(userId, streamInfo, judgeStreamType(streamInfo));
            }

            @Override
            public void onLocalStreamUpdated(@NotNull AgoraRteStreamEvent streamEvent) {
                Logger.d("onLocalStreamUpdated cause=" + streamEvent.getCause());
                AgoraRteStreamInfo streamInfo = streamEvent.getStreamInfo();
                AgoraRteUserInfo operator = streamEvent.getOperator();
                handleCause(streamEvent.getCause(), operator, streamInfo.getOwner());
                Logger.d("StreamChange >> onLocalStreamUpdated: streamId= " + streamInfo.getStreamId() + ",video=" + streamInfo.getHasVideo() + ",audio=" + streamInfo.getHasAudio());
                callObservers(streamInfo.getStreamId(), mStreamObservers, observer -> observer.onStreamUpdate(streamInfo, operator));
            }

            @Override
            public void onLocalStreamRemoved(@NotNull AgoraRteStreamEvent streamEvent) {
                if (mRteScene == null) {
                    return;
                }
                AgoraRteLocalUser localUser = mRteScene.getLocalUser();
                if (localUser == null) {
                    return;
                }
                AgoraRteStreamInfo streamInfo = streamEvent.getStreamInfo();
                AgoraRteUserInfo operator = streamEvent.getOperator();
                String userId = streamInfo.getOwner().getUserId();
                Logger.d("StreamChange >> onLocalStreamRemoved: streamId= " + streamInfo.getStreamId() + ",video=" + streamInfo.getHasVideo() + ",audio=" + streamInfo.getHasAudio());
                handleCause(streamEvent.getCause(), operator, streamInfo.getOwner());
                if (streamInfo.getStreamId().equals(localUser.getStreamId())) {
                    callObservers(streamInfo.getStreamId(), mStreamObservers, observer -> observer.onStreamUpdate(createPlaceHolderStream(localUser), operator));
                } else {
                    dealStreamRemove(userId, streamInfo.getStreamId(), judgeStreamType(streamInfo));
                }
            }

            @Override
            public void onLocalAudioStats(@NotNull AgoraRteLocalAudioStats stats) {

            }

            @Override
            public void onLocalVideoStats(@NotNull AgoraRteLocalVideoStats stats) {

            }

            @Override
            public void audioVolumeIndicationOfStream(@NotNull String streamId, int volume) {
                synchronized (streamVolumeMap) {
                    int maxVolume = 0;
                    String maxVolumeStreamId = "";
                    streamVolumeMap.put(streamId, volume);
                    for (String key : streamVolumeMap.keySet()) {
                        int v = streamVolumeMap.get(key);
                        if (v > maxVolume) {
                            maxVolume = v;
                            maxVolumeStreamId = key;
                        }
                    }
                    boolean isMax = streamId.equals(maxVolumeStreamId);
                    callObservers(streamId, mStreamObservers, observer -> observer.onAudioVolumeIndication(volume, isMax));
                }

            }

        });
    }

    private void dealUserJoin(AgoraRteUserInfo user) {
        if (mRteScene == null) {
            return;
        }
        callObservers(getRoomId(), mRoomObservers, observer -> observer.onUserJoined(user));
        List<AgoraRteStreamInfo> userStreams = mRteScene.getUserStreams(user.getUserId());
        for (AgoraRteStreamInfo userStream : userStreams) {
            dealStreamAdd(user.getUserId(), userStream, judgeStreamType(userStream));
        }

        boolean containerUserMainStream = false;
        for (AgoraRteStreamInfo userStream : userStreams) {
            if (userStream.getStreamId().equals(user.getStreamId())) {
                containerUserMainStream = true;
            }
        }
        if (!containerUserMainStream) {
            dealStreamAdd(user.getUserId(), createPlaceHolderStream(user), StreamType.MEDIA);
        }
        if (mRoomProperties != null && mRoomProperties.isBoardSharing() && mRoomProperties.getBoardOwnerId().equals(user.getUserId())) {
            dealStreamAdd(user.getUserId(), createBoardStream(mRoomProperties.board), StreamType.BOARD);
        }
    }

    private String getUserStreamId(String userId) {
        if (mRteScene == null) {
            return "";
        }
        List<AgoraRteUserInfo> allUsers = mRteScene.getAllUsers();
        if (allUsers.size() == 0) {
            return "";
        }
        for (AgoraRteUserInfo user : allUsers) {
            if (user.getUserId().equals(userId)) {
                return user.getStreamId();
            }
        }
        return "";
    }

    private void parseCustomMessage(Gson gson, String message, AgoraRteUserInfo fromUser) {
        Logger.d("parsePeerCmd message=" + message);
        PeerMessage.Type peerCmd = gson.fromJson(message, PeerMessage.Type.class);
        PeerMessage<?> msg = null;
        if (CmdType.APPROVE == peerCmd.cmd) {
            msg = gson.fromJson(message, PeerMessage.Approve.class);
        } else if (CmdType.MUTE_ALL == peerCmd.cmd) {
            msg = gson.fromJson(message, PeerMessage.MuteAll.class);
        }
        if (msg != null) {
            PeerMessage<?> _msg = msg;
            callObservers(getRoomId(), mRoomObservers, observer -> observer.onPeerMessageReceived(_msg, fromUser));
        }
    }


    public void registerRoomChangerObserver(String roomId, RoomChangeObserver observer) {
        registerObserver(roomId, mRoomObservers, observer);
    }

    public void unregisterRoomChangeObserver(String roomId, RoomChangeObserver observer) {
        unregisterObserver(roomId, mRoomObservers, observer);
    }

    public void registerUserChangerObserver(String userId, UserChangeObserver observer) {
        registerObserver(userId, mUserObservers, observer);
    }

    public void unregisterUserChangeObserver(String userId, UserChangeObserver observer) {
        unregisterObserver(userId, mUserObservers, observer);
    }

    public void registerStreamChangerObserver(String streamId, StreamChangeObserver observer) {
        registerObserver(streamId, mStreamObservers, observer);
    }

    public void unregisterStreamChangeObserver(String streamId, StreamChangeObserver observer) {
        unregisterObserver(streamId, mStreamObservers, observer);
    }

    private void unregisterAll() {
        mRoomObservers.clear();
        mUserObservers.clear();
        mStreamObservers.clear();
    }

    private <T> void callObservers(String id, Map<String, ArrayList<T>> observers, CallbackInvoker<T> invoker) {
        if (TextUtils.isEmpty(id)) {
            return;
        }
        synchronized (observers) {
            ArrayList<T> ts = observers.get(id);
            if (ts != null) {
                synchronized (ts) {
                    for (int i = ts.size() - 1; i >= 0; i--) {
                        invoker.invoke(ts.get(i));
                    }
                }
            }
        }
    }

    private <T> void unregisterObserver(String id, Map<String, ArrayList<T>> observers, T observer) {
        if (TextUtils.isEmpty(id)) {
            return;
        }
        if (observer == null) {
            throw new IllegalArgumentException("The observer is null.");
        }
        synchronized (observers) {
            ArrayList<T> ts = observers.get(id);
            if (ts != null) {
                synchronized (ts) {
                    int index = ts.indexOf(observer);
                    if (index != -1) {
                        ts.remove(index);
                    }
                }
            }
        }
    }

    private <T> void registerObserver(String id, Map<String, ArrayList<T>> observers, T observer) {
        if (TextUtils.isEmpty(id)) {
            return;
        }
        if (observer == null) {
            throw new IllegalArgumentException("The observer is null.");
        }
        synchronized (observers) {
            ArrayList<T> ts = observers.get(id);
            if (ts == null) {
                ts = new ArrayList<>();
                observers.put(id, ts);
            }

            synchronized (ts) {
                if (ts.contains(observer)) {
                    throw new IllegalStateException("Observer " + observer + " is already registered.");
                }
                ts.add(observer);
            }
        }

    }

    public void muteLocalMediaStream(String ownerUserId, String streamId, AgoraRteMediaStreamType type, boolean enable) {
        if (mRteScene == null) {
            return;
        }
        AgoraRteLocalUser localUser = mRteScene.getLocalUser();
        if(localUser == null){
            return;
        }
        localUser.muteLocalMediaStream(ownerUserId, streamId, type, enable, false);
    }

    public SurfaceView createSurfaceView(Context context) {
        if (mRteScene == null) {
            return null;
        }
        AgoraRteLocalUser localUser = mRteScene.getLocalUser();
        if(localUser == null){
            return null;
        }
        return localUser.createSurfaceRenderView(context);
    }

    public TextureView createTextureView(Context context) {
        if (mRteScene == null) {
            return null;
        }
        AgoraRteLocalUser localUser = mRteScene.getLocalUser();
        if(localUser == null){
            return null;
        }
        return localUser.createTextureRenderView(context);
    }

    public void renderRemoteVideo(String streamId, View view, AgoraRteRenderConfig config) {
        if (mRteScene == null) {
            return;
        }
        AgoraRteLocalUser localUser = mRteScene.getLocalUser();
        if(localUser == null){
            return;
        }
        localUser.renderRemoteStream(streamId, view, config);
    }

    public void stopRenderRemoteStream(String streamId) {
        if (mRteScene == null) {
            return;
        }
        AgoraRteLocalUser localUser = mRteScene.getLocalUser();
        if(localUser == null){
            return;
        }
        localUser.stopRenderRemoteStream(streamId);
    }


    public interface RoomChangeObserver {

        void onJoinFailure(Throwable error);

        void onJoinSuccess(List<AgoraRteUserInfo> userInfos);

        void onReJoinSuccess();

        void onReJoinFailure();

        void onJoinComplete();

        void onRoomClosed();

        void onRoomPropertiesChanged(RoomProperties oldValue, RoomProperties newValue);

        void onUserJoined(AgoraRteUserInfo user);

        void onUserLeft(AgoraRteUserInfo userInfo);

        void onSceneMsgReceived(AgoraRteChatMsg chatMessage);

        void onPeerMessageReceived(PeerMessage<?> peerMsg, AgoraRteUserInfo fromUser);

        void onActionCauseReceived(@NonNull AgoraRteUserInfo operator, @NonNull AgoraRteUserInfo target, @CauseCmdType int type, String reason);

    }

    public interface UserChangeObserver {

        void onStreamAdd(AgoraRteStreamInfo userStream, @StreamType int streamType);

        void onStreamRemove(String streamId);

        void onUserInfoUpdated(AgoraRteUserInfo userInfo);

    }

    public interface StreamChangeObserver {

        void onStreamUpdate(AgoraRteStreamInfo streamInfo, @Nullable AgoraRteUserInfo operator);

        void onAudioVolumeIndication(int volume, boolean isMax);
    }
}
