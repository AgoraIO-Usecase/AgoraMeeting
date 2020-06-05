package io.agora.meeting.annotaion.room;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({AudioRoute.HEADSET, AudioRoute.EARPIECE, AudioRoute.SPEAKER})
@Retention(RetentionPolicy.SOURCE)
public @interface AudioRoute {
    int HEADSET = 0;
    int EARPIECE = 1;
    int SPEAKER = 2;
}
