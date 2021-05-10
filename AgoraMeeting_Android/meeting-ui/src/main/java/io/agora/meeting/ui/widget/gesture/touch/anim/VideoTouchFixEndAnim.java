package io.agora.meeting.ui.widget.gesture.touch.anim;

import android.animation.ValueAnimator;
import android.graphics.Matrix;
import android.graphics.PointF;
import android.graphics.RectF;
import android.view.TextureView;

import io.agora.meeting.ui.widget.gesture.touch.adapter.IVideoTouchAdapter;


/**
 * 回弹动效参数计算、动画状态控制
 * <p>
 *
 * @author yinxuming
 * @date 2020/12/24
 */
public class VideoTouchFixEndAnim implements IVideoTouchEndAnim {

    private IVideoTouchAdapter mTouchAdapter;
    private ValueAnimator mAnimator;
    float mScale = 1.0f;
    float mCurrentRotateDegrees;
    float mRotateEndFixDegrees;
    boolean isNeedFixAnim = false;

    public VideoTouchFixEndAnim(IVideoTouchAdapter touchAdapter) {
        mTouchAdapter = touchAdapter;
    }

    @Override
    public void setEndAnimScale(float scale) {
        mScale = scale;
        isNeedFixAnim = true;
    }

    @Override
    public void setEndAnimRotate(float currentRotate, float rotateEndFixDegrees) {
        mCurrentRotateDegrees = currentRotate;
        mRotateEndFixDegrees = rotateEndFixDegrees;
        isNeedFixAnim = true;
    }

    @Override
    public void startAnim() {
        // 注意在主线程调用动画相关操作
        endPrevAnim();
        if (!isNeedFixAnim) {
            return;
        }
        mAnimator = makeFixEndAnimator();
        if (mAnimator == null) {
            return;
        }
        mAnimator.start();
    }


    @Override
    public void endPrevAnim() {
        if (mAnimator != null && (mAnimator.isRunning() || mAnimator.isStarted())) {
            mAnimator.end();
        }
        mAnimator = null;
    }

    /**
     * 计算transAnimX、transAnimY 得到endAnimMatrix，生成动画对象
     * @return
     */
    private ValueAnimator makeFixEndAnimator() {
        TextureView mTextureView = mTouchAdapter.getTextureView();
        // 动画 start矩阵：当前画面变换
        Matrix currentTransformMatrix = mTextureView.getTransform(null);
        Matrix endAnimMatrix = new Matrix();
        final float fixDegrees = mRotateEndFixDegrees;
        RectF videoRectF = new RectF(0, 0, mTextureView.getWidth(), mTextureView.getHeight());
        PointF center = new PointF(videoRectF.right / 2, videoRectF.bottom / 2);
        endAnimMatrix.set(currentTransformMatrix);
        // 动画 end矩阵：模拟计算当前画面经过旋转补偿后的矩阵
        endAnimMatrix.postRotate(fixDegrees, center.x, center.y);
        RectF currentLocationRectF = new RectF(0, 0, mTextureView.getWidth(), mTextureView.getHeight());
        // 测量画面最终应该进行的矩阵变换位置
        endAnimMatrix.mapRect(currentLocationRectF);

        float transAnimX = 0f;
        float transAnimY = 0f;
        if (currentLocationRectF.left > videoRectF.left
                || currentLocationRectF.right < videoRectF.right
                || currentLocationRectF.top > videoRectF.top
                || currentLocationRectF.bottom < videoRectF.bottom) { //，有一边缩放后在屏幕内部，自动吸附到屏幕边缘 或 居中

            if (currentLocationRectF.width() <= videoRectF.width()) { // 宽度 < 屏宽：居中
                transAnimX = videoRectF.right / 2 - (currentLocationRectF.right + currentLocationRectF.left) / 2;
            } else if (currentLocationRectF.left > videoRectF.left) { // 左侧在屏幕内：左移吸边
                transAnimX = videoRectF.left - currentLocationRectF.left;
            } else if (currentLocationRectF.right < videoRectF.right) {  //  右侧在屏幕内：右移吸边
                transAnimX = videoRectF.right - currentLocationRectF.right;
            }

            if (currentLocationRectF.height() <= videoRectF.height()) { // 高度 < 屏搞：居中
                transAnimY = videoRectF.bottom / 2 - (currentLocationRectF.bottom + currentLocationRectF.top) / 2;
            } else if (currentLocationRectF.top > videoRectF.top) {  // 上移吸边
                transAnimY = videoRectF.top - currentLocationRectF.top;
            } else if (currentLocationRectF.bottom < videoRectF.bottom) { // 下移吸边
                transAnimY = videoRectF.bottom - currentLocationRectF.bottom;
            }
        }

        endAnimMatrix.postTranslate(transAnimX, transAnimY);

        // 不使用动画直接变换
//        mTouchAdapter.getTextureView().setTransform(endAnimMatrix);
//        mTouchAdapter.getVideoRotateHandler().postRotateDegrees(fixDegrees, false);
        if (transAnimX == 0 && transAnimY == 0 && fixDegrees == 0) {
            return null;
        } else {
            ScaleRotateEndAnimator animator = new ScaleRotateEndAnimator() {
                @Override
                protected void updateMatrixToView(Matrix transMatrix) {
                    mTouchAdapter.getTextureView().setTransform(transMatrix);
                }

                @Override
                protected void onFixEndAnim(ValueAnimator animator, float fixEndDegrees) {
                    mTouchAdapter.getVideoRotateHandler().fixRotateEndAnim(fixEndDegrees);
                    if (animator == mAnimator) {
                        mAnimator = null;
                        onAnimEndRelease();
                    }
                }
            };
            animator.setScaleEndAnimParams(currentTransformMatrix, endAnimMatrix, fixDegrees);
            return animator;
        }
    }

    private void onAnimEndRelease() {
        isNeedFixAnim = false;

        mScale = 1.0f;
        mCurrentRotateDegrees = 0;
        mRotateEndFixDegrees = 0;
    }
}
