package io.agora.meeting.core.annotaion;

import androidx.annotation.StringDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Description:
 *
 *
 * @since 2/3/21
 */
@StringDef({UserRole.HOST, UserRole.BROADCASTER, UserRole.AUDIENCE})
@Retention(RetentionPolicy.SOURCE)
public @interface UserRole {
    String HOST = "host";
    String BROADCASTER = "broadcaster";
    String AUDIENCE = "audience";
}
