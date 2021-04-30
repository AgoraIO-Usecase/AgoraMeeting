package io.agora.meeting.core;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;

import io.agora.meeting.core.annotaion.DeviceNetQuality;
import io.agora.meeting.core.annotaion.Keep;
import io.agora.rte.AgoraRteError;
import io.agora.rte.AgoraRteLastmileProbeConfig;
import io.agora.rte.AgoraRteNetworkQuality;
import io.agora.rte.AgoraRteNetworkTestListener;
import io.agora.rte.AgoraRteNetworkTestService;

/**
 * Description:
 * 网络质量探测
 *
 *
 * @since 2/19/21
 */
@Keep
public final class RtcNetworkMonitor {
    private OnNetQualityChangeListener onNetQualityChangeListener;
    private final Context context;
    private final MeetingConfig config;
    private final Handler mHandler;

    private final AgoraRteNetworkTestService testService;
    private final AgoraRteNetworkTestListener testListener = (service, quality) -> {
        if (quality == AgoraRteNetworkQuality.AgoraRteNetworkQualityUnknown
                || quality == AgoraRteNetworkQuality.AgoraRteNetworkQualityDetecting) {
            onNetQualityChanged(DeviceNetQuality.IDLE);
        } else if (quality == AgoraRteNetworkQuality.AgoraRteNetworkQualityExcellent
                || quality == AgoraRteNetworkQuality.AgoraRteNetworkQualityGood) {
            onNetQualityChanged(DeviceNetQuality.GOOD);
        } else if (quality == AgoraRteNetworkQuality.AgoraRteNetworkQualityPoor) {
            onNetQualityChanged(DeviceNetQuality.POOR);
        } else if (quality == AgoraRteNetworkQuality.AgoraRteNetworkQualityBad
                || quality == AgoraRteNetworkQuality.AgoraRteNetworkQualityVBad
                || quality == AgoraRteNetworkQuality.AgoraRteNetworkQualityDown) {
            onNetQualityChanged(DeviceNetQuality.BAD);
        }
    };

    public RtcNetworkMonitor(Context context, MeetingConfig config) {
        this.context = context;
        this.config = config;
        this.mHandler = new Handler(Looper.getMainLooper());
        this.testService = new AgoraRteNetworkTestService(testListener);
    }

    public void enableNetQualityCheck(OnNetQualityChangeListener listener) {
        this.onNetQualityChangeListener = listener;
        testService.initWithAppId(context, config.appId);
        AgoraRteError error = testService.startLastmileProbeTest(new AgoraRteLastmileProbeConfig(
                true,
                false,
                config.cameraVideoEncoderConfig.getBitrate(),
                0
        ));
        if(error != null && onNetQualityChangeListener != null){
            onNetQualityChangeListener.onError(error);
        }
    }

    public void disableNetQualityCheck() {
        this.onNetQualityChangeListener = null;
        this.mHandler.removeCallbacksAndMessages(null);
        AgoraRteError error = testService.stopLastmileProbeTest();
        if(error != null && onNetQualityChangeListener != null){
            onNetQualityChangeListener.onError(error);
        }
    }

    public void destroy() {
        disableNetQualityCheck();
    }

    private void onNetQualityChanged(@DeviceNetQuality int quality) {
        if (onNetQualityChangeListener != null) {
            mHandler.post(() -> {
                if (onNetQualityChangeListener != null) {
                    onNetQualityChangeListener.onNetQualityChanged(quality);
                }
            });
        }
    }

    @Keep
    public interface OnNetQualityChangeListener {

        void onNetQualityChanged(@DeviceNetQuality int quality);

        void onError(Throwable error);
    }

}
