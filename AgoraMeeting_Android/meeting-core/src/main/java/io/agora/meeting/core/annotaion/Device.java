package io.agora.meeting.core.annotaion;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Description:
 *
 *
 * @since 3/5/21
 */
@IntDef({Device.CAMERA, Device.MIC})
@Retention(RetentionPolicy.SOURCE)
public @interface Device {
    int CAMERA = 1;
    int MIC    = 2;
}
