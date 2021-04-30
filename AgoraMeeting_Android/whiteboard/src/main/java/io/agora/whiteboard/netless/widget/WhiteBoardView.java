package io.agora.whiteboard.netless.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.ViewParent;

import com.herewhite.sdk.WhiteboardView;

public class WhiteBoardView extends WhiteboardView {
    private boolean interceptTouchEvent = true;

    public WhiteBoardView(Context context) {
        super(context);
    }

    public WhiteBoardView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    @Override
    public boolean performClick() {
        return super.performClick();
    }

    public void setInterceptTouchEvent(boolean interceptTouchEvent){
        this.interceptTouchEvent = interceptTouchEvent;
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        boolean ret = super.onTouchEvent(event);
        if(!interceptTouchEvent){
            return ret;
        }

        requestFocus();
        ViewParent parent = getParent();
        if (parent == null) return false;
        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
            case MotionEvent.ACTION_MOVE:
                parent.requestDisallowInterceptTouchEvent(true);
                break;
            case MotionEvent.ACTION_UP:
                parent.requestDisallowInterceptTouchEvent(false);
                performClick();
                break;
        }
        return true;
    }
}
