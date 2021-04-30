package io.agora.rtc.ss.impl;

import android.graphics.SurfaceTexture;
import android.view.Surface;

import java.util.Locale;

import io.agora.rtc.ss.gles.FullFrameRect;
import io.agora.rtc.ss.gles.GLRender;
import io.agora.rtc.ss.gles.ImgTexFormat;
import io.agora.rtc.ss.gles.ImgTexFrame;
import io.agora.rtc.ss.gles.SrcConnector;
import io.agora.rtc.ss.gles.Texture2dProgram;
import io.agora.rtc.ss.utils.Logger;

/**
 * Description:
 *
 *
 * @since 2/5/21
 */
public class SurfaceExporter implements SurfaceTexture.OnFrameAvailableListener {
    private static final String LOG_TAG = "SurfaceExporter";

    private final static boolean TRACE = false;
    // Performance trace
    private long mLastTraceTime;
    private long mFrameDrawed;

    private final GLRender glRender;
    private GetSurfaceCallback getSurfaceCallback;

    private FullFrameRect mTexFrameRect;

    private int mWidth, mHeight;
    private int mTextureId;
    private SurfaceTexture mSurfaceTexture;
    private Surface mSurface;

    private volatile boolean mTexInited;
    private ImgTexFormat mImgTexFormat;

    public SrcConnector<ImgTexFrame> mImgTexSrcConnector;


    public SurfaceExporter(GLRender glRender) {
        this.glRender = glRender;
        this.glRender.addListener(new GLRender.GLRenderListener() {
            @Override
            public void onReady() {

            }

            @Override
            public void onSizeChanged(int width, int height) {
            }

            @Override
            public void onDrawFrame() {
                // 输出纹理数据
                long pts = System.nanoTime() / 1000 / 1000;
                try {
                    mSurfaceTexture.updateTexImage();
                } catch (Exception e) {
                    Logger.e(LOG_TAG, "updateTexImage failed, ignore");
                    return;
                }

                if (!mTexInited) {
                    mTexInited = true;
                    initTexFormat();
                }

                float[] texMatrix = new float[16];
                mSurfaceTexture.getTransformMatrix(texMatrix);

                ImgTexFrame frame = new ImgTexFrame(mImgTexFormat, mTextureId, texMatrix, pts);

                final ImgTexFrame _frame = frame;
                try {
                    mImgTexSrcConnector.onFrameAvailable(_frame);
                } catch (Exception e) {
                    Logger.e(LOG_TAG, "Draw frame failed, ignore: " + e.toString());
                }

                if (TRACE) {
                    mFrameDrawed++;
                    long tm = System.currentTimeMillis();
                    long tmDiff = tm - mLastTraceTime;
                    if (tmDiff >= 5000) {
                        float fps = mFrameDrawed * 1000.f / tmDiff;
                        Logger.d(LOG_TAG, "surface export fps: " + String.format(Locale.getDefault(), "%.2f", fps));
                        mFrameDrawed = 0;
                        mLastTraceTime = tm;
                    }
                }

            }

            @Override
            public void onReleased() {
                if (mTexFrameRect != null) {
                    mTexFrameRect.release(false);
                    mTexFrameRect = null;
                }
            }
        });
        mImgTexSrcConnector = new SrcConnector<>();
    }


    private void initTexFormat() {
        mImgTexFormat = new ImgTexFormat(ImgTexFormat.COLOR_FORMAT_EXTERNAL_OES, mWidth, mHeight);
        mImgTexSrcConnector.onFormatChanged(mImgTexFormat);
    }

    public void update(int width, int height) {
        if (width == mWidth && height == mHeight) {
            return;
        }
        mWidth = width;
        mHeight = height;
        // 生成一个Surface
        glRender.queueEvent(new Runnable() {
            @Override
            public void run() {
                if (mTexFrameRect == null) {
                    mTexFrameRect = new FullFrameRect(new Texture2dProgram(Texture2dProgram.ProgramType.TEXTURE_EXT));
                }
                if (mSurfaceTexture != null) {
                    mSurfaceTexture.release();
                }
                if (mSurface != null) {
                    mSurface.release();
                }

                mTextureId = mTexFrameRect.createTextureObject();
                mSurfaceTexture = new SurfaceTexture(mTextureId);
                mSurfaceTexture.setDefaultBufferSize(mWidth, mHeight);
                mSurface = new Surface(mSurfaceTexture);

                mSurfaceTexture.setOnFrameAvailableListener(SurfaceExporter.this);

                if (getSurfaceCallback != null) {
                    getSurfaceCallback.onSurfaceObtained(mSurface, mWidth, mHeight);
                }
            }
        });
    }

    public void getSurface(GetSurfaceCallback getSurfaceCallback) {
        if (mSurface != null) {
            getSurfaceCallback.onSurfaceObtained(mSurface, mWidth, mHeight);
        } else {
            this.getSurfaceCallback = getSurfaceCallback;
        }
    }

    @Override
    public void onFrameAvailable(SurfaceTexture surfaceTexture) {
        glRender.requestRender();
    }

    public void release() {
        if (mSurfaceTexture != null) {
            mSurfaceTexture.release();
            mSurfaceTexture = null;
        }
        if (mSurface != null) {
            mSurface.release();
            mSurface = null;
        }
        getSurfaceCallback = null;
    }


    public interface GetSurfaceCallback {
        void onSurfaceObtained(Surface surface, int width, int height);
    }

}
