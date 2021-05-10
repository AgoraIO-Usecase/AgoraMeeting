package io.agora.meeting.core.log;

import android.content.Context;

import io.agora.log.AgoraConsolePrintType;
import io.agora.log.AgoraLogManager;
import io.agora.log.AgoraLogType;
import io.agora.rte.LogUtil;
import io.agora.rte.annotation.Keep;

/**
 * Description:
 *
 *
 * @since 3/1/21
 */
@Keep
public final class Logger {
    private final static String LogFile = "AgoraMeeting";
    public final static String LogTag = "AgoraMeeting";
    private final AgoraLogManager logManager;

    private static volatile Logger mLogger;

    private Logger(Context context, boolean logAll) throws Exception {
        logManager = new AgoraLogManager(
                LogUtil.INSTANCE.logFolderPath(context),
                LogFile,
                LogUtil.MAX_LOG_FILES,
                LogTag,
                logAll ? AgoraConsolePrintType.ALL : AgoraConsolePrintType.INFO
        );
    }

    public static void initialize(Context context, boolean logAll) {
        synchronized (Logger.class) {
            try {
                mLogger = new Logger(context, logAll);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    private static void log(String msg, AgoraLogType type){
        if(mLogger != null){
            mLogger.logManager.logMsg(msg, type);
        }
    }

    public static void d(String tag, String msg) {
        log(tag + " >> " + msg, AgoraLogType.DEBUG);
    }

    public static void d(String msg) {
        log(msg, AgoraLogType.DEBUG);
    }

    public static void i(String tag, String msg) {
        log(tag + " >> " + msg, AgoraLogType.INFO);
    }

    public static void i(String msg) {
        log(msg, AgoraLogType.INFO);
    }

    public static void w(String tag, String msg) {
        log(tag + " >> " + msg, AgoraLogType.WARNING);
    }

    public static void w(String msg) {
        log(msg, AgoraLogType.WARNING);
    }

    public static void e(String tag, String msg) {
        log(tag + " >> " + msg, AgoraLogType.ERROR);
    }

    public static void e(String msg) {
        log(msg, AgoraLogType.ERROR);
    }
}
