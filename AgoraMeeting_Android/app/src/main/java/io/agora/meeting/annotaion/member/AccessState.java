package io.agora.meeting.annotaion.member;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({AccessState.EXIT, AccessState.ENTER})
@Retention(RetentionPolicy.SOURCE)
public @interface AccessState {
    /**
     * Exit
     */
    int EXIT = 0;
    /**
     * Enter
     */
    int ENTER = 1;
}
