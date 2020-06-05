package io.agora.meeting.annotaion;

import androidx.annotation.StringDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@StringDef({
        EventType.ALERT,
        EventType.KICK,
        EventType.TIME,
        EventType.UPGRADE,
})
@Retention(RetentionPolicy.SOURCE)
public @interface EventType {
    String ALERT = "alert";
    String KICK = "kick";
    String TIME = "time";
    String UPGRADE = "upgrade";
}
