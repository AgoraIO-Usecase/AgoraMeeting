package io.agora.meeting.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.ViewParent;

import com.herewhite.sdk.WhiteboardView;

public class WhiteBoardView extends WhiteboardView {
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

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        super.onTouchEvent(event);
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
