package io.agora.meeting.core.annotaion;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Description:
 *
 *
 * @since 3/30/21
 */
@IntDef({DataState.REMOVE, DataState.UPDATE, DataState.ADD})
@Retention(RetentionPolicy.SOURCE)
public @interface DataState {
    int REMOVE = 1;
    int UPDATE = 2;
    int ADD = 3;
}
