package io.agora.meeting.annotaion.room;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

import io.agora.meeting.annotaion.member.Role;

@IntDef({GlobalModuleState.ENABLE, GlobalModuleState.CLOSE, GlobalModuleState.DISABLE})
@Retention(RetentionPolicy.SOURCE)
public @interface GlobalModuleState {
    /**
     * Enable by {@link Role#HOST}
     */
    int ENABLE = 0;
    /**
     * Close by {@link Role#HOST}
     */
    int CLOSE = 1;
    /**
     * Disable by {@link Role#HOST}
     */
    int DISABLE = 2;
}
