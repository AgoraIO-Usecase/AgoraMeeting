package io.agora.meeting.core.annotaion;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Description:
 *
 *
 * @since 3/2/21
 */
@IntDef({AccessType.APPLY, AccessType.INVITE})
@Retention(RetentionPolicy.SOURCE)
public @interface AccessType {
    int APPLY = 1;
    int INVITE = 2;
}
