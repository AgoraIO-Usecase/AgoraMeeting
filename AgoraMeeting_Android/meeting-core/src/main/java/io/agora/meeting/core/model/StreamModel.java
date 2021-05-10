package io.agora.meeting.core.model;

import android.content.Context;
import android.view.SurfaceView;
import android.view.TextureView;
import android.view.View;

import androidx.annotation.Nullable;

import java.lang.ref.WeakReference;
import java.util.Objects;

import io.agora.meeting.core.MeetingContext;
import io.agora.meeting.core.MeetingRteService;
import io.agora.meeting.core.annotaion.AudioRoute;
import io.agora.meeting.core.annotaion.Keep;
import io.agora.meeting.core.annotaion.RenderMode;
import io.agora.meeting.core.annotaion.RequestState;
import io.agora.meeting.core.annotaion.StreamType;
import io.agora.meeting.core.base.BaseModel;
import io.agora.meeting.core.bean.ScreenToken;
import io.agora.meeting.core.extra.BoardMediaTrack;
import io.agora.meeting.core.extra.ScreenMediaTrack;
import io.agora.meeting.core.http.BaseCallback;
import io.agora.meeting.core.http.body.req.UserPermCloseReq;
import io.agora.meeting.core.http.body.req.UserPermOpenReq;
import io.agora.meeting.core.log.Logger;
import io.agora.rte.AgoraRteAudioScenario;
import io.agora.rte.AgoraRteCameraSource;
import io.agora.rte.AgoraRteCameraVideoTrack;
import io.agora.rte.AgoraRteError;
import io.agora.rte.AgoraRteMediaStreamType;
import io.agora.rte.AgoraRteMediaTrack;
import io.agora.rte.AgoraRteMicAudioTrack;
import io.agora.rte.AgoraRteRenderConfig;
import io.agora.rte.AgoraRteRenderMode;
import io.agora.rte.AgoraRteStreamInfo;
import io.agora.rte.AgoraRteUserInfo;
import io.agora.whiteboard.netless.annotation.Appliance;
import io.agora.whiteboard.netless.widget.WhiteBoardView;

/**
 * Description: 音视频流
 *
 *
 * @since 2/8/21
 */
@Keep
public final class StreamModel extends BaseModel<StreamModel.CallBack> {
    private final MeetingContext context;
    private final AgoraRteStreamInfo mStreamInfo;
    @StreamType
    private final int mStreamType;

    private AgoraRteMediaTrack mMediaTrack;
    private AgoraRteMicAudioTrack mLocalAudioTrack;
    private UserModel mOwner;

    @AudioRoute
    private int audioRoute = AudioRoute.SPEAKER;
    private int audioVolume;
    private boolean isMaxVolume;

    private final InnerStreamObserver innerStreamObserver = new InnerStreamObserver();
    private WeakReference<View> renderViewRef;
    private final View.OnAttachStateChangeListener renderViewAttachListener = new View.OnAttachStateChangeListener() {
        @Override
        public void onViewAttachedToWindow(View v) {
            if(renderViewRef != null){
                View view = renderViewRef.get();
                if(view == v){
                    setVideoSubscript(true);
                }
            }
        }

        @Override
        public void onViewDetachedFromWindow(View v) {
            if(renderViewRef != null){
                View view = renderViewRef.get();
                if(view == v){
                    setVideoSubscript(false);
                }
            }
        }
    };

    public StreamModel(MeetingContext context,
                       UserModel owner,
                       AgoraRteStreamInfo streamInfo,
                       @StreamType int streamType) {
        this.context = context;
        this.mOwner = owner;
        this.mStreamInfo = streamInfo;
        this.mStreamType = streamType;
        context.rteService.registerStreamChangerObserver(getStreamId(), innerStreamObserver);
        initMediaTrack();
    }

    private void initMediaTrack() {
        if (mStreamType == StreamType.BOARD) {
            mMediaTrack = new BoardMediaTrack(context.mRootActivity, mStreamInfo.getStreamId(), mStreamInfo.getStreamName(), canBoardInteract());
            mMediaTrack.start();
            return;
        }
        if (mStreamType == StreamType.SCREEN && getOwner().isScreenOwner()) {
            mMediaTrack = new ScreenMediaTrack(context.context, context.config.appId, context.rteService.getRoomId(), getStreamId());
            ((ScreenMediaTrack)mMediaTrack).setVideoEncoderConfig(context.config.screenVideoEncoderConfig);
            context.screenRtcToken.execWhen(data -> {
                UserModel owner = getOwner();
                if(owner != null){
                    owner.stopScreenShare();
                }
            }, new ScreenToken(RequestState.IDLE));
            context.screenRtcToken.execWhen(data -> {
                if(mMediaTrack != null){
                    ((ScreenMediaTrack) mMediaTrack).setRtcToken(data.rtcToken);
                }
            }, new ScreenToken(RequestState.SUCCESS));
            mMediaTrack.start();
            return;
        }
        if (mStreamType == StreamType.MEDIA) {
            if (mOwner.isLocal()) {
                // 开启大小流
                context.rteService.enableDualStreamMode(true);
                // 开启音量检测
                context.rteService.getLocalAudioMediaTrack().enableAudioVolumeIndication();
                context.rteService.getLocalAudioMediaTrack().setAudioRouteChangeListener(audioRoute -> {
                    StreamModel.this.audioRoute = audioRoute;
                    invokeCallback(callBack -> callBack.onAudioRouteChange(audioRoute));
                });
                AgoraRteCameraVideoTrack videoMediaTrack = context.rteService.getLocalVideoMediaTrack();
                videoMediaTrack.setCameraSource(context.config.defaultCameraFront ? AgoraRteCameraSource.Front: AgoraRteCameraSource.Back);
                videoMediaTrack.setVideoEncoderConfig(context.config.cameraVideoEncoderConfig);
                mMediaTrack = videoMediaTrack;
                mLocalAudioTrack = context.rteService.getLocalAudioMediaTrack();
            }
            updateRemoteStreamState(false);
        }

        Logger.d("StreamChange >> StreamModel#initialize streamId=" + getStreamId() + ", video=" + hasVideo() + ", audio=" + hasAudio());
    }

    /**
     * @return 是否是白板
     */
    public boolean isBoard() {
        return mStreamType == StreamType.BOARD;
    }

    /**
     * @return 是否是屏幕共享
     */
    public boolean isScreen() {
        return mStreamType == StreamType.SCREEN;
    }

    /**
     * @return 是否可以操作白板
     */
    public boolean canBoardInteract() {
        return context.rteService.canBoardInteractByMe();
    }

    /**
     * @return 流类型，包括 音视频流/白板/屏幕共享
     */
    @StreamType
    public int getStreamType() {
        return mStreamType;
    }

    /**
     * @return 流的唯一标识
     */
    public String getStreamId() {
        return mStreamInfo.getStreamId();
    }

    /**
     * @return 流所属的用户
     */
    public UserModel getOwner() {
        return mOwner;
    }

    /**
     * @return 流所属的用户id
     */
    public String getOwnerUserId() {
        if (mOwner == null) {
            return "";
        }
        return mOwner.getUserId();
    }

    /**
     * @return 流所属的用户名称
     */
    public String getOwnerUserName() {
        if (mOwner == null) {
            return "";
        }
        return mOwner.getUserName();
    }

    /**
     * @return 是否有视频
     */
    public boolean hasVideo() {
        return mStreamInfo.getHasVideo()
                || (getOwner() != null && !getOwner().isScreenOwner() && isScreen())
                || isBoard();
    }

    /**
     * @return 是否有音频
     */
    public boolean hasAudio() {
        return mStreamInfo.getHasAudio() && !isScreen() && !isBoard();
    }

    /**
     * @param enable 是否打开视频
     */
    public void setVideoEnable(boolean enable) {
        if(Boolean.compare(enable, hasVideo()) == 0){
            return;
        }
        Logger.d("StreamChange >> setVideoEnable=" + enable + ", userId=" + getOwnerUserId());
        if (enable) {
            UserPermOpenReq body = new UserPermOpenReq();
            body.micAccess = false;
            body.cameraAccess = true;
            context.userService.requestUserPermissions(context.config.appId, context.rteService.getRoomId(), context.rteService.getLocalUserId(), body)
                    .enqueue(new BaseCallback<>(error -> invokeCallback(callBack -> callBack.onError(error))));
        } else {
            // 关闭摄像头
            UserPermCloseReq body = new UserPermCloseReq();
            body.micClose = false;
            body.cameraClose = true;
            body.targetUserId = getOwnerUserId();
            context.userService.closeUserPermissions(context.config.appId, context.rteService.getRoomId(), context.rteService.getLocalUserId(), body)
                    .enqueue(new BaseCallback<>(error -> invokeCallback(callBack -> callBack.onError(error))));
        }
    }

    /**
     * @param enable 是否打开音频
     */
    public void setAudioEnable(boolean enable) {
        if (Boolean.compare(enable, hasAudio()) == 0) {
            return;
        }
        Logger.d("StreamChange >> setAudioEnable=" + enable + ", userId=" + getOwnerUserId());
        if (enable) {
            UserPermOpenReq body = new UserPermOpenReq();
            body.micAccess = true;
            body.cameraAccess = false;
            context.userService.requestUserPermissions(context.config.appId, context.rteService.getRoomId(), context.rteService.getLocalUserId(), body)
                    .enqueue(new BaseCallback<>(error -> invokeCallback(callBack -> callBack.onError(error))));
        } else {
            UserPermCloseReq body = new UserPermCloseReq();
            body.micClose = true;
            body.cameraClose = false;
            body.targetUserId = getOwnerUserId();
            context.userService.closeUserPermissions(context.config.appId, context.rteService.getRoomId(), context.rteService.getLocalUserId(), body)
                    .enqueue(new BaseCallback<>(error -> invokeCallback(callBack -> callBack.onError(error))));
        }
    }

    /**
     * 有耳机时固定耳机，无耳机时在 听筒和扬声器 间切换
     */
    public void switchLocalMic(){
        setEnableSpeakerphone(!isSpeakerphoneEnabled());
    }

    /**
     *
     * 启用/关闭扬声器播放。
     *
     * @param enable true: 切换到外放。如果设备连接了耳机或蓝牙，则无法切换到外放。
     *               false: 切换到听筒。如果设备连接了耳机，则语音路由走耳机。
     * @return 方法调用是否成功
     */
    public boolean setEnableSpeakerphone(boolean enable){
        if (mLocalAudioTrack != null && context.config.audioEncoderConfig.getScenario() != AgoraRteAudioScenario.meeting) {
            AgoraRteError agoraRteError = mLocalAudioTrack.setEnableSpeakerphone(enable);
            return agoraRteError.getCode() == 0;
        }
        return false;
    }

    /**
     *
     * 检查扬声器状态启用状态。
     *
     * @return true：扬声器已开启，语音会输出到扬声器
     *         false：扬声器未开启，语音会输出到非扬声器（听筒，耳机等）
     */
    public boolean isSpeakerphoneEnabled(){
        if(mLocalAudioTrack != null){
            return mLocalAudioTrack.isSpeakerphoneEnabled();
        }
        return false;
    }

    /**
     * @return 音频播放设备
     */
    @AudioRoute
    public int getAudioRoute() {
        return audioRoute;
    }

    /**
     *
     * @return 获取音频音量
     */
    public int getAudioVolume() {
        return audioVolume;
    }

    /**
     *
     * @return 是不是所有流里的最大音量
     */
    public boolean isVolumeMax() {
        return isMaxVolume;
    }

    /**
     * 切换本地摄像头
     */
    public void switchLocalCamera() {
        if (mMediaTrack instanceof AgoraRteCameraVideoTrack) {
            ((AgoraRteCameraVideoTrack) mMediaTrack).switchCamera();
        }
    }

    /**
     * @param context 上下文
     * @return 显示视频的SurfaceView
     */
    public SurfaceView createSurfaceView(Context context) {
        return this.context.rteService.createSurfaceView(context);
    }

    /**
     * @param context 上下文
     * @return 显示视频的TextureView
     */
    public TextureView createTextureView(Context context) {
        return this.context.rteService.createTextureView(context);
    }

    /**
     * 订阅显示视频
     *
     * @param view       由{@link StreamModel#createSurfaceView(Context)} 或 {@link StreamModel#createTextureView(Context)} 创建的视图
     * @param renderMode 显示模式，是全屏还是居中
     */
    public void subscriptVideo(View view, @RenderMode int renderMode, boolean highStream) {
        AgoraRteRenderMode rteRenderMode = renderMode == RenderMode.FIT ? AgoraRteRenderMode.Fit : AgoraRteRenderMode.Hidden;
        AgoraRteRenderConfig config = new AgoraRteRenderConfig(rteRenderMode, true);
        if (getOwner().isLocal() && getStreamType() != StreamType.SCREEN) {
            ((AgoraRteCameraVideoTrack) mMediaTrack).setRenderConfig(config);
            ((AgoraRteCameraVideoTrack) mMediaTrack).setView(view);
        } else if(getStreamType() != StreamType.BOARD){
            if(renderViewRef != null){
                View oView = renderViewRef.get();
                if(oView == view){
                    if(oView.isAttachedToWindow()){
                        setVideoSubscript(true);
                    }
                    return;
                }else if(oView != null){
                    oView.removeOnAttachStateChangeListener(renderViewAttachListener);
                }
            }
            renderViewRef = new WeakReference<>(view);
            view.addOnAttachStateChangeListener(renderViewAttachListener);
            context.rteService.renderRemoteVideo(getStreamId(), view, config);
            context.rteService.enableRemoteVideoHighStream(getStreamId(), highStream);
            if(view.isAttachedToWindow()){
                setVideoSubscript(true);
            }
        }
    }

    public void unSubscriptVideo(){
        setVideoSubscript(false);
    }

    private void setVideoSubscript(boolean subscript) {
        if(getOwner().isLocal() || getStreamType() == StreamType.BOARD){
            return;
        }

        if (!isReleased() && context.rteService != null) {
            Logger.d("StreamModel", "setVideoSubscript streamId=" + getStreamId() + ",subscript=" + subscript);
            if (subscript) {
                updateRemoteStreamState(true);
            } else {
                context.rteService.unsubscribeRemoteStream(getStreamId(), AgoraRteMediaStreamType.video);
            }
        }
    }

    /**
     * 获取白板的视图，只能显示在一个地方
     *
     * @param detachFromParent 是否从View.Parent里移除，false时要手动移除，否则会报错
     * @return 白板视图
     */
    public WhiteBoardView getBoardView(boolean detachFromParent) {
        if (mMediaTrack instanceof BoardMediaTrack) {
            return ((BoardMediaTrack) mMediaTrack).getBoardView(detachFromParent);
        }
        return null;
    }

    /**
     * @return 白板画笔颜色
     */
    public int[] getBoardStrokeColor() {
        if (mMediaTrack instanceof BoardMediaTrack) {
            return ((BoardMediaTrack) mMediaTrack).getBoardStrokeColor();
        }
        return null;
    }

    /**
     * 设置白板是否可写，主要我可操作白板时才能将白板设为可写
     *
     */
    public void setBoardWritable(boolean writable){
        if(canBoardInteract()){
            if (mMediaTrack instanceof BoardMediaTrack) {
                ((BoardMediaTrack) mMediaTrack).setWritable(writable);
            }
        }
    }

    /**
     * 修改白板画笔颜色
     *
     * @param color 画笔颜色
     */
    public void changeBoardStrokeColor(int[] color) {
        if (mMediaTrack instanceof BoardMediaTrack) {
            ((BoardMediaTrack) mMediaTrack).setStrokeColor(color);
        }
    }

    /**
     * 设置白板工具类型
     *
     * @param appliance 工具类型
     */
    public void setBoardAppliance(@Appliance String appliance) {
        if (mMediaTrack instanceof BoardMediaTrack) {
            ((BoardMediaTrack) mMediaTrack).setAppliance(appliance);
        }
    }

    /**
     * 清除白板内容
     */
    public void cleanBoard(){
        if (mMediaTrack instanceof BoardMediaTrack) {
            ((BoardMediaTrack) mMediaTrack).cleanBoard();
        }
    }

    /**
     * 更新屏幕共享的推流用户token
     */
    public void updateScreenRtcToken(String rtcToken) {
        if (mMediaTrack instanceof ScreenMediaTrack) {
            ((ScreenMediaTrack) mMediaTrack).setRtcToken(rtcToken);
        }
    }

    private void updateRemoteStreamState(boolean videoOrAudio){
        if(getOwner().isLocal() || getStreamType() == StreamType.BOARD){
            return;
        }
        if(videoOrAudio){
            if(hasVideo()){
                context.rteService.subscribeRemoteStream(getStreamId(), AgoraRteMediaStreamType.video);
            }else{
                context.rteService.unsubscribeRemoteStream(getStreamId(), AgoraRteMediaStreamType.video);
            }
        }else{
            if(hasAudio()){
                context.rteService.subscribeRemoteStream(getStreamId(), AgoraRteMediaStreamType.audio);
            }else{
                context.rteService.unsubscribeRemoteStream(getStreamId(), AgoraRteMediaStreamType.audio);
            }
        }
    }

    @Override
    public void release() {
        Logger.d("StreamModel >> release subscriptVideo null");
        context.rteService.stopRenderRemoteStream(getStreamId());
        context.rteService.unregisterStreamChangeObserver(getStreamId(), innerStreamObserver);
        if (mMediaTrack != null) {
            mMediaTrack.stop();
            mMediaTrack = null;
        }
        if(mLocalAudioTrack != null){
            mLocalAudioTrack.stop();
            mLocalAudioTrack = null;
        }
        if(renderViewRef != null){
            View oView = renderViewRef.get();
            if(oView != null){
                oView.removeOnAttachStateChangeListener(renderViewAttachListener);
            }
            renderViewRef = null;
        }
        mOwner = null;
        super.release();
    }

    private class InnerStreamObserver implements MeetingRteService.StreamChangeObserver {
        @Override
        public void onStreamUpdate(AgoraRteStreamInfo streamInfo, @Nullable AgoraRteUserInfo operator) {
            // 白板权限是否有变化
            if (isBoard() && mMediaTrack instanceof BoardMediaTrack && operator != null) {
                boolean writable = ((BoardMediaTrack) mMediaTrack).isWritable();
                boolean canInteract = context.rteService.canBoardInteractByMe();
                boolean interactChange = Boolean.compare(writable, canInteract) != 0;
                if (interactChange) {
                    context.msgHandler.handleBoardInteractState(operator.getUserId(), operator.getUserName(), canInteract);
                    ((BoardMediaTrack) mMediaTrack).setWritable(canInteract);
                    invokeCallback(callBack -> callBack.onStreamChanged(StreamModel.this));
                }
                return;
            }

            // 判断流信息是否变化
            boolean audioChange = Boolean.compare(mStreamInfo.getHasAudio(), streamInfo.getHasAudio()) != 0;
            boolean videoChange = Boolean.compare(mStreamInfo.getHasVideo(), streamInfo.getHasVideo()) != 0;

            Logger.d("StreamChange >> StreamModel#onStreamUpdate: streamId= "+ streamInfo.getStreamId() + ",video=" + streamInfo.getHasVideo() + ",audio=" + streamInfo.getHasAudio());
            if (!audioChange && !videoChange) {
                return;
            }

            StreamModel.this.mStreamInfo.setHasAudio(streamInfo.getHasAudio());
            StreamModel.this.mStreamInfo.setHasVideo(streamInfo.getHasVideo());
            if(videoChange) updateRemoteStreamState(true);
            if(audioChange) updateRemoteStreamState(false);
            invokeCallback(callBack -> callBack.onStreamChanged(StreamModel.this));
        }

        @Override
        public void onAudioVolumeIndication(int volume, boolean isMax) {
            audioVolume = volume;
            isMaxVolume = isMax;
            invokeCallback(callBack -> callBack.onAudioVolumeChanged(StreamModel.this));
        }
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        StreamModel that = (StreamModel) o;

        if (mStreamType != that.mStreamType) return false;
        return Objects.equals(mStreamInfo, that.mStreamInfo);
    }

    @Override
    public int hashCode() {
        int result = mStreamInfo != null ? mStreamInfo.hashCode() : 0;
        result = 31 * result + mStreamType;
        return result;
    }

    @Keep
    public interface CallBack {
        void onError(Throwable error);
        void onStreamChanged(StreamModel streamModel);
        void onAudioVolumeChanged(StreamModel streamModel);
        void onAudioRouteChange(@AudioRoute int audioRoute);
    }

}
