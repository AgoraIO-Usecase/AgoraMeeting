package io.agora.meeting.ui.util;

import android.text.TextUtils;

import androidx.annotation.NonNull;

import java.util.UUID;

public class UUIDUtil {
    private static final String KEY_SP = "uuid";

    @NonNull
    public static String getUUID() {
        String uuid = PreferenceUtil.get(KEY_SP, "");
        if (TextUtils.isEmpty(uuid)) {
            uuid = UUID.randomUUID().toString();
            PreferenceUtil.put(KEY_SP, uuid);
        }
        return uuid;
    }
}
