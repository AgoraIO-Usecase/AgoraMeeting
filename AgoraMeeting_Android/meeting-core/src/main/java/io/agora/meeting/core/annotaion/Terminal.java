package io.agora.meeting.core.annotaion;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({Terminal.PHONE, Terminal.PAD})
@Retention(RetentionPolicy.SOURCE)
public @interface Terminal {
    /**
     * Phone
     */
    int PHONE = 1;
    /**
     * Pad
     */
    int PAD = 2;
}
