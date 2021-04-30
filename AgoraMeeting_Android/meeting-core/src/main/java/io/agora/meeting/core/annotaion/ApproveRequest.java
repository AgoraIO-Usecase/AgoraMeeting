package io.agora.meeting.core.annotaion;

import androidx.annotation.StringDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Description:
 *
 *
 * @since 3/1/21
 */
@StringDef({ApproveRequest.CAMERA, ApproveRequest.MIC})
@Retention(RetentionPolicy.SOURCE)
public @interface ApproveRequest {
    String CAMERA = "cameraAccess";
    String MIC = "micAccess";
}
