package io.agora.meeting;

import android.app.Application;

import androidx.annotation.Nullable;

import org.jetbrains.annotations.NotNull;

import io.agora.base.PreferenceManager;
import io.agora.base.ToastManager;
import io.agora.base.network.RetrofitManager;
import io.agora.base.util.CryptoUtil;
import io.agora.log.LogManager;
import io.agora.rtc.Constants;
import io.agora.rtc.video.VideoEncoderConfiguration;
import io.agora.sdk.manager.RtcManager;
import io.agora.sdk.manager.RtmManager;
import okhttp3.logging.HttpLoggingInterceptor;

public class MainApplication extends Application {
    public static MainApplication instance;

    public String appId;

    @Override
    public void onCreate() {
        super.onCreate();
        instance = this;

        LogManager.init(this, BuildConfig.EXTRA);
        PreferenceManager.init(this);
        ToastManager.init(this);
        RetrofitManager.instance().setLogger(new HttpLoggingInterceptor.Logger() {
            private final LogManager log = new LogManager(RetrofitManager.class.getSimpleName());

            @Override
            public void log(@NotNull String s) {
                log.d(s);
            }
        });

        setAppId(getString(R.string.agora_app_id));
        RtcManager.instance().init(this, getAppId(), (RtcManager sdk) -> {
            if (sdk == null) return;
            sdk.setChannelProfile(Constants.CHANNEL_PROFILE_LIVE_BROADCASTING);
            sdk.setClientRole(Constants.CLIENT_ROLE_BROADCASTER);
            sdk.setParameters("che.audio.specify.codec", "OPUSFB");
            sdk.setAudioProfile(Constants.AUDIO_PROFILE_DEFAULT, Constants.AUDIO_SCENARIO_CHATROOM_ENTERTAINMENT);
            sdk.setVideoEncoderConfiguration(new VideoEncoderConfiguration(
                    VideoEncoderConfiguration.VD_360x360,
                    VideoEncoderConfiguration.FRAME_RATE.FRAME_RATE_FPS_15,
                    VideoEncoderConfiguration.STANDARD_BITRATE,
                    VideoEncoderConfiguration.ORIENTATION_MODE.ORIENTATION_MODE_FIXED_PORTRAIT
            ));
        });
        RtmManager.instance().init(this, getAppId(), null);
        RetrofitManager.instance().addHeader("Authorization", CryptoUtil.getAuth(getString(R.string.agora_auth)));
    }

    @Nullable
    public static String getAppId() {
        return instance.appId;
    }

    public static void setAppId(String appId) {
        instance.appId = appId;
    }
}
