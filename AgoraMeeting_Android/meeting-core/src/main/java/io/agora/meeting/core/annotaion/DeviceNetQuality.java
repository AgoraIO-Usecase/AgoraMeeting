package io.agora.meeting.core.annotaion;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({DeviceNetQuality.IDLE, DeviceNetQuality.GOOD, DeviceNetQuality.POOR, DeviceNetQuality.BAD})
@Retention(RetentionPolicy.SOURCE)
public @interface DeviceNetQuality {
    int IDLE = 0;
    int GOOD = 1;
    int POOR = 2;
    int BAD = 3;
}
