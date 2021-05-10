package io.agora.rtc.ss.impl;

import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.opengl.EGLContext;
import android.os.IBinder;
import android.os.RemoteException;
import android.util.DisplayMetrics;
import android.view.Surface;
import android.view.WindowManager;

import androidx.annotation.Nullable;

import java.lang.ref.WeakReference;

import io.agora.rtc.ss.aidl.IScreenCapture;
import io.agora.rtc.ss.gles.EglCore;
import io.agora.rtc.ss.gles.GLRender;
import io.agora.rtc.ss.gles.ImgTexFrame;
import io.agora.rtc.ss.gles.SinkConnector;
import io.agora.rtc.ss.utils.Logger;
import io.agora.rtc.ss.utils.NotificationHelper;

/**
 * Description:
 *
 *
 * @since 2/4/21
 */
public class ScreenCaptureService extends Service {
    private static final String LOG_TAG = "ScreenCaptureService";


    private final InnerBinder mBinder = new InnerBinder(new WeakReference(this));
    private Context mContext;
    private GLRender mScreenGLRender;
    private ScreenCapture mScreenCapture;
    private SurfaceImporter mSurfaceImporter;

    private volatile boolean isCapturing = false;
    private EglCore rootEglCore;

    @Override
    public void onCreate() {
        super.onCreate();
        mContext = getApplicationContext();
        Logger.init(mContext, "ScreenCapture");
        initModules();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        deInitModules();
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return mBinder;
    }

    @Override
    public boolean onUnbind(Intent intent) {
        return super.onUnbind(intent);
    }

    private static class InnerBinder extends IScreenCapture.Stub{

        private final WeakReference<ScreenCaptureService> wref;

        InnerBinder(WeakReference<ScreenCaptureService> wref){
            this.wref = wref;
        }

        @Override
        public void setOutput(Surface surface, int width, int height) throws RemoteException {
            ScreenCaptureService service = wref.get();
            if(service != null){
                service.setSurfaceOutput(surface, width, height);
            }
        }

        @Override
        public void startCapture() throws RemoteException {
            ScreenCaptureService service = wref.get();
            if(service != null){
                service.startCapture();
            }
        }

        @Override
        public void stopCapture() throws RemoteException {
            ScreenCaptureService service = wref.get();
            if(service != null){
                service.stopCapture();
            }
        }
    }


    private void initModules() {
        WindowManager wm = (WindowManager) mContext.getSystemService(Context.WINDOW_SERVICE);
        DisplayMetrics metrics = new DisplayMetrics();
        wm.getDefaultDisplay().getMetrics(metrics);
        int screenWidth = metrics.widthPixels;
        int screenHeight = metrics.heightPixels;
        int screenDensity = metrics.densityDpi;

        rootEglCore = new EglCore(null, 0);
        initGLRender(rootEglCore.getEGLContext());
        initScreenCapture( screenWidth, screenHeight, screenDensity);
        initSurfaceImporter(rootEglCore.getEGLContext());

        mScreenGLRender.init(screenWidth, screenHeight);
    }

    private void initGLRender(EGLContext context){
        if (mScreenGLRender == null) {
            mScreenGLRender = new GLRender(context);
        }
    }

    private void initSurfaceImporter(EGLContext context){
        if(mSurfaceImporter == null){
            mSurfaceImporter = new SurfaceImporter(context);
        }
    }

    private void initScreenCapture(int width, int height, int density) {
        if (mScreenCapture == null) {
            mScreenCapture = new ScreenCapture(mContext, mScreenGLRender, width, height, density);
        }
        mScreenCapture.mImgTexSrcConnector.connect(new SinkConnector<ImgTexFrame>() {
            @Override
            public void onFormatChanged(Object obj) {
                Logger.d(LOG_TAG, "onFormatChanged " + obj.toString());
            }

            @Override
            public void onFrameAvailable(ImgTexFrame frame) {
                //Logger.d(LOG_TAG, "onFrameAvailable " + frame.toString() + ",pts=" + frame.pts + ",width="+frame.mFormat.mWidth + ",height=" + frame.mFormat.mHeight);
                if(mSurfaceImporter != null && isCapturing){
                    mSurfaceImporter.onFrameAvailable(frame);
                }
            }
        });

        mScreenCapture.setOnScreenCaptureListener(new ScreenCapture.OnScreenCaptureListener() {
            @Override
            public void onStarted() {
                Logger.d(LOG_TAG, "Screen Record Started");
            }

            @Override
            public void onError(int err) {
                Logger.d(LOG_TAG, "onError " + err);
                switch (err) {
                    case ScreenCapture.SCREEN_ERROR_SYSTEM_UNSUPPORTED:
                        break;
                    case ScreenCapture.SCREEN_ERROR_PERMISSION_DENIED:
                        break;
                }
            }
        });
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        WindowManager wm = (WindowManager) getApplicationContext().getSystemService(Context.WINDOW_SERVICE);
        DisplayMetrics outMetrics = new DisplayMetrics();
        wm.getDefaultDisplay().getMetrics(outMetrics);
        int screenWidth = outMetrics.widthPixels;
        int screenHeight = outMetrics.heightPixels;
        Logger.d(LOG_TAG, "onConfigurationChanged " + newConfig.orientation + " " + screenWidth + " " + screenHeight);
        mScreenGLRender.update(screenWidth, screenHeight);
    }


    private void startCapture() {
        if(isCapturing){
            return;
        }
        isCapturing = true;
        startForeground(55431, NotificationHelper.getForeNotification(this));
        mScreenCapture.start();
    }


    private void stopCapture() {
        isCapturing = false;
        stopForeground(true);
        mScreenCapture.stop();
    }

    private void setSurfaceOutput(Surface surface, int width, int height){
        mScreenCapture.setOutSize(width, height);
        mSurfaceImporter.setSurface(surface, width, height);
    }

    private void deInitModules() {
        if (mScreenCapture != null) {
            mScreenCapture.release();
            mScreenCapture = null;
        }

        if (mScreenGLRender != null) {
            mScreenGLRender.quit();
            mScreenGLRender = null;
        }

        if(mSurfaceImporter != null){
            mSurfaceImporter.release();
            mSurfaceImporter = null;
        }

        if(rootEglCore != null){
            rootEglCore.release();
            rootEglCore = null;
        }
    }


}
