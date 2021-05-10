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
@IntDef({StreamType.MEDIA, StreamType.SCREEN, StreamType.BOARD})
@Retention(RetentionPolicy.SOURCE)
public @interface StreamType {
    int MEDIA         = 0;
    int SCREEN        = 2;
    int BOARD         = 3;
}
