package io.agora.meeting.viewmodel;

import android.content.Context;
import android.content.SharedPreferences;

import androidx.lifecycle.ViewModel;
import androidx.preference.PreferenceManager;

import io.agora.meeting.MainApplication;
import io.agora.meeting.R;
import io.agora.meeting.data.PreferenceLiveData;

public class PreferenceViewModel extends ViewModel {
    private PreferenceLiveData.StringPreferenceLiveData name;
    private PreferenceLiveData.BooleanPreferenceLiveData camera;
    private PreferenceLiveData.BooleanPreferenceLiveData mic;

    public PreferenceViewModel() {
        Context context = MainApplication.instance;
        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(context);
        name = new PreferenceLiveData.StringPreferenceLiveData(preferences, context.getString(R.string.key_name), null);
        camera = new PreferenceLiveData.BooleanPreferenceLiveData(preferences, context.getString(R.string.key_camera), false);
        mic = new PreferenceLiveData.BooleanPreferenceLiveData(preferences, context.getString(R.string.key_mic), false);
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
}
