package io.agora.meeting.core.extra;

import android.content.Context;
import android.text.TextUtils;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

import io.agora.meeting.core.annotaion.Keep;
import io.agora.rtc.ss.ScreenSharingClient;
import io.agora.rtc.video.VideoEncoderConfiguration;
import io.agora.rte.AgoraRteAudioSourceType;
import io.agora.rte.AgoraRteError;
import io.agora.rte.AgoraRteMediaTrack;
import io.agora.rte.AgoraRteVideoEncoderConfig;
import io.agora.rte.AgoraRteVideoSourceType;
import io.agora.rte.internal.impl.Converter;

/**
 * Description:
 *
 *
 * @since 2/23/21
 */
@Keep
public final class ScreenMediaTrack implements AgoraRteMediaTrack {

    private Context context;
    private String appId;
    private String channelName;

    private String streamId;
    private String rtcToken;
    private VideoEncoderConfiguration encoderConfiguration;

    private boolean pendingStart = false;

    public ScreenMediaTrack(Context context, String appId, String channelId, String streamId) {
        this.context = context;
        this.appId = appId;
        this.channelName = channelId;
        this.streamId = streamId;
    }

    public AgoraRteError setVideoEncoderConfig(AgoraRteVideoEncoderConfig config){
        this.encoderConfiguration = config.toRtcVideoEncodeConfig();
        return null;
    }

    public void setRtcToken(String rtcToken) {
        this.rtcToken = rtcToken;
        if(pendingStart){
            pendingStart = false;
            startScreen();
        }else{
            ScreenSharingClient.getInstance().renewToken(rtcToken);
        }
    }

    @Nullable
    @Override
    public AgoraRteError start() {
        if(!TextUtils.isEmpty(rtcToken)){
            startScreen();
        }else{
            pendingStart = true;
        }
        return null;
    }

    private void startScreen() {
        ScreenSharingClient.getInstance().start(context,
                appId,
                rtcToken,
                channelName,
                Converter.INSTANCE.stringToSignedInt(streamId),
                encoderConfiguration);
    }

    @Nullable
    @Override
    public AgoraRteError stop() {
        ScreenSharingClient.getInstance().stop(context);
        pendingStart = false;
        context = null;
        return null;
    }

    @NotNull
    @Override
    public AgoraRteVideoSourceType getVideoSourceType() {
        return AgoraRteVideoSourceType.screen;
    }

    @NotNull
    @Override
    public AgoraRteAudioSourceType getAudioSourceType() {
        return AgoraRteAudioSourceType.none;
    }

    @NotNull
    @Override
    public String getTrackId() {
        return this.toString();
    }
}
