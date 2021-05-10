package io.agora.meeting.core.utils;

import android.text.TextUtils;

import androidx.annotation.NonNull;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import io.agora.meeting.core.annotaion.Keep;

@Keep
public final class CryptoUtil {
    private CryptoUtil(){}

    @Keep
    public static String md5(@NonNull String string) {
        if (TextUtils.isEmpty(string)) return "";
        MessageDigest md5;
        try {
            md5 = MessageDigest.getInstance("MD5");
            byte[] bytes = md5.digest(string.getBytes());
            StringBuilder result = new StringBuilder();
            for (byte b : bytes) {
                String temp = Integer.toHexString(b & 0xff);
                if (temp.length() == 1) {
                    temp = "0" + temp;
                }
                result.append(temp);
            }
            return result.toString();
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
            return "";
        }
    }

    @Keep
    public static String getAuth(@NonNull String auth) {
        String prefix = "Basic ";
        if (auth.startsWith(prefix)) {
            return auth;
        }
        return new StringBuilder(auth).insert(0, prefix).toString();
    }
}
