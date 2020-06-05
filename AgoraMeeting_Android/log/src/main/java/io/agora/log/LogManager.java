package io.agora.log;

import android.content.Context;

import androidx.annotation.NonNull;

import com.elvishew.xlog.LogConfiguration;
import com.elvishew.xlog.LogLevel;
import com.elvishew.xlog.Logger;
import com.elvishew.xlog.XLog;
import com.elvishew.xlog.printer.AndroidPrinter;
import com.elvishew.xlog.printer.file.FilePrinter;
import com.elvishew.xlog.printer.file.naming.ChangelessFileNameGenerator;

import java.io.File;

public class LogManager {
    private static File sPath;
    private static String sTag;
    private Logger logger;

    public static void init(@NonNull Context context, @NonNull String tag) {
        sPath = new File(context.getExternalCacheDir(), "logs");
        sTag = tag;
        XLog.init(new LogConfiguration.Builder()
                        .logLevel(LogLevel.ALL)
                        .tag(tag).build(),
                new AndroidPrinter(),
                new FilePrinter.Builder(getPath().getAbsolutePath())
                        .fileNameGenerator(new ChangelessFileNameGenerator(tag + ".log"))
                        .build());
    }

    public LogManager(String sTag) {
        logger = XLog.tag(getTag() + " " + sTag).build();
    }

    public void d(String msg, Object... args) {
        logger.d(msg, args);
    }

    public void i(String msg, Object... args) {
        logger.i(msg, args);
    }

    public void w(String msg, Object... args) {
        logger.w(msg, args);
    }

    public void e(String msg, Object... args) {
        logger.e(msg, args);
    }

    public static File getPath() throws IllegalStateException {
        if (sPath == null)
            throw new IllegalStateException("LogManager is not initialized. Please call init() before use!");
        return sPath;
    }

    public static String getTag() throws IllegalStateException {
        if (sTag == null)
            throw new IllegalStateException("LogManager is not initialized. Please call init() before use!");
        return sTag;
    }
}
