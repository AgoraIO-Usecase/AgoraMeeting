package io.agora.meeting;

import android.app.Application;

import androidx.annotation.Nullable;

import org.jetbrains.annotations.NotNull;

import io.agora.base.PreferenceManager;
import io.agora.base.ToastManager;
import io.agora.base.network.RetrofitManager;
import io.agora.base.util.CryptoUtil;
import io.agora.log.LogManager;
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
