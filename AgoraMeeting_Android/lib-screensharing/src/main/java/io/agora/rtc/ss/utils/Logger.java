package io.agora.rtc.ss.utils;

import android.util.Log;

/**
 * Description:
 *
 * @author xcz
 * @since 2/5/21
 */
public class Logger {
    public static final boolean loggable = true;

    public static void e(String tag, String msg){
        if(!loggable){
            return;
        }
        Log.e(tag, msg);
    }

    public static void d(String tag, String msg){
        if(!loggable){
            return;
        }
        Log.d(tag, msg);
    }

    public static void w(String tag, String msg){
        if(!loggable){
            return;
        }
        Log.w(tag, msg);
    }

    public static void i(String tag, String msg){
        if(!loggable){
            return;
        }
        Log.i(tag, msg);
    }
}
