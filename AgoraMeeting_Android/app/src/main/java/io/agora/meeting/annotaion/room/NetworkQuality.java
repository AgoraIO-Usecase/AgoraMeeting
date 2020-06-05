package io.agora.meeting.annotaion.room;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({NetworkQuality.IDLE, NetworkQuality.GOOD, NetworkQuality.POOR, NetworkQuality.BAD})
@Retention(RetentionPolicy.SOURCE)
public @interface NetworkQuality {
    int IDLE = 0;
    int GOOD = 1;
    int POOR = 2;
    int BAD = 3;
}
