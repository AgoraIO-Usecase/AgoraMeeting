package io.agora.meeting.core.annotaion;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

import io.agora.rtc.video.VideoCanvas;

/**
 * Description:
 *
 *
 * @since 2/25/21
 */
@IntDef({RenderMode.HIDDEN, RenderMode.FIT})
@Retention(RetentionPolicy.SOURCE)
public @interface RenderMode {
    int HIDDEN = VideoCanvas.RENDER_MODE_HIDDEN;
    int FIT = VideoCanvas.RENDER_MODE_FIT;
}
