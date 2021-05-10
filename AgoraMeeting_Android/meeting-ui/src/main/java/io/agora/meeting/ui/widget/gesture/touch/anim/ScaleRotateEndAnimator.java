package io.agora.meeting.ui.widget.gesture.touch.anim;


import android.animation.Animator;
import android.animation.ValueAnimator;
import android.graphics.Matrix;

import androidx.annotation.CallSuper;


/**
 * 缩放动画
 * <p>
 * 在给定时间内从startMatrix变化到endMatrix，参考：
 * [PinchImageView](https://github.com/boycy815/PinchImageView/blob/master/pinchimageview/src/main/java/com/boycy815/pinchimageview/PinchImageView.java)
 *
 * @author yinxuming
 * @date 2020/12/2
 */
public abstract class ScaleRotateEndAnimator extends ValueAnimator implements ValueAnimator.AnimatorUpdateListener,
        Animator.AnimatorListener {
    private static final String TAG = "VideoScaleEndAnimator";

    /**
     * 图片缩放动画时间
     */
    public static final int SCALE_ANIMATOR_DURATION = 300;

    private Matrix mStartMatrix = new Matrix();
    private Matrix mEndMatrix = new Matrix();
    private Matrix mMatrix = new Matrix();
    private float[] mStartMatrixValue;
    private float[] mInterpolateMatrixValue;
    private float[] mEndMatrixValue;
    private float mRotateDegrees;


    public void setScaleEndAnimParams(Matrix startMatrix, Matrix endMatrix, float rotateFixDegree) {
        mStartMatrix = startMatrix;
        mEndMatrix = endMatrix;
        mRotateDegrees = rotateFixDegree;
        mMatrix.reset();
        if (mStartMatrix == null || mEndMatrix == null) {
            return;
        }
        mStartMatrixValue = new float[9];
        mStartMatrix.getValues(mStartMatrixValue);
        mEndMatrixValue = new float[9];
        mEndMatrix.getValues(mEndMatrixValue);
        mInterpolateMatrixValue = new float[9];

        setAnimConfig();
    }

    protected void setAnimConfig() {
        setFloatValues(0, 1f);
        setDuration(SCALE_ANIMATOR_DURATION);
        addUpdateListener(this);
        addListener(this);
    }


    @Override
    public void onAnimationUpdate(ValueAnimator animation) {
        // 获取动画进度
        float value = (Float) animation.getAnimatedValue();
        onValueUpdate(value);
    }


    public void onValueUpdate(float value) {
        if (mStartMatrix == null
                || mEndMatrix == null) {
            return;
        }
        for (int i = 0; i < 9; i++) {
            mInterpolateMatrixValue[i] = mStartMatrixValue[i] + (mEndMatrixValue[i] - mStartMatrixValue[i]) * value;
        }
        mMatrix.setValues(mInterpolateMatrixValue);
        updateMatrixToView(mMatrix);
    }


    protected abstract void updateMatrixToView(Matrix transMatrix);

    protected abstract void onFixEndAnim(ValueAnimator animator, float fixEndDegrees);

    @Override
    public void onAnimationStart(Animator animation) {
    }

    @CallSuper
    @Override
    public void onAnimationEnd(Animator animation) {
        onFixEndAnim(this, mRotateDegrees);
    }

    @CallSuper
    @Override
    public void onAnimationCancel(Animator animation) {
    }

    @Override
    public void onAnimationRepeat(Animator animation) {
    }

}