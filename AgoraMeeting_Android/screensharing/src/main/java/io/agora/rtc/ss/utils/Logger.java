package io.agora.rtc.ss.utils;

import android.content.Context;
import android.os.Environment;
import android.os.Process;

import java.io.File;

import io.agora.log.AgoraConsolePrintType;
import io.agora.log.AgoraLogManager;

/**
 * Description:
 *
 *
 * @since 2/5/21
 */
public class Logger {
    public static final boolean loggable = true;
    private static AgoraLogManager agoraLogger;

    public static void init(Context context, String prefix) {
        if (agoraLogger != null) {
            return;
        }
        try {
            agoraLogger = new AgoraLogManager(
                    logFolder(context).getAbsolutePath(),
                    prefix,
                    2,
                    prefix,
                    AgoraConsolePrintType.ALL
            );
        } catch (Exception exception) {
            exception.printStackTrace();
        }
    }

    private static File logFolder(Context context) {
        File folder = new File(context.getExternalFilesDir(
                Environment.DIRECTORY_DOCUMENTS), "logs");
        folder.mkdirs();
        return folder;
    }

    public static void e(String tag, String msg) {
        if (!loggable) {
            return;
        }
        if (agoraLogger != null) {
            agoraLogger.e("pid=" + Process.myPid() + ":" + tag + " >> " + msg);
        }
    }

    public static void d(String tag, String msg) {
        if (!loggable) {
            return;
        }
        if (agoraLogger != null) {
            agoraLogger.d("pid=" + Process.myPid() + ":" + tag + " >> " + msg);
        }
    }

    public static void w(String tag, String msg) {
        if (!loggable) {
            return;
        }
        if (agoraLogger != null) {
            agoraLogger.w("pid=" + Process.myPid() + ":" + tag + " >> " + msg);
        }
    }

    public static void i(String tag, String msg) {
        if (!loggable) {
            return;
        }
        if (agoraLogger != null) {
            agoraLogger.i("pid=" + Process.myPid() + ":" + tag + " >> " + msg);
        }
    }
}
