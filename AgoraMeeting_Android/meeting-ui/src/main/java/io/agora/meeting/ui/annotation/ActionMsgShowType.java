package io.agora.meeting.ui.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Description:
 *
 *
 * @since 3/5/21
 */
@IntDef({ActionMsgShowType.TEXT, ActionMsgShowType.URL, ActionMsgShowType.ACTION})
@Retention(RetentionPolicy.SOURCE)
public @interface ActionMsgShowType {
    int ACTION  = 1;
    int URL     = 2;
    int TEXT    = 3;
}
