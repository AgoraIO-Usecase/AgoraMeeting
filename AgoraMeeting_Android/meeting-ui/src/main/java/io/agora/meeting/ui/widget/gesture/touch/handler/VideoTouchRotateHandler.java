package io.agora.meeting.ui.widget.gesture.touch.handler;

import android.graphics.Matrix;
import android.graphics.PointF;
import android.view.TextureView;

import io.agora.meeting.ui.widget.gesture.touch.RotateGestureDetector;
import io.agora.meeting.ui.widget.gesture.touch.adapter.IVideoTouchAdapter;


/**
 * 手势旋转 处理
 * <p>
 *
 * @author yinxuming
 * @date 2020/12/23
 */
public class VideoTouchRotateHandler implements IVideoRotateHandler, RotateGestureDetector.OnRotateGestureListener {

    private IVideoTouchAdapter mTouchAdapter;
    private boolean mIsRotating;  // 是否旋转中
    private float mRotateDegrees;
    private PointF mRotateCenter;   // 目前需求只需要围绕画面中心旋转即可

    public VideoTouchRotateHandler(IVideoTouchAdapter videoTouchAdapter) {
        mTouchAdapter = videoTouchAdapter;
    }

    @Override
    public boolean onRotateBegin(RotateGestureDetector detector) {
        if (isTextureViewValid()) {
            mTouchAdapter.getVideoTouchEndAnim().endPrevAnim();
            mIsRotating = true;
            mRotateCenter = new PointF(mTouchAdapter.getTextureView().getWidth() / 2,
                    mTouchAdapter.getTextureView().getHeight() / 2);
        }
        return true;
    }

    @Override
    public boolean onRotate(RotateGestureDetector detector, float degrees, float px, float py) {
        if (isRotating()) {
            postRotate(degrees); // 永远使用画面中心点进行旋转，避免由于旋转中心点引起位置变化，最后的回弹动效无法与边缘对齐
        }
        return true;

    }

    private void postRotate(float rotateDegree) {
        Matrix matrix = getTransformMatrix();
        matrix.postRotate(rotateDegree, mRotateCenter.x, mRotateCenter.y);
        updateMatrixToTexture(matrix);
        setRotateDegrees(getCurrentRotateDegree() + rotateDegree);
    }


    @Override
    public void onRotateEnd(RotateGestureDetector detector) {
        if (isRotating() && mTouchAdapter.getVideoTouchEndAnim() != null) {
            mTouchAdapter.getVideoTouchEndAnim().setEndAnimRotate(getCurrentRotateDegree(),
                    computeRoteEndDegree(getCurrentRotateDegree()));
        }
        mIsRotating = false;
    }

    public boolean isRotating() {
        return mIsRotating;
    }

    @Override
    public boolean isRotated() {
        return mRotateDegrees != 0 || mIsRotating;
    }

    @Override
    public float getCurrentRotateDegree() {
        return mRotateDegrees;
    }

    private void setRotateDegrees(float rotateDegrees) {
        rotateDegrees = rotateDegrees % 360; // 大于360度的，取其模，避免累加误差急剧增大
        mRotateDegrees = rotateDegrees;

    }

    @Override
    public float getTargetRotateDegree() {
        return getCurrentRotateDegree() + computeRoteEndDegree(getCurrentRotateDegree());
    }

    /**
     * 旋转回弹动画结束后，更新已补偿的角度
     * @param rotateDegree
     */
    @Override
    public void fixRotateEndAnim(float rotateDegree) {
        setRotateDegrees(getCurrentRotateDegree() + rotateDegree);
    }

    @Override
    public void cancelRotate() {
        setRotateDegrees(0);
        mRotateCenter = null;
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

    private void updateMatrixToTexture(Matrix newMatrix) {
        if (isTextureViewValid()) {
            TextureView textureView = mTouchAdapter.getTextureView();
            textureView.setTransform(newMatrix);
            if (!mTouchAdapter.isPlaying()) {
                textureView.invalidate();
            }
        }
    }

    /**
     * 计算旋转结束后需要补偿的角度
     * @param currentRotateDegree
     * @return
     */
    public static float computeRoteEndDegree(float currentRotateDegree) {
        float rotateEndFixDegrees = currentRotateDegree % 90;
        if (rotateEndFixDegrees != 0) {
            if (rotateEndFixDegrees >= 45) { // 大于45度，直接旋转到90，计算旋转到90需要的角度
                rotateEndFixDegrees = 90 - rotateEndFixDegrees;
            } else if (rotateEndFixDegrees > -45 && rotateEndFixDegrees < 45) { // (-45, 45)，回弹到0度位置
                rotateEndFixDegrees = -rotateEndFixDegrees;
            } else if (rotateEndFixDegrees < -45) { // 小于-45，直接旋转到-90，计算旋转到90需要的角度
                rotateEndFixDegrees = -90 - rotateEndFixDegrees;
            }
        }
        return rotateEndFixDegrees;
    }

}
