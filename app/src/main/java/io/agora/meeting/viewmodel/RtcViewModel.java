package io.agora.meeting.viewmodel;

import androidx.annotation.IntRange;
import androidx.annotation.Nullable;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import java.util.HashMap;

import io.agora.base.ToastManager;
import io.agora.base.callback.ThrowableCallback;
import io.agora.meeting.BuildConfig;
import io.agora.meeting.annotaion.room.AudioRoute;
import io.agora.meeting.data.Me;
import io.agora.meeting.data.Room;
import io.agora.sdk.listener.RtcEventListener;
import io.agora.sdk.manager.RtcManager;
import io.agora.sdk.manager.RtmManager;
import io.agora.sdk.manager.SdkManager;

public class RtcViewModel extends ViewModel {
    public final MutableLiveData<Integer> networkQuality = new MutableLiveData<>();
    public final MutableLiveData<Integer> audioRoute = new MutableLiveData<>();

    private RtcEventListener rtcEventListener = new RtcEventHandler(this);

    public RtcViewModel() {
        RtcManager.instance().registerListener(rtcEventListener);
    }

    @Override
    protected void onCleared() {
        super.onCleared();
        RtcManager.instance().unregisterListener(rtcEventListener);
    }

    public void enableLastMileTest(boolean enable) {
        RtcManager.instance().enableLastMileTest(enable);
    }

    public void joinChannel(@Nullable Room room, @Nullable Me me) {
        if (room == null || me == null) return;

        String channelId = room.channelName;
        RtmManager.instance().login(me.rtmToken, me.uid, new ThrowableCallback<Void>() {
            @Override
            public void onSuccess(Void res) {
                RtmManager.instance().joinChannel(new HashMap<String, String>() {{
                    put(SdkManager.CHANNEL_ID, channelId);
                }});
                RtcManager.instance().joinChannel(new HashMap<String, String>() {{
                    put(SdkManager.TOKEN, me.rtcToken);
                    put(SdkManager.CHANNEL_ID, channelId);
                    put(SdkManager.USER_ID, me.getUidStr());
                    put(SdkManager.USER_EXTRA, BuildConfig.EXTRA);
                }});
            }

            @Override
            public void onFailure(Throwable throwable) {
                ToastManager.showShort(throwable.toString());
            }
        });
    }

    public void leaveChannel() {
        RtcManager.instance().leaveChannel();
        RtmManager.instance().leaveChannel();
    }

    public void switchAudioRoute() {
        Integer audioRoute = this.audioRoute.getValue();
        if (audioRoute == null) return;

        if (audioRoute == AudioRoute.EARPIECE) {
            RtcManager.instance().setEnableSpeakerphone(true);
        } else if (audioRoute == AudioRoute.SPEAKER) {
            RtcManager.instance().setEnableSpeakerphone(false);
        }
    }

    public void switchCamera() {
        RtcManager.instance().switchCamera();
    }

    public void enableLocalAudio(boolean enable) {
        RtcManager.instance().enableLocalAudio(enable);
    }

    public void enableLocalVideo(boolean enable) {
        RtcManager.instance().enableLocalVideo(enable);
    }

    public void rate(@IntRange(from = 1, to = 5) int rating) {
        RtcManager.instance().rate(rating, null);
    }
}
