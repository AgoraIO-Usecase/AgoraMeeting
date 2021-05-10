package io.agora.meeting.core.annotaion;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Description:
 *
 *
 * @since 2/19/21
 */
@IntDef({ShareType.NONE, ShareType.SCREEN, ShareType.BOARD})
@Retention(RetentionPolicy.SOURCE)
public @interface ShareType {
    int NONE = 0;
    int SCREEN = 1;
    int BOARD = 2;
}
