package io.agora.meeting.core.annotaion;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({ModuleState.DISABLE, ModuleState.ENABLE, ModuleState.FORBID})
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
    /**
     * 禁止
     */
    int FORBID = 2;
}
