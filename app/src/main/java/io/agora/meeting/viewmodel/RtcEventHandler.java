package io.agora.meeting.viewmodel;

import androidx.annotation.NonNull;

import io.agora.meeting.annotaion.room.AudioRoute;
import io.agora.meeting.annotaion.room.NetworkQuality;
import io.agora.rtc.Constants;
import io.agora.sdk.listener.RtcEventListener;

public class RtcEventHandler extends RtcEventListener {
    private RtcViewModel rtcVM;

    public RtcEventHandler(@NonNull RtcViewModel viewModel) {
        this.rtcVM = viewModel;
    }

    @Override
    public void onLastmileQuality(@io.agora.sdk.annotation.NetworkQuality int quality) {
        if (quality == Constants.QUALITY_UNKNOWN
                || quality == Constants.QUALITY_DETECTING) {
            rtcVM.networkQuality.postValue(NetworkQuality.IDLE);
        } else if (quality == Constants.QUALITY_EXCELLENT
                || quality == Constants.QUALITY_GOOD) {
            rtcVM.networkQuality.postValue(NetworkQuality.GOOD);
        } else if (quality == Constants.QUALITY_POOR) {
            rtcVM.networkQuality.postValue(NetworkQuality.POOR);
        } else if (quality == Constants.QUALITY_BAD
                || quality == Constants.QUALITY_VBAD
                || quality == Constants.QUALITY_DOWN) {
            rtcVM.networkQuality.postValue(NetworkQuality.BAD);
        }
    }

    @Override
    public void onAudioRouteChanged(@io.agora.sdk.annotation.AudioRoute int routing) {
        if (routing == Constants.AUDIO_ROUTE_HEADSET
                || routing == Constants.AUDIO_ROUTE_HEADSETNOMIC
                || routing == Constants.AUDIO_ROUTE_HEADSETBLUETOOTH) {
            rtcVM.audioRoute.postValue(AudioRoute.HEADSET);
        } else if (routing == Constants.AUDIO_ROUTE_EARPIECE) {
            rtcVM.audioRoute.postValue(AudioRoute.EARPIECE);
        } else {
            rtcVM.audioRoute.postValue(AudioRoute.SPEAKER);
        }
    }
}
