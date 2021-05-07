package io.agora.meeting.core;

import io.agora.rte.AgoraRteAudioEncoderConfig;
import io.agora.rte.AgoraRteAudioProfile;
import io.agora.rte.AgoraRteAudioScenario;
import io.agora.rte.AgoraRteDegradationPreference;
import io.agora.rte.AgoraRteVideoEncoderConfig;
import io.agora.rte.AgoraRteVideoOutputOrientationMode;

/**
 * Description:
 *
 *
 * @since 2/7/21
 */
public final class MeetingConfig {
    private static final String SERVER_URL_RELEASE = "https://api.agora.io";

    public boolean logAll       = BuildConfig.DEBUG;
    public String appId         = "";
    public String customId      = "";
    public String customCer     = "";
    public String meetingSvr    = SERVER_URL_RELEASE;
    public boolean defaultCameraFront = true;
    public AgoraRteVideoEncoderConfig cameraVideoEncoderConfig = new AgoraRteVideoEncoderConfig(
            640,
            480,
            15,
            0,
            AgoraRteVideoOutputOrientationMode.Adaptive,
            AgoraRteDegradationPreference.Quality
    );
    public AgoraRteVideoEncoderConfig screenVideoEncoderConfig = new AgoraRteVideoEncoderConfig(
            1280,
            720,
            15,
            0,
            AgoraRteVideoOutputOrientationMode.Adaptive,
            AgoraRteDegradationPreference.Quality
    );
    public AgoraRteAudioEncoderConfig audioEncoderConfig = new AgoraRteAudioEncoderConfig(
            AgoraRteAudioProfile.defaultt,
            AgoraRteAudioScenario.meeting
    );

}
