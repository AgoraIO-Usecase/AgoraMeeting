package io.agora.meeting.annotaion.message;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({AdminAction.INVITE, AdminAction.REJECT_APPLY})
@Retention(RetentionPolicy.SOURCE)
public @interface AdminAction {
    int INVITE = 1;
    int REJECT_APPLY = 2;
}
