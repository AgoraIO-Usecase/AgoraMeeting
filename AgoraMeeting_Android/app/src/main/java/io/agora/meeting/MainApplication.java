package io.agora.meeting;

import android.app.Application;

import androidx.annotation.Nullable;

import io.agora.base.PreferenceManager;
import io.agora.base.ToastManager;
import io.agora.base.network.RetrofitManager;
import io.agora.base.util.CryptoUtil;
import io.agora.log.LogManager;
import io.agora.sdk.manager.RtcManager;
import io.agora.sdk.manager.RtmManager;

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

        setAppId(getString(R.string.agora_app_id));
        RtcManager.instance().init(this, getAppId());
        RtmManager.instance().init(this, getAppId());
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
