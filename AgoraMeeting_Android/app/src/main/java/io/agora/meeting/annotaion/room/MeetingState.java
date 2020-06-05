package io.agora.meeting.annotaion.room;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({MeetingState.END, MeetingState.NORMAL})
@Retention(RetentionPolicy.SOURCE)
public @interface MeetingState {
    /**
     * Meeting is end
     */
    int END = 0;
    /**
     * Meeting is starting
     */
    int NORMAL = 1;
}
