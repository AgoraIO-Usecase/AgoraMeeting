package io.agora.meeting.core.utils;

import io.agora.meeting.core.annotaion.Keep;

/**
 * Description:
 *
 *
 * @since 3/9/21
 */
@Keep
public final class TimeSyncUtil {
    private TimeSyncUtil(){}

    private static long timestampDiff = 0;

    /**
     * @return 与后台服务器同步后的时间截
     */
    public synchronized static long getSyncCurrentTimeMillis(){
        return System.currentTimeMillis() + timestampDiff;
    }

    public synchronized static void syncLocalTimestamp(long serverTs) {
        if (serverTs > 0) {
            timestampDiff = serverTs - System.currentTimeMillis();
        }
    }
}
