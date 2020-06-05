package io.agora.meeting.data;

import android.content.SharedPreferences;

import androidx.annotation.Nullable;
import androidx.lifecycle.MutableLiveData;

public abstract class PreferenceLiveData<T> extends MutableLiveData<T> implements SharedPreferences.OnSharedPreferenceChangeListener {
    SharedPreferences mPreferences;
    private String mKey;
    private T defValue;

    PreferenceLiveData(SharedPreferences preferences, String key, T defValue) {
        this.mPreferences = preferences;
        this.mKey = key;
        this.defValue = defValue;
    }

    abstract T getValue(String key, T defValue);

    abstract void setValue(String key, T value);

    @Override
    public void setValue(T value) {
        setValue(mKey, value);
    }

    @Nullable
    @Override
    public T getValue() {
        return super.getValue();
    }

    @Override
    protected void onActive() {
        super.onActive();
        PreferenceLiveData.super.setValue(getValue(mKey, defValue));
        mPreferences.registerOnSharedPreferenceChangeListener(this);
    }

    @Override
    protected void onInactive() {
        super.onInactive();
        mPreferences.unregisterOnSharedPreferenceChangeListener(this);
    }

    @Override
    public void onSharedPreferenceChanged(SharedPreferences sharedPreferences, String key) {
        if (mKey.equals(key)) {
            PreferenceLiveData.super.setValue(getValue(key, defValue));
        }
    }

    public static class BooleanPreferenceLiveData extends PreferenceLiveData<Boolean> {
        public BooleanPreferenceLiveData(SharedPreferences preferences, String key, Boolean defValue) {
            super(preferences, key, defValue);
        }

        @Override
        Boolean getValue(String key, Boolean defValue) {
            return mPreferences.getBoolean(key, defValue);
        }

        @Override
        void setValue(String key, Boolean value) {
            mPreferences.edit().putBoolean(key, value).apply();
        }
    }

    public static class StringPreferenceLiveData extends PreferenceLiveData<String> {
        public StringPreferenceLiveData(SharedPreferences preferences, String key, String defValue) {
            super(preferences, key, defValue);
        }

        @Override
        String getValue(String key, String defValue) {
            return mPreferences.getString(key, defValue);
        }

        @Override
        void setValue(String key, String value) {
            mPreferences.edit().putString(key, value).apply();
        }
    }
}