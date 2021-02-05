package io.agora.rtc.ss.impl;

import android.app.Service;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.IBinder;
import android.os.RemoteCallbackList;
import android.os.RemoteException;
import android.view.Surface;

import io.agora.rtc.Constants;
import io.agora.rtc.ss.Constant;
import io.agora.rtc.ss.aidl.INotification;
import io.agora.rtc.ss.aidl.IScreenCapture;
import io.agora.rtc.ss.aidl.IScreenSharing;
import io.agora.rtc.ss.gles.GLRender;
import io.agora.rtc.ss.gles.ImgTexFrame;
import io.agora.rtc.ss.gles.SinkConnector;
import io.agora.rtc.ss.utils.Logger;
import io.agora.rtc.ss.utils.SimpleSafeData;

public class ScreenSharingService extends Service {

    private static final String LOG_TAG = ScreenSharingService.class.getSimpleName();

    private SimpleSafeData<IScreenCapture> mScreenCaptureSvc = new SimpleSafeData<>();

    private ServiceConnection mScreenCaptureConn = new ServiceConnection() {
        public void onServiceConnected(ComponentName className, IBinder service) {
            mScreenCaptureSvc.setData(IScreenCapture.Stub.asInterface(service));
        }

        public void onServiceDisconnected(ComponentName className) {
            mScreenCaptureSvc.clean();
        }
    };

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

    private GLRender mGLRender;
    private ScreenSender mScreenSender;
    private SurfaceExporter mSurfaceExporter;

    private void refreshToken(String token) {
        if (mScreenSender != null) {
            mScreenSender.renewToken(token);
        }
    }

    private void startCapture(){
        mScreenCaptureSvc.exec(new Runnable() {
            @Override
            public void run() {
                try {
                    mScreenCaptureSvc.getData().startCapture();
                } catch (RemoteException e) {
                    Logger.e(LOG_TAG, "mScreenCaptureSvc startCapture error : " + e.toString());
                }
            }
        });
    }

    private void stopCapture(){
        mScreenCaptureSvc.exec(new Runnable() {
            @Override
            public void run() {
                try {
                    mScreenCaptureSvc.getData().stopCapture();
                } catch (RemoteException e) {
                    Logger.e(LOG_TAG, "mScreenCaptureSvc stopCapture error : " + e.toString());
                }
            }
        });
    }

    @Override
    public void onCreate() {
        initModules();
    }

    @Override
    public IBinder onBind(Intent intent) {
        initialize(intent);
        return mBinder;
    }

    @Override
    public boolean onUnbind(Intent intent) {
        if(mScreenSender != null){
            mScreenSender.release();
        }
        return super.onUnbind(intent);
    }

    private void initialize(Intent intent) {
        int encodeWidth = intent.getIntExtra(Constant.WIDTH, 0);
        int encodeHeight = intent.getIntExtra(Constant.HEIGHT, 0);

        if(mGLRender != null){
            mGLRender.update(encodeHeight, encodeWidth);
        }
        if(mScreenSender != null){
            mScreenSender.setup(intent);
        }
        if(mSurfaceExporter != null){
            mSurfaceExporter.update(encodeHeight, encodeWidth);
            mSurfaceExporter.getSurface(new SurfaceExporter.GetSurfaceCallback() {
                @Override
                public void onSurfaceObtained(final Surface surface, final int width, final int height) {
                    mScreenCaptureSvc.exec(new Runnable() {
                        @Override
                        public void run() {
                            try {
                                mScreenCaptureSvc.getData().setOutput(surface, width, height);
                            } catch (RemoteException e) {
                                Logger.e(LOG_TAG, "mScreenCaptureSvc setOutput error : " + e.toString());
                            }
                        }
                    });
                }
            });
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        deInitModules();
    }


    private void initModules() {
        Context context = getApplicationContext();
        if(mScreenCaptureSvc.getData() == null){
            Intent intent = new Intent(context, ScreenCaptureService.class);
            context.bindService(intent, mScreenCaptureConn, Context.BIND_AUTO_CREATE);
        }

        if(mGLRender == null){
            mGLRender = new GLRender();
            mGLRender.init(0, 0);
        }

        if(mScreenSender == null){
            mScreenSender = new ScreenSender(context);
        }
        mScreenSender.setSetupListener(new ScreenSender.SetupListener() {
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

        if(mSurfaceExporter == null){
            mSurfaceExporter = new SurfaceExporter(mGLRender);
        }
        mSurfaceExporter.mImgTexSrcConnector.connect(new SinkConnector<ImgTexFrame>() {
            @Override
            public void onFormatChanged(Object format) {

            }

            @Override
            public void onFrameAvailable(ImgTexFrame frame) {
                mScreenSender.consumeAVFrame(frame);
            }
        });

    }

    private void deInitModules() {
        if(mGLRender != null){
            mGLRender.quit();
            mGLRender = null;
        }
        if(mScreenSender != null){
            mScreenSender.release();
            mScreenSender = null;
        }
        if(mSurfaceExporter != null){
            mSurfaceExporter.release();
            mSurfaceExporter = null;
        }
    }






}
