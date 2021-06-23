package io.agora.meeting.core;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.agora.meeting.core.annotaion.RequestState;
import io.agora.meeting.core.bean.ScreenToken;
import io.agora.meeting.core.http.RoomService;
import io.agora.meeting.core.http.SystemService;
import io.agora.meeting.core.http.UserService;
import io.agora.meeting.core.http.network.RetrofitManager;
import io.agora.rtc.ss.utils.SimpleSafeData;

/**
 * Description:
 *
 *
 * @since 2/9/21
 */
public final class MeetingContext {

    public Context context;
    public Context mRootActivity;

    public final MeetingConfig config;

    public final RoomService    roomService;
    public final UserService    userService;
    public final SystemService  systemService;

    public final MeetingRteService rteService;
    public final MeetingMsgHandler msgHandler;

    public boolean openLocalMic, openLocalCamera;
    public final SimpleSafeData<ScreenToken> screenRtcToken = new SimpleSafeData<>(new ScreenToken(RequestState.IDLE));


    private final Application.ActivityLifecycleCallbacks atyCallback = new Application.ActivityLifecycleCallbacks() {
        @Override
        public void onActivityCreated(@NonNull Activity activity, @Nullable Bundle savedInstanceState) {
            if (mRootActivity != activity) {
                mRootActivity = activity;
            }
        }

        @Override
        public void onActivityStarted(@NonNull Activity activity) {}

        @Override
        public void onActivityResumed(@NonNull Activity activity) {
            if (mRootActivity != activity) {
                mRootActivity = activity;
            }
        }

        @Override
        public void onActivityPaused(@NonNull Activity activity) {
            if (mRootActivity == activity) {
                mRootActivity = null;
            }
        }

        @Override
        public void onActivityStopped(@NonNull Activity activity) {}

        @Override
        public void onActivitySaveInstanceState(@NonNull Activity activity, @NonNull Bundle outState) {

        }

        @Override
        public void onActivityDestroyed(@NonNull Activity activity) {
            if (mRootActivity == activity) {
                mRootActivity = null;
            }
        }
    };


    public MeetingContext(Context context, MeetingConfig config) {
        this.context = context;
        this.config = config;
        this.roomService = RetrofitManager.instance().getService(config.meetingSvr, RoomService.class);
        this.userService = RetrofitManager.instance().getService(config.meetingSvr, UserService.class);
        this.systemService = RetrofitManager.instance().getService(config.meetingSvr, SystemService.class);
        this.rteService = new MeetingRteService(context, config);
        this.msgHandler = new MeetingMsgHandler();

        if (context instanceof Application) {
            ((Application) context).registerActivityLifecycleCallbacks(atyCallback);
        } else {
            mRootActivity = context;
        }
    }

    public void destroy() {
        if (context instanceof Application) {
            ((Application) context).unregisterActivityLifecycleCallbacks(atyCallback);
        }
        screenRtcToken.clean();
        rteService.destroy();
        mRootActivity = null;
    }

}
