package io.agora.meeting.ui.viewmodel;

import android.app.Application;
import android.content.SharedPreferences;

import androidx.lifecycle.AndroidViewModel;

import io.agora.meeting.ui.R;
import io.agora.meeting.ui.data.PreferenceLiveData;
import io.agora.meeting.ui.util.PreferenceUtil;

public class PreferenceViewModel extends AndroidViewModel {
    private final PreferenceLiveData.StringPreferenceLiveData name;
    private final PreferenceLiveData.BooleanPreferenceLiveData camera;
    private final PreferenceLiveData.BooleanPreferenceLiveData cameraFront;
    private final PreferenceLiveData.BooleanPreferenceLiveData mic;
    private final PreferenceLiveData.IntPreferenceLiveData notifyMaxNum;
    private final PreferenceLiveData.IntPreferenceLiveData meetingDuration;
    private final PreferenceLiveData.IntPreferenceLiveData meetingMaxPeople;
    private final PreferenceLiveData.BooleanPreferenceLiveData showPrivacy;

    public PreferenceViewModel(Application application) {
        super(application);
        SharedPreferences preferences = PreferenceUtil.getSharedPreferences();
        name = new PreferenceLiveData.StringPreferenceLiveData(preferences, application.getString(R.string.key_name), null);
        camera = new PreferenceLiveData.BooleanPreferenceLiveData(preferences, application.getString(R.string.key_camera), true);
        cameraFront = new PreferenceLiveData.BooleanPreferenceLiveData(preferences, application.getString(R.string.key_camera_front), true);
        mic = new PreferenceLiveData.BooleanPreferenceLiveData(preferences, application.getString(R.string.key_mic), true);
        notifyMaxNum = new PreferenceLiveData.IntPreferenceLiveData(preferences, application.getString(R.string.key_notify_max_num), 50);
        meetingDuration = new PreferenceLiveData.IntPreferenceLiveData(preferences, application.getString(R.string.key_meeting_duration), 45 * 60);
        meetingMaxPeople = new PreferenceLiveData.IntPreferenceLiveData(preferences, application.getString(R.string.key_meeting_max_people), 1000);
        showPrivacy = new PreferenceLiveData.BooleanPreferenceLiveData(preferences, application.getString(R.string.key_show_privacy_terms), true);
    }

    public PreferenceLiveData.StringPreferenceLiveData getName() {
        return name;
    }

    public void setName(String name) {
        this.name.setValue(name);
    }

    public PreferenceLiveData.BooleanPreferenceLiveData getCamera() {
        return camera;
    }

    public void setCamera(Boolean camera) {
        this.camera.setValue(camera);
    }

    public PreferenceLiveData.BooleanPreferenceLiveData getMic() {
        return mic;
    }

    public void setMic(Boolean mic) {
        this.mic.setValue(mic);
    }

    public boolean getShowPrivacy() {
        return showPrivacy.getValue();
    }

    public void setShowPrivacy(Boolean show) {
        this.showPrivacy.setValue(show);
    }

    public PreferenceLiveData.IntPreferenceLiveData getToastMaxNum() {
        return notifyMaxNum;
    }

    public PreferenceLiveData.IntPreferenceLiveData getMeetingDuration() {
        return meetingDuration;
    }

    public PreferenceLiveData.IntPreferenceLiveData getMeetingMaxPeople() {
        return meetingMaxPeople;
    }

    public void switchCameraFront() {
        this.cameraFront.setValue(!cameraFront.getValue());
    }

    public void setCameraFront(boolean enable) {
        this.cameraFront.setValue(enable);
    }

    public PreferenceLiveData.BooleanPreferenceLiveData getCameraFront() {
        return cameraFront;
    }
}
