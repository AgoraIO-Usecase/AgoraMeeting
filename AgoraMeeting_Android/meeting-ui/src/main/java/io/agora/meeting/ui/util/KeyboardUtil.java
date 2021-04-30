package io.agora.meeting.ui.util;

import android.app.Activity;
import android.content.Context;
import android.graphics.Rect;
import android.util.DisplayMetrics;
import android.view.View;
import android.view.ViewTreeObserver;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;

import androidx.annotation.NonNull;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleEventObserver;
import androidx.lifecycle.LifecycleOwner;

import static android.content.Context.INPUT_METHOD_SERVICE;

/**
 * Description:
 *
 *
 * @since 3/11/21
 */
public class KeyboardUtil {
    private static final int KEYBOARD_MIN_HEIGHT = 100; // dp

    /**
     * 监听软键盘是否打开
     */
    public static void listenKeyboardChange(
            @NonNull LifecycleOwner owner,
            @NonNull View rootView,
            OnKeyboardVisibleChangeListener listener
    ) {
        KeyboardObserver keyboardObserver = new KeyboardObserver();
        keyboardObserver.rootView = rootView;
        keyboardObserver.visible = isKeyboardShown(rootView);
        keyboardObserver.listener = listener;
        owner.getLifecycle().addObserver(keyboardObserver);
        if(listener != null){
            listener.onKeyBoardVisibleChange(keyboardObserver.visible);
        }
    }

    /**
     * 判断当前软键盘是否打开
     */
    public static boolean isKeyboardShown(@NonNull View rootView) {
        Rect r = new Rect();
        rootView.getWindowVisibleDisplayFrame(r);
        DisplayMetrics dm = rootView.getResources().getDisplayMetrics();
        int heightDiff = dm.heightPixels - r.height();
        return heightDiff > KEYBOARD_MIN_HEIGHT * dm.density;
    }

    /**
     * 打开软键盘
     */
    public static void openKeyboard(EditText mEditText, Context mContext) {
        mEditText.setFocusable(true);
        mEditText.setFocusableInTouchMode(true);
        mEditText.requestFocus();

        InputMethodManager imm = (InputMethodManager) mContext
                .getSystemService(INPUT_METHOD_SERVICE);
        imm.showSoftInput(mEditText, InputMethodManager.RESULT_SHOWN);
        imm.toggleSoftInput(InputMethodManager.SHOW_FORCED,
                InputMethodManager.HIDE_IMPLICIT_ONLY);
    }

    /**
     * 关闭软键盘
     */
    public static void closeKeyboard(EditText mEditText, Context mContext) {
        InputMethodManager imm = (InputMethodManager) mContext
                .getSystemService(INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(mEditText.getWindowToken(), 0);
    }

    /**
     * 关闭软键盘
     */
    public static void hideInput(Activity activity) {
        if (activity.getCurrentFocus() != null) {
            InputMethodManager inputManager = (InputMethodManager) activity.getSystemService(INPUT_METHOD_SERVICE);
            inputManager.hideSoftInputFromWindow(activity.getCurrentFocus().getWindowToken(), 0);
        }
    }

    private static class KeyboardObserver implements LifecycleEventObserver {
        private OnKeyboardVisibleChangeListener listener;
        private View rootView;
        private boolean visible;
        private final ViewTreeObserver.OnGlobalLayoutListener layoutListener = () -> {
            if(rootView == null){
                return;
            }
            boolean mKeyboardUp = isKeyboardShown(rootView);
            if (Boolean.compare(mKeyboardUp, visible) == 0) {
                return;
            }
            visible = mKeyboardUp;
            if (listener != null) {
                listener.onKeyBoardVisibleChange(visible);
            }
        };

        @Override
        public void onStateChanged(@NonNull LifecycleOwner source,
                                   @NonNull Lifecycle.Event event) {
            if (event == Lifecycle.Event.ON_START) {
                rootView.getViewTreeObserver().addOnGlobalLayoutListener(layoutListener);
            } else if (event == Lifecycle.Event.ON_STOP) {
                rootView.getViewTreeObserver().removeOnGlobalLayoutListener(layoutListener);
            } else if (event == Lifecycle.Event.ON_DESTROY) {
                source.getLifecycle().removeObserver(this);
                rootView = null;
                listener = null;
            }
        }
    }

    public interface OnKeyboardVisibleChangeListener {
        void onKeyBoardVisibleChange(boolean visible);
    }
}
