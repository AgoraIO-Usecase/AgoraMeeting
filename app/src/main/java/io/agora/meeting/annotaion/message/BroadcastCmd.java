package io.agora.meeting.annotaion.message;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({
        BroadcastCmd.CHAT, BroadcastCmd.ACCESS,
        BroadcastCmd.ROOM, BroadcastCmd.USER,
        BroadcastCmd.BOARD, BroadcastCmd.SCREEN,
        BroadcastCmd.HOST, BroadcastCmd.KICK
})
@Retention(RetentionPolicy.SOURCE)
public @interface BroadcastCmd {
    /**
     * Chat message
     */
    int CHAT = 1;
    /**
     * Access message
     */
    int ACCESS = 2;
    /**
     * Room info changed message
     */
    int ROOM = 3;
    /**
     * User info changed message
     */
    int USER = 4;
    /**
     * Users with board changed message
     */
    int BOARD = 5;
    /**
     * Users with screen sharing changed message
     */
    int SCREEN = 6;
    /**
     * Hosts changed message
     */
    int HOST = 7;
    /**
     * Kick out message
     */
    int KICK = 8;
}
