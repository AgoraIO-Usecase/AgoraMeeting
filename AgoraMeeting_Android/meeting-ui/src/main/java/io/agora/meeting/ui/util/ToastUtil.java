package io.agora.meeting.ui.util;

import android.content.Context;
import android.os.Handler;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;

import io.agora.meeting.ui.R;

public class ToastUtil {
    private static Context sContext;
    private static Handler sHandler;

    static void init(@NonNull Context context) {
        sContext = context.getApplicationContext();
        sHandler = new Handler();
    }

    public static void showShort(@StringRes int resId) {
        showShort(getContext().getString(resId));
    }

    public static void showShort(@StringRes int resId, Object... formatArgs) {
        showShort(getContext().getString(resId, formatArgs));
    }

    public static void showShort(@Nullable String text) {
        if(TextUtils.isEmpty(text)){
            return;
        }
        sHandler.post(() -> showCustomToast(text, Toast.LENGTH_SHORT));
    }

    public static void showLong(@StringRes int resId) {
        showLong(getContext().getString(resId));
    }

    public static void showLong(@StringRes int resId, Object... formatArgs) {
        showLong(getContext().getString(resId, formatArgs));
    }

    public static void showLong(@Nullable String text) {
        if(TextUtils.isEmpty(text)){
            return;
        }
        sHandler.post(() -> showCustomToast(text, Toast.LENGTH_LONG));
    }

    private static void showCustomToast(String text, int duration){
        Context context = getContext();
        Toast toast = Toast.makeText(context, text, duration);
        toast.setGravity(Gravity.CENTER, 0, 0);
        View view = LayoutInflater.from(context).inflate(R.layout.layout_toast, null);
        toast.setView(view);
        ((TextView)view.findViewById(android.R.id.message)).setText(text);
        toast.show();
    }

    private static Context getContext() throws IllegalStateException {
        if (sContext == null)
            throw new IllegalStateException("ToastManager is not initialized. Please call init() before use!");
        return sContext;
    }
}
