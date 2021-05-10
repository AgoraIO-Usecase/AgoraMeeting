package io.agora.meeting.ui.widget.gesture;

import android.content.Context;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;
import android.view.View;
import android.view.ViewParent;
import android.widget.FrameLayout;

import io.agora.meeting.core.log.Logger;
import io.agora.meeting.ui.widget.gesture.touch.RotateGestureDetector;
import io.agora.meeting.ui.widget.gesture.touch.adapter.GestureVideoTouchAdapterImpl;
import io.agora.meeting.ui.widget.gesture.touch.adapter.IVideoTouchAdapter;
import io.agora.meeting.ui.widget.gesture.touch.anim.VideoTouchFixEndAnim;
import io.agora.meeting.ui.widget.gesture.touch.handler.VideoTouchRotateHandler;
import io.agora.meeting.ui.widget.gesture.touch.handler.VideoTouchScaleHandler;


/**
 * 手势处理layer层
 */
public final class GestureLayer implements IGestureLayer, GestureDetector.OnGestureListener,
        GestureDetector.OnDoubleTapListener {

    private Context mContext;
    private FrameLayout mContainer;

    /** 手势检测 */
    private GestureDetector mGestureDetector;

    /** 手势缩放 检测 */
    private ScaleGestureDetector mScaleGestureDetector;
    /** 手势缩放 处理 */
    private VideoTouchScaleHandler mScaleHandler;
    /**
     * 手势旋转 检测
     */
    private RotateGestureDetector mRotateGestureDetector;
    /**
     * 手势旋转 处理
     */
    private VideoTouchRotateHandler mRotateHandler;

    private IVideoTouchAdapter mVideoTouchAdapter;

    public GestureLayer(Context context, IVideoTouchAdapter videoTouchAdapter) {
        mContext = context;
        mVideoTouchAdapter = videoTouchAdapter;
        initContainer();
        initTouchHandler();
    }

    @Override
    public FrameLayout getContainer() {
        return mContainer;
    }

    protected Context getContext() {
        return mContext;
    }

    private void initContainer() {
        mContainer = new FrameLayout(mContext) {
            @Override
            public boolean dispatchTouchEvent(MotionEvent ev) {
                return super.dispatchTouchEvent(ev);
            }

            @Override
            public boolean onInterceptTouchEvent(MotionEvent ev) {
                return super.onInterceptTouchEvent(ev);
            }

            @Override
            public boolean onTouchEvent(MotionEvent event) {
                boolean isConsume =  ensureHasEvent(this, onGestureTouchEvent(event));
                if (isConsume) {
                    return true;
                } else {
                    return super.onTouchEvent(event);
                }
            }
        };
    }

    public void resetLayout(){
        if(mScaleHandler != null){
            mScaleHandler.cancelScale();
        }
    }

    public void initTouchHandler() {
        mGestureDetector = new GestureDetector(mContext, this);
        mGestureDetector.setOnDoubleTapListener(this);

        // 缩放 处理
        mScaleHandler = new VideoTouchScaleHandler(getContext(), mContainer, mVideoTouchAdapter);
        mScaleGestureDetector = new ScaleGestureDetector(getContext(), mScaleHandler);
        // 旋转处理
        mRotateHandler = new VideoTouchRotateHandler(mVideoTouchAdapter);
        mRotateGestureDetector = new RotateGestureDetector();
        mRotateGestureDetector.setRotateGestureListener(mRotateHandler);
        // 缩放关联旋转处理
        if (mVideoTouchAdapter instanceof GestureVideoTouchAdapterImpl) {
            ((GestureVideoTouchAdapterImpl) mVideoTouchAdapter).setVideoRotateHandler(mRotateHandler);
            ((GestureVideoTouchAdapterImpl) mVideoTouchAdapter).setTouchEndAnim(new VideoTouchFixEndAnim(mVideoTouchAdapter));
        }
    }


    @Override
    public void onLayerRelease() {
        if (mGestureDetector != null) {
            mGestureDetector.setOnDoubleTapListener(null);
        }
    }


    @Override
    public boolean onGestureTouchEvent(MotionEvent event) {
        try {

            processScaleFixAnim(event);

            int pointCount = event.getPointerCount();
            Logger.d("GestureLayout", "pointCount = " + pointCount);
            if (pointCount == 1) {
                if (event.getAction() == MotionEvent.ACTION_UP && mScaleHandler.isScaled()) {
                    mScaleHandler.showScaleReset();
                }
                if(event.getAction() == MotionEvent.ACTION_MOVE){
                    return false;
                }
            }
            if (pointCount > 1) {
                boolean isConsume = mScaleGestureDetector.onTouchEvent(event);
                mRotateGestureDetector.onTouchEvent(event);
                if (isConsume) {
                    return true;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return true;
    }

    private boolean ensureHasEvent(View view, boolean intercept){
        ViewParent parent = view.getParent();
        if (parent == null) return false;
        parent.requestDisallowInterceptTouchEvent(intercept);
        return true;
    }

    private void processScaleFixAnim(MotionEvent event) {
        if (event.getAction() == MotionEvent.ACTION_UP || event.getAction() == MotionEvent.ACTION_CANCEL) {
            if (mScaleHandler.isScaled() || mRotateHandler.isRotated()) {
                mVideoTouchAdapter.getVideoTouchEndAnim().startAnim();
            }
        }
    }

    @Override
    public boolean onSingleTapConfirmed(MotionEvent e) {
        return onSingleTap(e);
    }

    /**
     * 单击事件处理
     *
     * @param event 触摸事件
     */
    private boolean onSingleTap(MotionEvent event) {
        // 如果有全屏时的锁屏逻辑，需要在这里判断
        touchEvent(event);
        return true;
    }

    private void touchEvent(MotionEvent event) {
        mContainer.setVisibility(View.VISIBLE);
        if (event.getAction() == MotionEvent.ACTION_DOWN) {
            // sendEvent touch
        }
    }

    @Override
    public boolean onDoubleTap(MotionEvent e) {
        return true;
    }

    @Override
    public boolean onDoubleTapEvent(MotionEvent e) {
        return false;
    }

    @Override
    public boolean onDown(MotionEvent e) {
        return false;
    }

    @Override
    public void onShowPress(MotionEvent e) {

    }

    @Override
    public boolean onSingleTapUp(MotionEvent e) {
        return false;
    }

    @Override
    public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {
        if (mScaleHandler.isInScaleStatus()) {
            return mScaleHandler.onScroll(e1, e2, distanceX, distanceY);
        }
        return false;
    }

    @Override
    public void onLongPress(MotionEvent e) {
    }

    @Override
    public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX,
                           float velocityY) {
        return false;
    }

}
