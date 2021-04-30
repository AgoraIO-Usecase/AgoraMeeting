package io.agora.meeting.ui.widget.gesture.touch.handler;

import android.content.Context;
import android.graphics.Matrix;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;
import android.view.TextureView;
import android.view.View;
import android.widget.FrameLayout;

import io.agora.meeting.ui.widget.gesture.touch.adapter.IVideoTouchAdapter;
import io.agora.meeting.ui.widget.gesture.touch.ui.TouchScaleResetView;

/**
 * 播放器画面双指手势缩放处理：
 * 1. 双指缩放
 * 2. 双指平移
 * 3. 缩放结束后，若为缩小画面，居中动效
 * 4. 缩放结束后，若为放大画面，自动吸附屏幕边缘动效
 * 5. 暂停播放下，实时更新缩放画面
 * MyApplication/touchEvent_01/src/main/java/cn/yinxm/tevent/gesture/imgview/PinchImageView.java
 */
public class VideoTouchScaleHandler implements IVideoTouchHandler, ScaleGestureDetector.OnScaleGestureListener {
    private Context mContext;
    public FrameLayout mContainer;
    protected boolean mTouchReset;
    private boolean openScaleTouch = true; // 开启缩放
    private boolean mIsScaleTouch;
    private float mStartCenterX, mStartCenterY, mLastCenterX, mLastCenterY, centerX, centerY;
    private float mStartSpan, mLastSpan, mCurrentSpan;
    private float mScale = 1.0f;
    private float mMinScale = 0.3F, mMaxScale = 3F;

    IVideoTouchAdapter mTouchAdapter;
    TouchScaleResetView mScaleRestView;

    public VideoTouchScaleHandler(Context context, FrameLayout container,
                                  IVideoTouchAdapter videoTouchAdapter) {
        mContext = context;
        mContainer = container;
        mTouchAdapter = videoTouchAdapter;
        initView();
    }

    private void initView() {
        mScaleRestView = new TouchScaleResetView(mContext, mContainer) {
            @Override
            public void clickResetScale() {
                mScaleRestView.setVisibility(View.GONE);
                if (isInScaleOrRotateStatus()) {
                    cancelScale();
                }
            }
        };
    }

    private Context getContext() {
        return mContext;
    }

    @Override
    public boolean onScale(ScaleGestureDetector detector) {
        if (mIsScaleTouch && openScaleTouch) {
            mCurrentSpan = detector.getCurrentSpan();
            centerX = detector.getFocusX();
            centerY = detector.getFocusY();
            if (processOnScale(detector)) {
                mLastCenterX = centerX;
                mLastCenterY = centerY;
                mLastSpan = mCurrentSpan;
            }
        }

        return false;
    }

    @Override
    public boolean onScaleBegin(ScaleGestureDetector detector) {
        if (isTextureViewValid()) {
            mTouchAdapter.getVideoTouchEndAnim().endPrevAnim();
            mIsScaleTouch = true;
        }
        mStartCenterX = detector.getFocusX();
        mStartCenterY = detector.getFocusY();
        mStartSpan = detector.getCurrentSpan();

        mLastCenterX = mStartCenterX;
        mLastCenterY = mStartCenterY;
        mLastSpan = mStartSpan;
        return true;
    }

    @Override
    public void onScaleEnd(ScaleGestureDetector detector) {
        if (mIsScaleTouch) { // 取消多手势操作
            mIsScaleTouch = false;
            mTouchReset = true;
            mTouchAdapter.getVideoTouchEndAnim().setEndAnimScale(mScale);
        }
    }

    public void cancelScale() {
        mIsScaleTouch = false;
        mScale = 1.0f;
        mTouchAdapter.getVideoRotateHandler().cancelRotate();
        Matrix mScaleTransMatrix = getTransformMatrix();
        if (mScaleTransMatrix != null) {
            mScaleTransMatrix.reset();
            updateMatrixToTexture(mScaleTransMatrix);
        }
    }

    private boolean processOnScale(ScaleGestureDetector detector) {
        float diffScale = mCurrentSpan / mLastSpan;
        Matrix mScaleTransMatrix = getTransformMatrix();
        if (mTouchAdapter.isFullScreen()) {
            if (mScaleTransMatrix != null) {
                postScale(mScaleTransMatrix, diffScale, mStartCenterX, mStartCenterY);
                mScaleTransMatrix.postTranslate(detector.getFocusX() - mLastCenterX,
                        detector.getFocusY() - mLastCenterY);
                updateMatrixToTexture(mScaleTransMatrix);
                //int scaleRatio = (int) (mScale * 100);
                //Toast.makeText(getContext(), "" + scaleRatio + "%", Toast.LENGTH_SHORT).show();
                return true;
            }
        }
        return false;
    }

    private void postScale(Matrix matrix, float scale, float x, float y) {
        float curScale = mScale;
        if ((curScale - mMinScale) >= 0 && (mMaxScale - curScale) >= 0) {
            curScale *= scale;
            if ((curScale - mMinScale) < 0 || (mMaxScale - curScale) < 0) {
                return;
            }
            mScale = curScale;
            matrix.postScale(scale, scale, x, y);
        }
    }


    private void updateMatrixToTexture(Matrix newMatrix) {
        if (isTextureViewValid()) {
            TextureView textureView = mTouchAdapter.getTextureView();
            textureView.setTransform(newMatrix);
            if (!mTouchAdapter.isPlaying()) {
                textureView.invalidate();
            }
        }
    }

    public void showScaleReset() {
        if (isScaled() && mTouchAdapter != null && mTouchAdapter.isFullScreen()) {
            if (mScaleRestView != null && mScaleRestView.getVisibility() != View.VISIBLE) {
                mScaleRestView.setVisibility(View.VISIBLE);
            }
        }
    }

    public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {
        // TODO: 2020/11/29 缩放模式下，是否需要单手滚动
//        if (isScaled(mScale) && mScaleTransMatrix != null) {
//            TextureView mTextureView = mTouchAdapter.getTextureView();
//            if (mTextureView != null) {
//                postTranslate(mScaleTransMatrix, -distanceX, -distanceY);
//                onScaleMatrixUpdate(mScaleTransMatrix);
//                Matrix matrix = new Matrix(mTextureView.getMatrix());
//                matrix.set(mScaleTransMatrix);
//                mTextureView.setTransform(matrix);
//                return true;
//            }
//        }
        return false;
    }

    public boolean isInScaleOrRotateStatus() {
        return isInScaleStatus() || mTouchAdapter.getVideoRotateHandler().isRotated();
    }

    /**
     * 是否处于已缩放 or 缩放中
     *
     * @return
     */
    public boolean isInScaleStatus() {
        return isScaled(mScale) || mIsScaleTouch;
    }

    public boolean isScaled() {
        return isScaled(mScale);
    }

    private boolean isScaled(float scale) {
        return scale > 0 && scale <= 0.99F || scale >= 1.01F;
    }

    private boolean isTextureViewValid() {
        return mTouchAdapter.getTextureView() != null && mTouchAdapter.getTextureView().isAvailable();
    }

    private Matrix getTransformMatrix() {
        if (isTextureViewValid()) {
            return mTouchAdapter.getTextureView().getTransform(null);
        }
        return null;
    }
}
