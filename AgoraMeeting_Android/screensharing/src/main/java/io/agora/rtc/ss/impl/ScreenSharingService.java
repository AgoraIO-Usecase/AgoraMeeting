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

import java.lang.ref.WeakReference;

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

    private final InnerBinder mBinder = new InnerBinder(new WeakReference(this));

    private GLRender mGLRender;
    private ScreenSender mScreenSender;
    private SurfaceExporter mSurfaceExporter;

    private void refreshToken(String token) {
        if (mScreenSender != null) {
            mScreenSender.renewToken(token);
        }
    }

    private void startCapture(){
        mScreenCaptureSvc.execOnce(new SimpleSafeData.Callback<IScreenCapture>() {
            @Override
            public void run(IScreenCapture data) {
                try {
                    data.startCapture();
                } catch (RemoteException e) {
                    Logger.e(LOG_TAG, "mScreenCaptureSvc startCapture error : " + e.toString());
                }
            }
        });
    }

    private void stopCapture(){
        mScreenCaptureSvc.execOnce(new SimpleSafeData.Callback<IScreenCapture>() {
            @Override
            public void run(IScreenCapture data) {
                try {
                    data.stopCapture();
                } catch (RemoteException e) {
                    Logger.e(LOG_TAG, "mScreenCaptureSvc stopCapture error : " + e.toString());
                }
            }
        });
    }

    @Override
    public void onCreate() {
        Logger.init(getApplicationContext(), "ScreenSharing");
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
            mGLRender.update(encodeWidth, encodeHeight);
        }
        if(mScreenSender != null){
            mScreenSender.setup(intent);
        }
        if(mSurfaceExporter != null){
            mSurfaceExporter.update(encodeWidth, encodeHeight);
            mSurfaceExporter.getSurface(new SurfaceExporter.GetSurfaceCallback() {
                @Override
                public void onSurfaceObtained(final Surface surface, final int width, final int height) {
                    mScreenCaptureSvc.execOnce(new SimpleSafeData.Callback<IScreenCapture>() {
                        @Override
                        public void run(IScreenCapture data) {
                            try {
                                data.setOutput(surface, width, height);
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
        if(mScreenCaptureSvc.getData() != null){
            try {
                getApplicationContext().unbindService(mScreenCaptureConn);
            } catch (Exception e) {
                Logger.e(LOG_TAG, e.toString());
            }
            mScreenCaptureSvc.clean();
        }
    }


    private static class InnerBinder extends IScreenSharing.Stub{
        private final WeakReference<ScreenSharingService> wref;

        InnerBinder(WeakReference<ScreenSharingService> wref){
            this.wref = wref;
        }

        @Override
        public void registerCallback(INotification callback) throws RemoteException {
            if (callback != null){
                ScreenSharingService service = wref.get();
                if(service != null){
                    service.mCallbacks.register(callback);
                }
            }
        }

        @Override
        public void unregisterCallback(INotification callback) throws RemoteException {
            if (callback != null){
                ScreenSharingService service = wref.get();
                if(service != null){
                    service.mCallbacks.unregister(callback);
                }
            }
        }

        @Override
        public void startShare() throws RemoteException {
            ScreenSharingService service = wref.get();
            if(service != null){
                service.startCapture();
            }
        }

        @Override
        public void stopShare() throws RemoteException {
            ScreenSharingService service = wref.get();
            if(service != null){
                service.stopCapture();
            }
        }

        @Override
        public void renewToken(String token) throws RemoteException {
            ScreenSharingService service = wref.get();
            if(service != null){
                service.refreshToken(token);
            }
        }
    }



}
