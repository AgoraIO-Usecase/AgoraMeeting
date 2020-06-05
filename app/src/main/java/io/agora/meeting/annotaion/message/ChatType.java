package io.agora.meeting.annotaion.message;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({ChatType.TEXT})
@Retention(RetentionPolicy.SOURCE)
public @interface ChatType {
    /**
     * Text message
     */
    int TEXT = 1;
}
