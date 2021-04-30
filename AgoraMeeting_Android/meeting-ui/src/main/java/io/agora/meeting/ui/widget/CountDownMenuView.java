package io.agora.meeting.ui.widget;

import android.content.Context;
import android.os.Parcelable;
import android.util.AttributeSet;
import android.util.SparseArray;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Locale;

import io.agora.meeting.ui.R;


/**
 * Description:
 *
 *
 * @since 1/22/21
 */
public class CountDownMenuView extends FrameLayout {

    private TextView tvSecond;
    private int leftSecond;
    private Runnable endRun;

    private final Runnable updateRun = new Runnable() {
        @Override
        public void run() {
            tvSecond.setText(String.format(Locale.US, "%ds", leftSecond));
            leftSecond--;
            if (leftSecond > 0) {
                postDelayed(this, 1000);
            } else {
                // 倒计时结束
                setVisibility(View.GONE);
                if (endRun != null) {
                    endRun.run();
                }
            }
        }
    };

    public CountDownMenuView(@NonNull Context context) {
        this(context, null);
    }

    public CountDownMenuView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public CountDownMenuView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        LayoutInflater.from(getContext()).inflate(R.layout.widget_menu_count_down, this, true);
        tvSecond = findViewById(R.id.tv_second);

        // 禁用点击事件
        setOnTouchListener((v, event) -> true);
        setVisibility(View.GONE);
    }


    private void bindTarget(View targetView){
        if (targetView == null) {
            throw new IllegalStateException("targetView can not be null");
        }
        if (getParent() != null) {
            ((ViewGroup) getParent()).removeView(this);
        }
        ViewParent targetParent = targetView.getParent();

        if (targetParent instanceof ViewGroup) {
            ViewGroup targetContainer = (ViewGroup) targetParent;

            if(targetContainer instanceof CDContainer){
                targetContainer.addView(this);
            }else{
                int index = targetContainer.indexOfChild(targetView);
                ViewGroup.LayoutParams targetParams = targetView.getLayoutParams();
                targetContainer.removeView(targetView);
                final CDContainer cdContainer = new CDContainer(getContext());
                if(targetContainer instanceof RelativeLayout){
                    cdContainer.setId(targetView.getId());
                }
                targetContainer.addView(cdContainer, index, targetParams);
                cdContainer.addView(targetView);
                cdContainer.addView(this);
            }
        } else {
            throw new IllegalStateException("targetView must have a parent");
        }
    }

    public void setupTarget(View targetView){
        bindTarget(targetView);
    }

    public boolean hasBindTarget(){
        return getParent() != null;
    }

    public void start(int second, Runnable end){
        leftSecond = second;
        endRun = end;

        setVisibility(View.VISIBLE);
        removeCallbacks(updateRun);
        post(updateRun);
    }

    public void stop(){
        leftSecond = 0;
        endRun = null;
        removeCallbacks(updateRun);
        setVisibility(View.GONE);
    }



    private static class CDContainer extends ViewGroup {

        @Override
        protected void dispatchRestoreInstanceState(SparseArray<Parcelable> container) {
            if(!(getParent() instanceof RelativeLayout)){
                super.dispatchRestoreInstanceState(container);
            }
        }

        public CDContainer(Context context) {
            super(context);
        }

        @Override
        protected void onLayout(boolean changed, int l, int t, int r, int b) {
            for (int i = 0; i < getChildCount(); i++) {
                View child = getChildAt(i);
                child.layout(0, 0, child.getMeasuredWidth(), child.getMeasuredHeight());
            }
        }

        @Override
        protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
            View targetView = null, badgeView = null;
            for (int i = 0; i < getChildCount(); i++) {
                View child = getChildAt(i);
                if (!(child instanceof CountDownMenuView)) {
                    targetView = child;
                } else {
                    badgeView = child;
                }
            }
            if (targetView == null) {
                super.onMeasure(widthMeasureSpec, heightMeasureSpec);
            } else {
                targetView.measure(widthMeasureSpec, heightMeasureSpec);
                if (badgeView != null) {
                    badgeView.measure(MeasureSpec.makeMeasureSpec(targetView.getMeasuredWidth(), MeasureSpec.EXACTLY),
                            MeasureSpec.makeMeasureSpec(targetView.getMeasuredHeight(), MeasureSpec.EXACTLY));
                }
                setMeasuredDimension(targetView.getMeasuredWidth(), targetView.getMeasuredHeight());
            }
        }
    }

}
