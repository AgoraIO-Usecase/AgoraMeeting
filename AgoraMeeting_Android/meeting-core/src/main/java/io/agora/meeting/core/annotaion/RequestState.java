package io.agora.meeting.core.annotaion;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({RequestState.IDLE, RequestState.REQUESTING, RequestState.SUCCESS, RequestState.FAILED})
@Retention(RetentionPolicy.SOURCE)
public @interface RequestState {
    int IDLE = 0;
    int REQUESTING = 1;
    int SUCCESS    = 2;
    int FAILED     = 3;
}
