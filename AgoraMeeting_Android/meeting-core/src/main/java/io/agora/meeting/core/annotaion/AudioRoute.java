package io.agora.meeting.core.annotaion;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

import io.agora.rtc.Constants;

/**
 * Description:
 *
 *
 * @since 3/9/21
 */
@IntDef({AudioRoute.HEADSET,
        AudioRoute.HEADSETNOMIC,
        AudioRoute.HEADSETBLUETOOTH,
        AudioRoute.EARPIECE,
        AudioRoute.SPEAKER,
})
@Retention(RetentionPolicy.SOURCE)
public @interface AudioRoute {
    int HEADSET = Constants.AUDIO_ROUTE_HEADSET; // 0
    int HEADSETNOMIC = Constants.AUDIO_ROUTE_HEADSETNOMIC; // 2
    int HEADSETBLUETOOTH = Constants.AUDIO_ROUTE_HEADSETBLUETOOTH; //5
    int EARPIECE = Constants.AUDIO_ROUTE_EARPIECE; //1
    int SPEAKER = Constants.AUDIO_ROUTE_SPEAKERPHONE; //3
}
