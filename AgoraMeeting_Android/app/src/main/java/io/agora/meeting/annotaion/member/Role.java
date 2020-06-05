package io.agora.meeting.annotaion.member;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({Role.HOST, Role.AUDIENCE})
@Retention(RetentionPolicy.SOURCE)
public @interface Role {
    /**
     * Meeting role: host
     */
    int HOST = 1;
    /**
     * Meeting role: audience
     */
    int AUDIENCE = 2;
}
