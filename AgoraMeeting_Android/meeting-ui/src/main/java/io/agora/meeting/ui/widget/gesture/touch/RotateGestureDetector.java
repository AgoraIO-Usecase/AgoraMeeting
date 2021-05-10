package io.agora.meeting.ui.widget.gesture.touch;

import android.view.MotionEvent;

/**
 * 双指手势旋转识别
 * <p>
 *
 * @author yinxuming
 * @date 2020/12/22
 */
public class RotateGestureDetector {
    private OnRotateGestureListener mRotateGestureListener;
    private boolean mIsRotate = false;
    private float mLastDegrees;


    public boolean onTouchEvent(MotionEvent event) {
        if (event.getPointerCount() != 2) {
            mIsRotate = false;
            return false;
        }
        float pivotX = (event.getX(0) + event.getX(1)) / 2;
        float pivotY = (event.getY(0) + event.getY(1)) / 2;
        float deltaX = event.getX(0) - event.getX(1);
        float deltaY = event.getY(0) - event.getY(1);
        float degrees = (float) Math.toDegrees(Math.atan2(deltaY, deltaX)); // 当前双指连线夹角
        switch (event.getActionMasked()) {
            case MotionEvent.ACTION_DOWN:
            case MotionEvent.ACTION_POINTER_DOWN:
                mLastDegrees = degrees;
                mIsRotate = false;
                break;
            case MotionEvent.ACTION_MOVE:
                if (!mIsRotate) {
                    mIsRotate = true;
                    notifyRotateBegin();
                }
                // 计算本次旋转角度
                float diffDegree = degrees - mLastDegrees;  // 旋转角度 = 当前双指夹角 - 上次双指夹角。结果大于0 顺时针旋转；小于0逆时针旋转
                if (diffDegree > 45) {  // y/x 分母微小抖动带来的角度剧烈变化，修正
                    diffDegree = -5;
                } else if (diffDegree < -45) {
                    diffDegree = 5;
                }
                notifyRotate(diffDegree, pivotX, pivotY);
                mLastDegrees = degrees;
                break;
            case MotionEvent.ACTION_POINTER_UP:
            case MotionEvent.ACTION_CANCEL:
                mLastDegrees = 0;
                mIsRotate = false;
                notifyRotateEnd();
                break;
        }

        return true;
    }

    private void notifyRotateBegin() {
        if (mRotateGestureListener != null) {
            mRotateGestureListener.onRotateBegin(this);
        }
    }

    private void notifyRotate(float diffDegree, float pivotX, float pivotY) {
        if (mRotateGestureListener != null) {
            mRotateGestureListener.onRotate(this, diffDegree, pivotX, pivotY);
        }
    }

    private void notifyRotateEnd() {
        if (mRotateGestureListener != null) {
            mRotateGestureListener.onRotateEnd(this);
        }
    }

    public void setRotateGestureListener(OnRotateGestureListener rotateGestureListener) {
        mRotateGestureListener = rotateGestureListener;
    }

    public interface OnRotateGestureListener {
        boolean onRotateBegin(RotateGestureDetector detector);

        boolean onRotate(RotateGestureDetector detector, float degrees, float px, float py);

        void onRotateEnd(RotateGestureDetector detector);
    }

    public static class SimpleOnRotateGestureListener implements OnRotateGestureListener {

        @Override
        public boolean onRotateBegin(RotateGestureDetector detector) {
            return false;
        }

        @Override
        public boolean onRotate(RotateGestureDetector detector, float degrees, float px, float py) {
            return false;
        }


        @Override
        public void onRotateEnd(RotateGestureDetector detector) {

        }
    }

}
