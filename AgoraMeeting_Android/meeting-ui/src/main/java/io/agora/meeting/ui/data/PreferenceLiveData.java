package io.agora.meeting.ui.data;

import android.content.SharedPreferences;

import androidx.annotation.NonNull;
import androidx.lifecycle.MutableLiveData;

public abstract class PreferenceLiveData<T> extends MutableLiveData<T> implements SharedPreferences.OnSharedPreferenceChangeListener {
    SharedPreferences mPreferences;
    private String mKey;
    private T defValue;

    PreferenceLiveData(SharedPreferences preferences, String key, T defValue) {
        this.mPreferences = preferences;
        this.mKey = key;
        this.defValue = defValue;
        init();
    }

    private void init(){
        if(!mPreferences.contains(mKey)){
            setValue(defValue);
        }
    }

    abstract T getValue(String key, T defValue);

    abstract void setValue(String key, T value);

    @Override
    public void setValue(T value) {
        setValue(mKey, value);
    }

    @NonNull
    @Override
    public T getValue() {
        T value = super.getValue();
        if(value == null){
            value = getValue(mKey, defValue);
        }
        return value;
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

    public static final class BooleanPreferenceLiveData extends PreferenceLiveData<Boolean> {
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

    public static final class StringPreferenceLiveData extends PreferenceLiveData<String> {
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

    public static final class IntPreferenceLiveData extends PreferenceLiveData<Integer> {
        public IntPreferenceLiveData(SharedPreferences preferences, String key, Integer defValue) {
            super(preferences, key, defValue);
        }

        @Override
        Integer getValue(String key, Integer defValue) {
            return mPreferences.getInt(key, defValue);
        }

        @Override
        void setValue(String key, Integer value) {
            mPreferences.edit().putInt(key, value).apply();
        }
    }
}