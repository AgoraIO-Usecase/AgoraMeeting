package io.agora.rtc.ss.gles;

import io.agora.rtc.video.AgoraVideoFrame;

public class ImgTexFormat {
    public static final int COLOR_FORMAT_EXTERNAL_2D = AgoraVideoFrame.FORMAT_TEXTURE_2D;
    public static final int COLOR_FORMAT_EXTERNAL_OES = AgoraVideoFrame.FORMAT_TEXTURE_OES;

    public final int mColorFormat;
    public final int mWidth;
    public final int mHeight;

    public ImgTexFormat(int cf, int width, int height) {
        this.mColorFormat = cf;
        this.mWidth = width;
        this.mHeight = height;
    }

    @Override
    public String toString() {
        return "ImgTexFormat{" +
                "mColorFormat=" + mColorFormat +
                ", mWidth=" + mWidth +
                ", mHeight=" + mHeight +
                '}';
    }
}
