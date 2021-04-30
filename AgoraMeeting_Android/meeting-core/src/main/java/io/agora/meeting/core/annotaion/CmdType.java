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
@IntDef({CmdType.APPROVE, CmdType.MUTE_ALL})
@Retention(RetentionPolicy.SOURCE)
public @interface CmdType {
    int APPROVE  = 1;
    int MUTE_ALL = 2;
}
