package io.agora.meeting.annotaion.room;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({Module.AUDIO, Module.VIDEO, Module.BOARD, Module.CHAT})
@Retention(RetentionPolicy.SOURCE)
public @interface Module {
    /**
     * Audio
     */
    int AUDIO = 1;
    /**
     * Video
     */
    int VIDEO = 2;
    /**
     * Board
     */
    int BOARD = 3;
    /**
     * Chat
     */
    int CHAT = 4;
}
