package io.agora.meeting.core;

import android.content.Context;
import android.util.Base64;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

import java.util.Locale;

import io.agora.meeting.core.annotaion.Keep;
import io.agora.meeting.core.annotaion.OS;
import io.agora.meeting.core.annotaion.Terminal;
import io.agora.meeting.core.http.BaseCallback;
import io.agora.meeting.core.http.body.resp.AppVersionResp;
import io.agora.meeting.core.http.network.RetrofitManager;
import io.agora.meeting.core.log.Logger;
import io.agora.meeting.core.model.RoomModel;
import io.agora.rte.AgoraRteCallback;
import io.agora.rte.AgoraRteError;
import io.agora.rte.AgoraRteUploader;
import io.agora.rte.AgoraRteUploaderCreator;
import io.agora.rte.LogUtil;
import io.agora.scene.statistic.AgoraSceneStatistic;
import io.agora.scene.statistic.AgoraSceneStatisticContext;
import io.agora.scene.statistic.AgoraUserRatingValue;

/**
 * Description:
 *
 *
 * @since 2/9/21
 */
public final class MeetingEngine {
    private final MeetingContext mContext;
    private final RtcNetworkMonitor rtcNetworkMonitor;
    private final AgoraRteUploader logUploader;
    private final AgoraSceneStatistic agoraSceneStatistic;

    public MeetingEngine(Context context, MeetingConfig config) {
        Logger.initialize(context, config.logAll);
        RetrofitManager.instance().setLogger(Logger::i);
        RetrofitManager.instance().setAuth(Base64.encodeToString(String.format(Locale.US, "%s:%s", config.customId, config.customCer).getBytes(), Base64.NO_WRAP | Base64.NO_PADDING | Base64.URL_SAFE));

        mContext = new MeetingContext(context, config);
        rtcNetworkMonitor = new RtcNetworkMonitor(context, config);
        logUploader = new AgoraRteUploaderCreator(context, config.appId, false).create();
        agoraSceneStatistic = new AgoraSceneStatistic(RetrofitManager.instance().getClient());
    }

    /**
     * 设置是否默认使用前置摄像头，在joinOrCreateRoom前调用有效
     */
    public void setDefaultCameraFont(boolean enable){
        mContext.config.defaultCameraFront = enable;
    }

    /**
     * 检查是否是最新版本
     */
    public void checkVersion(BaseCallback.SuccessCallback<AppVersionResp> success, BaseCallback.FailureCallback failure) {
        mContext.systemService.checkVersion(mContext.config.appId, OS.ANDROID, Terminal.PHONE, BuildConfig.VERSION_NAME)
                .enqueue(new BaseCallback<>(data -> {
                    if (data != null && data.config != null) {
                        BaseCallback.setErrorMessagesDict(data.config.multiLanguage);
                        if (success != null) {
                            success.onSuccess(data);
                        }
                    }
                }, failure));
    }

    /**
     * 加入房间，如果房间不存在则创建房间
     */
    public RoomModel joinOrCreateRoom(String roomName, String roomId, String roomPwd, // 房间信息
                                      String userName, String userId,
                                      boolean userCameraOpen, boolean userMicOpen, // 用户信息
                                      int durationS, // 会议持续时间
                                      int maxPeople // 会议最大人数
    ) {
        RoomModel roomMode = new RoomModel(mContext, roomName, roomId, roomPwd);
        roomMode.join(userName, userId, userCameraOpen, userMicOpen, durationS, maxPeople);
        return roomMode;
    }

    /**
     * 开启网络探测，探测结果和{@link MeetingConfig#cameraVideoEncoderConfig}的码率配置相关
     */
    public void enableNetQualityCheck(RtcNetworkMonitor.OnNetQualityChangeListener listener) {
        rtcNetworkMonitor.enableNetQualityCheck(listener);
    }

    /**
     * 关闭网络探测
     */
    public void disableNetQualityCheck() {
        rtcNetworkMonitor.disableNetQualityCheck();
    }

    /**
     * 上传日志，外部使用{@link Logger}打印的日志也会上传到服务器上
     */
    public void uploadLog(UploadLogCallback callback) {
        logUploader.uploadLogWithFolderPath(LogUtil.INSTANCE.logFolderPath(mContext.context), new AgoraRteCallback<String>() {
            @Override
            public void success(@Nullable String param) {
                callback.success(param);
            }

            @Override
            public void fail(@NotNull AgoraRteError error) {
                callback.failed(error);
            }
        });
    }

    /**
     * 评分
     *
     * @param callQuality 通话质量
     * @param functionCompleteness 功能完整性
     * @param generalExperience 整体体验
     * @param comment 评论
     */
    public void userRate(String roomId, String userId,
                         float callQuality,
                         float functionCompleteness,
                         float generalExperience,
                         @androidx.annotation.Nullable String comment,
                         @androidx.annotation.Nullable BaseCallback.FailureCallback failure) {
        agoraSceneStatistic.setContent(new AgoraSceneStatisticContext(mContext.context,
                userId,
                "meeting",
                roomId)).userRating(new AgoraUserRatingValue(callQuality, functionCompleteness, generalExperience),
                comment, null, error -> {
                    if (failure != null) failure.onFailure(error);
                });
    }

    public void destroy() {
        mContext.destroy();
        rtcNetworkMonitor.destroy();
    }

    @Keep
    public interface UploadLogCallback{
        void success(String logId);
        void failed(Throwable error);
    }

}
