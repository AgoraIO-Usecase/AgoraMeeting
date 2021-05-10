package io.agora.meeting.ui.widget.gesture.touch.adapter;

import android.view.TextureView;

import io.agora.meeting.ui.widget.gesture.touch.anim.IVideoTouchEndAnim;
import io.agora.meeting.ui.widget.gesture.touch.handler.IVideoRotateHandler;


/**
 * 播放器手势触摸适配，兼容HkBaseVideoView升级到新播放器BaseVideoPlayer
 * <p>
 *
 * @author yinxuming
 * @date 2020/5/18
 */
public class GestureVideoTouchAdapterImpl implements IVideoTouchAdapter {
    private IVideoRotateHandler mRotateHandler;
    private IVideoTouchEndAnim mTouchEndAnim;
    TextureView mTextureView;

    public GestureVideoTouchAdapterImpl(TextureView textureView) {
        mTextureView = textureView;
    }


    @Override
    public IVideoTouchEndAnim getVideoTouchEndAnim() {
        return mTouchEndAnim;
    }

    @Override
    public IVideoRotateHandler getVideoRotateHandler() {
        return mRotateHandler;
    }

    @Override
    public TextureView getTextureView() {
        return mTextureView;
    }

    @Override
    public boolean isPlaying() {
        return true;
    }


    @Override
    public boolean isFullScreen() {
        return false;
    }

    public void setTouchEndAnim(IVideoTouchEndAnim touchEndAnim) {
        mTouchEndAnim = touchEndAnim;
    }

    public void setVideoRotateHandler(IVideoRotateHandler rotateHandler) {
        mRotateHandler = rotateHandler;
    }
}
