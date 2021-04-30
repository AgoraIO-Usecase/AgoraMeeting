package io.agora.rtc.ss.impl;

import android.opengl.EGLContext;
import android.opengl.GLES20;
import android.view.Surface;

import io.agora.rtc.ss.gles.FullFrameRect;
import io.agora.rtc.ss.gles.GLRender;
import io.agora.rtc.ss.gles.GlUtil;
import io.agora.rtc.ss.gles.ImgTexFormat;
import io.agora.rtc.ss.gles.ImgTexFrame;
import io.agora.rtc.ss.gles.Texture2dProgram;

/**
 * Description:
 *
 *
 * @since 2/5/21
 */
public class SurfaceImporter {
    private EGLContext shareCtx;
    private GLRender glRender;
    private FullFrameRect mTexFrameRect;

    public SurfaceImporter(EGLContext shareCtx) {
        this.shareCtx = shareCtx;
    }

    /**
     * 设置接收纹理数据的Surface，将通过创建一个上下文来将从ScreenCapture处接收的纹理数据传递给这个Surface
     *
     * @param surface 接收纹理数据的Surface
     * @param width   Surface中纹理的宽
     * @param height  Surface中纹理的高
     */
    public void setSurface(Surface surface, int width, int height) {
        if (glRender == null) {
            glRender = new GLRender(shareCtx);
        }
        glRender.init(surface);
        glRender.init(width, height);
        glRender.addListener(new GLRender.GLRenderListener() {
            @Override
            public void onReady() {

            }

            @Override
            public void onSizeChanged(int width, int height) {

            }

            @Override
            public void onDrawFrame() {

            }

            @Override
            public void onReleased() {
                if(mTexFrameRect != null){
                    mTexFrameRect.release(false);
                    mTexFrameRect = null;
                }
            }
        });
    }


    public void onFrameAvailable(final ImgTexFrame frame) {
        if(glRender == null){
            return;
        }
        mayInitTexFrameRect(frame.mFormat.mColorFormat);
        glRender.queueDrawFrameAppends(new Runnable() {
            @Override
            public void run() {

                //Bitmap bitmap = GlUtil.dumpBitmap(frame.mFormat.mWidth, frame.mFormat.mHeight);
                GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT | GLES20.GL_DEPTH_BUFFER_BIT | GLES20.GL_STENCIL_BUFFER_BIT);
                GLES20.glClearColor(0, 0, 0, 0);
                if(mTexFrameRect != null){
                    mTexFrameRect.drawFrame(frame.mTextureId, frame.mTexMatrix, GlUtil.IDENTITY_MATRIX);
                }
            }
        });
        glRender.requestRender();
    }

    public void release(){
        if(glRender != null){
            glRender.quit();
            glRender = null;
        }
    }

    private void mayInitTexFrameRect(final int color) {
        if (glRender == null) {
            return;
        }
        if (mTexFrameRect != null &&
                (mTexFrameRect.getProgram().getProgramType() == Texture2dProgram.ProgramType.TEXTURE_2D && color == ImgTexFormat.COLOR_FORMAT_EXTERNAL_2D
                        || mTexFrameRect.getProgram().getProgramType() == Texture2dProgram.ProgramType.TEXTURE_EXT && color == ImgTexFormat.COLOR_FORMAT_EXTERNAL_OES)) {
            return;
        }
        glRender.queueEvent(new Runnable() {
            @Override
            public void run() {
                if (mTexFrameRect != null) {
                    mTexFrameRect.changeProgram(new Texture2dProgram(
                            color == ImgTexFormat.COLOR_FORMAT_EXTERNAL_2D ? Texture2dProgram.ProgramType.TEXTURE_2D : Texture2dProgram.ProgramType.TEXTURE_EXT
                    ));
                } else {
                    mTexFrameRect = new FullFrameRect(new Texture2dProgram(
                            color == ImgTexFormat.COLOR_FORMAT_EXTERNAL_2D ? Texture2dProgram.ProgramType.TEXTURE_2D : Texture2dProgram.ProgramType.TEXTURE_EXT
                    ));
                }
            }
        });
    }


}
