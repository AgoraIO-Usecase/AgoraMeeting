package io.agora.meeting.ui.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.view.animation.LinearInterpolator;

import androidx.annotation.NonNull;

import io.agora.meeting.ui.R;

/**
 * Description:
 *
 *
 * @since 3/10/21
 */
public class LoadingImageView extends androidx.appcompat.widget.AppCompatImageView {

    private Animation animation;

    public LoadingImageView(Context context) {
        this(context, null);
    }

    public LoadingImageView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public LoadingImageView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        animation = AnimationUtils.loadAnimation(context, R.anim.loading);
        animation.setInterpolator(new LinearInterpolator());
    }

    @Override
    protected void onVisibilityChanged(@NonNull View changedView, int visibility) {
        super.onVisibilityChanged(changedView, visibility);
        if(visibility == View.VISIBLE){
            startAnimation(animation);
        }else{
            clearAnimation();
        }
    }

}
