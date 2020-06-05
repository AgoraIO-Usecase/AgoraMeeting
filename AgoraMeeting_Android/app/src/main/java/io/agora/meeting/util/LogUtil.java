package io.agora.meeting.util;

import android.app.Activity;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;

import io.agora.base.ToastManager;
import io.agora.base.annotation.OS;
import io.agora.base.annotation.Terminal;
import io.agora.base.callback.ThrowableCallback;
import io.agora.log.LogManager;
import io.agora.log.UploadManager;
import io.agora.meeting.BuildConfig;
import io.agora.meeting.MainApplication;
import io.agora.meeting.R;

public class LogUtil {
    public static void upload(@NonNull Activity activity, @Nullable String roomId) {
        UploadManager.upload(activity, new UploadManager.UploadParam(
                BuildConfig.API_BASE_URL,
                "/meeting/v1/log/params?osType=" + OS.ANDROID + "&terminalType=" + Terminal.PHONE,
                MainApplication.getAppId(),
                BuildConfig.CODE,
                BuildConfig.VERSION_NAME,
                roomId,
                LogManager.getPath().getAbsolutePath(),
                "/meeting/v1/log/sts/callback"
        ), new ThrowableCallback<String>() {
            @Override
            public void onSuccess(String res) {
                activity.runOnUiThread(() ->
                        new AlertDialog.Builder(activity)
                                .setTitle(R.string.upload_success)
                                .setMessage(res)
                                .setPositiveButton(R.string.know, (dialog, which) -> {
                                    ClipboardManager manager = (ClipboardManager) activity.getSystemService(Context.CLIPBOARD_SERVICE);
                                    if (manager != null) {
                                        manager.setPrimaryClip(ClipData.newPlainText(null, res));
                                        ToastManager.showShort(activity.getString(R.string.clipboard));
                                    }
                                })
                                .show()
                );
            }

            @Override
            public void onFailure(Throwable throwable) {
                ToastManager.showShort(throwable.getMessage());
            }
        });
    }
}
