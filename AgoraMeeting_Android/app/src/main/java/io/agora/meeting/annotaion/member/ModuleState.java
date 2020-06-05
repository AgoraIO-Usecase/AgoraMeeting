package io.agora.meeting.annotaion.member;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({ModuleState.DISABLE, ModuleState.ENABLE})
@Retention(RetentionPolicy.SOURCE)
public @interface ModuleState {
    /**
     * Disable
     */
    int DISABLE = 0;
    /**
     * Enable
     */
    int ENABLE = 1;
}
