package io.agora.meeting.annotaion.message;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({NormalAction.APPLY, NormalAction.REJECT_INVITE})
@Retention(RetentionPolicy.SOURCE)
public @interface NormalAction {
    int APPLY = 1;
    int REJECT_INVITE = 2;
}
