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
@IntDef({ApproveAction.APPLY, ApproveAction.INVITE, ApproveAction.ACCEPT, ApproveAction.REJECT, ApproveAction.CANCEL})
@Retention(RetentionPolicy.SOURCE)
public @interface ApproveAction {
    int APPLY = 1;
    int INVITE = 2;
    int ACCEPT = 3;
    int REJECT = 4;
    int CANCEL = 5;
}
