package io.agora.meeting.ui.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Description:
 *
 *
 * @since 3/10/21
 */
@IntDef({ChatState.SENDING, ChatState.FAILED, ChatState.SUCCESS})
@Retention(RetentionPolicy.SOURCE)
public @interface ChatState {
    int SENDING = 0;
    int FAILED  = 1;
    int SUCCESS = 2;
}
