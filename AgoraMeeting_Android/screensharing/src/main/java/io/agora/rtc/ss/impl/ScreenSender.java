package io.agora.rtc.ss.impl;

import android.content.Context;
import android.content.Intent;
import android.os.Process;
import android.util.Log;

import io.agora.rtc.Constants;
import io.agora.rtc.IRtcEngineEventHandler;
import io.agora.rtc.RtcEngine;
import io.agora.rtc.mediaio.IVideoFrameConsumer;
import io.agora.rtc.mediaio.IVideoSource;
import io.agora.rtc.mediaio.MediaIO;
import io.agora.rtc.ss.Constant;
import io.agora.rtc.ss.gles.ImgTexFrame;
import io.agora.rtc.ss.utils.Logger;
import io.agora.rtc.video.AgoraVideoFrame;
import io.agora.rtc.video.VideoEncoderConfiguration;

/**
 * Description:
 *
 *
 * @since 2/5/21
 */
public class ScreenSender {
    private static final String LOG_TAG = "ScreenSender";

    private RtcEngine mRtcEngine;
    private ScreenCaptureSource mSCS;
    private Context context;
    private Intent mIntent;
    private SetupListener setupListener;


    public ScreenSender(Context context){
        this.context = context;
    }

    public void setSetupListener(SetupListener setupListener){
        this.setupListener = setupListener;
    }

    public void renewToken(String token){
        if (mRtcEngine != null) {
            mRtcEngine.renewToken(token);
        } else {
            Logger.e(LOG_TAG, "rtc engine is null");
        }
    }

    public void setup(Intent intent){
        mIntent = intent;
        setUpEngine();
        setUpVideoConfig();
        joinChannel();
    }

    public void consumeAVFrame(ImgTexFrame texFrame){
        if(mSCS!= null && mSCS.getConsumer() != null){
            mSCS.getConsumer().consumeTextureFrame(texFrame.mTextureId, texFrame.mFormat.mColorFormat,
                    texFrame.mFormat.mWidth, texFrame.mFormat.mHeight, 0, System.currentTimeMillis(), texFrame.mTexMatrix);
        }
    }


    private void setUpEngine() {
        if(mRtcEngine != null){
            mRtcEngine.leaveChannel();
            RtcEngine.destroy();
            mRtcEngine = null;
        }

        String appId = mIntent.getStringExtra(Constant.APP_ID);
        try {
            mRtcEngine = RtcEngine.create(context, appId, new IRtcEngineEventHandler() {
                @Override
                public void onJoinChannelSuccess(String channel, int uid, int elapsed) {
                    Logger.d(LOG_TAG, "onJoinChannelSuccess " + channel + " " + elapsed);
                }

                @Override
                public void onWarning(int warn) {
                    Logger.d(LOG_TAG, "onWarning " + warn);
                }

                @Override
                public void onError(int err) {
                    Logger.d(LOG_TAG, "onError " + err);
                }

                @Override
                public void onRequestToken() {
                    if(setupListener != null){
                        setupListener.onRequestToken();
                    }
                }

                @Override
                public void onTokenPrivilegeWillExpire(String token) {
                    if(setupListener != null){
                        setupListener.onTokenPrivilegeWillExpire(token);
                    }
                }

                @Override
                public void onConnectionStateChanged(int state, int reason) {
                    if(setupListener != null){
                        setupListener.onConnectionStateChanged(state, reason);
                    }
                }
            });
        } catch (Exception e) {
            Logger.e(LOG_TAG, Log.getStackTraceString(e));

            throw new RuntimeException("NEED TO check rtc sdk init fatal error\n" + Log.getStackTraceString(e));
        }

        mRtcEngine.setLogFile("/sdcard/ss_svr.log");
        mRtcEngine.setChannelProfile(Constants.CHANNEL_PROFILE_LIVE_BROADCASTING);
        mRtcEngine.enableVideo();

        if (mRtcEngine.isTextureEncodeSupported()) {
            mSCS = new ScreenCaptureSource();
            int ret = mRtcEngine.setVideoSource(mSCS);
            Logger.e(LOG_TAG, "setVideoSource ret = "+ ret);
        } else {
            throw new RuntimeException("Can not work on device do not supporting texture" + mRtcEngine.isTextureEncodeSupported());
        }

        mRtcEngine.setClientRole(Constants.CLIENT_ROLE_BROADCASTER);

        mRtcEngine.muteAllRemoteAudioStreams(true);
        mRtcEngine.muteAllRemoteVideoStreams(true);
        mRtcEngine.disableAudio();
    }


    private void joinChannel() {
        String accessToken = mIntent.getStringExtra(Constant.ACCESS_TOKEN);
        String channelName = mIntent.getStringExtra(Constant.CHANNEL_NAME);
        String optionalInfo = "ss_" + (Process.myPid());
        int optionalUid = mIntent.getIntExtra(Constant.UID, 0);

        Logger.d("RTCENGINE", "======joinChannel info-screen share======");
        Logger.d("RTCENGINE", "accessToken  : " + accessToken);
        Logger.d("RTCENGINE", "channelName  : " + channelName);
        Logger.d("RTCENGINE", "optionalInfo : " + optionalInfo);
        Logger.d("RTCENGINE", "optionalUid  : " + optionalUid);
        Logger.d("RTCENGINE", "======joinChannel info-screen share======");

        int ret = mRtcEngine.joinChannel(accessToken, channelName,
                optionalInfo, optionalUid);
        Logger.d("RTCENGINE", "joinChannle ret = " + ret);
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

        Logger.d(LOG_TAG, "setUpVideoConfig encode width=" + width + ",height=" + height);

        mRtcEngine.setVideoEncoderConfiguration(new VideoEncoderConfiguration(
                new VideoEncoderConfiguration.VideoDimensions(width, height), fr, bitRate, om));

    }

    public void release() {
        if(mRtcEngine != null){
            mRtcEngine.leaveChannel();
            RtcEngine.destroy();
            mRtcEngine = null;
        }
    }


    public interface SetupListener{
        void onRequestToken();
        void onTokenPrivilegeWillExpire(String token);
        void onConnectionStateChanged(int state, int reason);
    }

    private static class ScreenCaptureSource implements IVideoSource {

        private IVideoFrameConsumer mConsumer;

        @Override
        public boolean onInitialize(IVideoFrameConsumer observer) {
            mConsumer = observer;
            return true;
        }

        @Override
        public int getBufferType() {
            return AgoraVideoFrame.BUFFER_TYPE_TEXTURE;
        }

        @Override
        public int getCaptureType() {
            return MediaIO.CaptureType.SCREEN.intValue();
        }

        @Override
        public int getContentHint() {
            return MediaIO.ContentHint.NONE.intValue();
        }

        @Override
        public void onDispose() {
            mConsumer = null;
        }

        @Override
        public void onStop() {
        }

        @Override
        public boolean onStart() {
            return true;
        }

        public IVideoFrameConsumer getConsumer() {
            return mConsumer;
        }

    }
}
