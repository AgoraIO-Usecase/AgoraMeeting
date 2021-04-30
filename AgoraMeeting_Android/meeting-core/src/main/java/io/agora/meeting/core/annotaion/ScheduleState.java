package io.agora.meeting.core.annotaion;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Description:
 *
 *
 * @since 3/10/21
 */
@IntDef({ScheduleState.HAS_NOT_START, ScheduleState.STARTED, ScheduleState.ENDED})
@Retention(RetentionPolicy.SOURCE)
public @interface ScheduleState {
    int HAS_NOT_START = 0;
    int STARTED = 1;
    int ENDED = 2;
}
