package io.agora.rtc.ss.impl;

import android.app.Notification;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.os.Build;
import android.os.IBinder;
import android.os.Process;
import android.os.RemoteCallbackList;
import android.os.RemoteException;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.WindowManager;

import androidx.core.app.NotificationCompat;

import io.agora.rtc.Constants;
import io.agora.rtc.IRtcEngineEventHandler;
import io.agora.rtc.RtcEngine;
import io.agora.rtc.ss.Constant;
import io.agora.rtc.ss.R;
import io.agora.rtc.ss.aidl.INotification;
import io.agora.rtc.ss.aidl.IScreenSharing;
import io.agora.rtc.ss.gles.GLRender;
import io.agora.rtc.ss.gles.ImgTexFrame;
import io.agora.rtc.ss.gles.SinkConnector;
import io.agora.rtc.video.VideoEncoderConfiguration;

public class ScreenSharingService extends Service {

    private static final String LOG_TAG = ScreenSharingService.class.getSimpleName();

    private ScreenCapture mScreenCapture;
    private GLRender mScreenGLRender;
    private RtcEngine mRtcEngine;
    private Context mContext;
    private ScreenCaptureSource mSCS;

    private RemoteCallbackList<INotification> mCallbacks
            = new RemoteCallbackList<INotification>();

    private final IScreenSharing.Stub mBinder = new IScreenSharing.Stub() {
        public void registerCallback(INotification cb) {
            if (cb != null) mCallbacks.register(cb);
        }

        public void unregisterCallback(INotification cb) {
            if (cb != null) mCallbacks.unregister(cb);
        }

        public void startShare() {
            startCapture();
        }

        public void stopShare() {
            stopCapture();
        }

        public void renewToken(String token) {
            refreshToken(token);
        }
    };
    private Intent mIntent;

    private void initModules() {
        WindowManager wm = (WindowManager) getApplicationContext().getSystemService(Context.WINDOW_SERVICE);
        DisplayMetrics metrics = new DisplayMetrics();
        wm.getDefaultDisplay().getMetrics(metrics);

        if (mScreenGLRender == null) {
            mScreenGLRender = new GLRender();
        }
        if (mScreenCapture == null) {
            mScreenCapture = new ScreenCapture(mContext, mScreenGLRender, metrics.widthPixels, metrics.heightPixels, metrics.densityDpi);
        }

        mScreenCapture.mImgTexSrcConnector.connect(new SinkConnector<ImgTexFrame>() {
            @Override
            public void onFormatChanged(Object obj) {
                Log.d(LOG_TAG, "onFormatChanged " + obj.toString());
            }

            @Override
            public void onFrameAvailable(ImgTexFrame frame) {
                Log.d(LOG_TAG, "onFrameAvailable " + frame.toString() + ",pts=" + frame.pts + ",width="+frame.mFormat.mWidth + ",height=" + frame.mFormat.mHeight);

                if (mRtcEngine == null || mSCS.getConsumer() == null) {
                    return;
                }

                mSCS.getConsumer().consumeTextureFrame(frame.mTextureId, frame.mFormat.mColorFormat, frame.mFormat.mWidth,
                        frame.mFormat.mHeight, 0, frame.pts, frame.mTexMatrix);
            }
        });

        mScreenCapture.setOnScreenCaptureListener(new ScreenCapture.OnScreenCaptureListener() {
            @Override
            public void onStarted() {
                Log.d(LOG_TAG, "Screen Record Started");
            }

            @Override
            public void onError(int err) {
                Log.d(LOG_TAG, "onError " + err);
                switch (err) {
                    case ScreenCapture.SCREEN_ERROR_SYSTEM_UNSUPPORTED:
                        break;
                    case ScreenCapture.SCREEN_ERROR_PERMISSION_DENIED:
                        break;
                }
            }
        });

        DisplayMetrics outMetrics = new DisplayMetrics();
        wm.getDefaultDisplay().getMetrics(outMetrics);
        int screenWidth = outMetrics.widthPixels;
        int screenHeight = outMetrics.heightPixels;

        initOffscreenPreview(screenWidth, screenHeight);
    }

    private void deInitModules() {
        if(mRtcEngine != null){
            mRtcEngine.leaveChannel();
            RtcEngine.destroy();
            mRtcEngine = null;
        }

        if (mScreenCapture != null) {
            mScreenCapture.release();
            mScreenCapture = null;
        }

        if (mScreenGLRender != null) {
            mScreenGLRender.quit();
            mScreenGLRender = null;
        }
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        WindowManager wm = (WindowManager) getApplicationContext().getSystemService(Context.WINDOW_SERVICE);
        DisplayMetrics outMetrics = new DisplayMetrics();
        wm.getDefaultDisplay().getMetrics(outMetrics);
        int screenWidth = outMetrics.widthPixels;
        int screenHeight = outMetrics.heightPixels;

        Log.d(LOG_TAG, "onConfigurationChanged " + newConfig.orientation + " " + screenWidth + " " + screenHeight);
        updateOffscreenPreview(screenWidth, screenHeight);
    }

    /**
     * Init offscreen preview.
     *
     * @param width  offscreen width
     * @param height offscreen height
     * @throws IllegalArgumentException
     */
    public void initOffscreenPreview(int width, int height) throws IllegalArgumentException {
        if (width <= 0 || height <= 0) {
            throw new IllegalArgumentException("Invalid offscreen resolution");
        }

        mScreenGLRender.init(width, height);
    }

    /**
     * Update offscreen preview.
     *
     * @param width  offscreen width
     * @param height offscreen height
     * @throws IllegalArgumentException
     */
    public void updateOffscreenPreview(int width, int height) throws IllegalArgumentException {
        if (width <= 0 || height <= 0) {
            throw new IllegalArgumentException("Invalid offscreen resolution");
        }

        mScreenGLRender.update(width, height);
    }

    private void startCapture() {
        mScreenCapture.start();
        startForeground(55431, getForeNotification());
    }

    private Notification getForeNotification() {
        Notification notification;
        String eventTitle = getResources().getString(R.string.app_name);
        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, NotificationHelper.generateChannelId(getApplication(), 55431))
                .setContentTitle(eventTitle)
                .setContentText(eventTitle);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
            builder.setColor(getResources().getColor(android.R.color.black));
        notification = builder.build();
        notification.flags |= Notification.FLAG_ONGOING_EVENT;

        return notification;
    }

    private void stopCapture() {
        stopForeground(true);
        mScreenCapture.stop();
    }

    private void refreshToken(String token) {
        if (mRtcEngine != null) {
            mRtcEngine.renewToken(token);
        } else {
            Log.e(LOG_TAG, "rtc engine is null");
        }
    }

    @Override
    public void onCreate() {
        mContext = getApplicationContext();
        initModules();
    }

    @Override
    public IBinder onBind(Intent intent) {
        mIntent = intent;
        initialize();
        return mBinder;
    }

    private void initialize() {
        setUpEngine();
        setUpVideoConfig();
        joinChannel();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        deInitModules();
    }

    private void joinChannel() {
        String accessToken = mIntent.getStringExtra(Constant.ACCESS_TOKEN);
        String channelName = mIntent.getStringExtra(Constant.CHANNEL_NAME);
        String optionalInfo = "ss_" + Process.myPid();
        int optionalUid = mIntent.getIntExtra(Constant.UID, 0);

        Log.d(LOG_TAG, "======joinChannel info======");
        Log.d(LOG_TAG, "accessToken  : " + accessToken);
        Log.d(LOG_TAG, "channelName  : " + channelName);
        Log.d(LOG_TAG, "optionalInfo : " + optionalInfo);
        Log.d(LOG_TAG, "optionalUid  : " + optionalUid);
        Log.d(LOG_TAG, "======joinChannel info======");

        int ret = mRtcEngine.joinChannel(accessToken, channelName,
                optionalInfo, optionalUid);
        Log.d(LOG_TAG, "joinChannle ret = " + ret);
    }

    private void setUpEngine() {
        if(mRtcEngine != null){
            mRtcEngine.leaveChannel();
            RtcEngine.destroy();
            mRtcEngine = null;
        }

        String appId = mIntent.getStringExtra(Constant.APP_ID);
        try {
            mRtcEngine = RtcEngine.create(getApplicationContext(), appId, new IRtcEngineEventHandler() {
                @Override
                public void onJoinChannelSuccess(String channel, int uid, int elapsed) {
                    Log.d(LOG_TAG, "onJoinChannelSuccess " + channel + " " + elapsed);
                }

                @Override
                public void onWarning(int warn) {
                    Log.d(LOG_TAG, "onWarning " + warn);
                }

                @Override
                public void onError(int err) {
                    Log.d(LOG_TAG, "onError " + err);
                }

                @Override
                public void onRequestToken() {
                    final int N = mCallbacks.beginBroadcast();
                    for (int i = 0; i < N; i++) {
                        try {
                            mCallbacks.getBroadcastItem(i).onError(Constants.ERR_INVALID_TOKEN);
                        } catch (RemoteException e) {
                            // The RemoteCallbackList will take care of removing
                            // the dead object for us.
                        }
                    }
                    mCallbacks.finishBroadcast();
                }

                @Override
                public void onTokenPrivilegeWillExpire(String token) {
                    final int N = mCallbacks.beginBroadcast();
                    for (int i = 0; i < N; i++) {
                        try {
                            mCallbacks.getBroadcastItem(i).onTokenWillExpire();
                        } catch (RemoteException e) {
                            // The RemoteCallbackList will take care of removing
                            // the dead object for us.
                        }
                    }
                    mCallbacks.finishBroadcast();
                }

                @Override
                public void onConnectionStateChanged(int state, int reason) {
                    switch (state) {
                        case Constants.CONNECTION_STATE_FAILED :
                            final int N = mCallbacks.beginBroadcast();
                            for (int i = 0; i < N; i++) {
                                try {
                                    mCallbacks.getBroadcastItem(i).onError(Constants.CONNECTION_STATE_FAILED);
                                } catch (RemoteException e) {
                                    // The RemoteCallbackList will take care of removing
                                    // the dead object for us.
                                }
                            }
                            mCallbacks.finishBroadcast();
                            break;
                        default :
                            break;
                    }
                }
            });
        } catch (Exception e) {
            Log.e(LOG_TAG, Log.getStackTraceString(e));

            throw new RuntimeException("NEED TO check rtc sdk init fatal error\n" + Log.getStackTraceString(e));
        }

        mRtcEngine.setLogFile("/sdcard/ss_svr.log");
        mRtcEngine.setChannelProfile(Constants.CHANNEL_PROFILE_LIVE_BROADCASTING);
        mRtcEngine.enableVideo();

        if (mRtcEngine.isTextureEncodeSupported()) {
            mSCS = new ScreenCaptureSource();
            int ret = mRtcEngine.setVideoSource(mSCS);
            Log.e(LOG_TAG, "setVideoSource ret = "+ ret);
        } else {
            throw new RuntimeException("Can not work on device do not supporting texture" + mRtcEngine.isTextureEncodeSupported());
        }

        mRtcEngine.setClientRole(Constants.CLIENT_ROLE_BROADCASTER);

        mRtcEngine.muteAllRemoteAudioStreams(true);
        mRtcEngine.muteAllRemoteVideoStreams(true);
        mRtcEngine.disableAudio();
    }

    private void setUpVideoConfig() {
        int width = mIntent.getIntExtra(Constant.WIDTH, 0);
        int height = mIntent.getIntExtra(Constant.HEIGHT, 0);
        int frameRate = mIntent.getIntExtra(Constant.FRAME_RATE, 15);
        int bitRate = mIntent.getIntExtra(Constant.BITRATE, 0);
        int orientationMode = mIntent.getIntExtra(Constant.ORIENTATION_MODE, 0);
        VideoEncoderConfiguration.FRAME_RATE fr;
        VideoEncoderConfiguration.ORIENTATION_MODE om;

        switch (frameRate) {
            case 1 :
                fr = VideoEncoderConfiguration.FRAME_RATE.FRAME_RATE_FPS_1;
                break;
            case 7 :
                fr = VideoEncoderConfiguration.FRAME_RATE.FRAME_RATE_FPS_7;
                break;
            case 10 :
                fr = VideoEncoderConfiguration.FRAME_RATE.FRAME_RATE_FPS_10;
                break;
            case 15 :
                fr = VideoEncoderConfiguration.FRAME_RATE.FRAME_RATE_FPS_15;
                break;
            case 24 :
                fr = VideoEncoderConfiguration.FRAME_RATE.FRAME_RATE_FPS_24;
                break;
            case 30 :
                fr = VideoEncoderConfiguration.FRAME_RATE.FRAME_RATE_FPS_30;
                break;
            default :
                fr = VideoEncoderConfiguration.FRAME_RATE.FRAME_RATE_FPS_15;
                break;
        }

        switch (orientationMode) {
            case 1 :
                om = VideoEncoderConfiguration.ORIENTATION_MODE.ORIENTATION_MODE_FIXED_LANDSCAPE;
                break;
            case 2 :
                om = VideoEncoderConfiguration.ORIENTATION_MODE.ORIENTATION_MODE_FIXED_PORTRAIT;
                break;
            default :
                om = VideoEncoderConfiguration.ORIENTATION_MODE.ORIENTATION_MODE_ADAPTIVE;
                break;
        }

        Log.d(LOG_TAG, "setUpVideoConfig encode width=" + width + ",height=" + height);

        mRtcEngine.setVideoEncoderConfiguration(new VideoEncoderConfiguration(
                new VideoEncoderConfiguration.VideoDimensions(width, height), fr, bitRate, om));

        mScreenCapture.setOutSize(height, width);
    }
}
