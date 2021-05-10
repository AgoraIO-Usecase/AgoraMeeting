package io.agora.meeting.ui.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * author: xcz
 * since:  1/19/21
 **/
@IntDef({Layout.TILED, Layout.AUDIO, Layout.SPEAKER})
@Retention(RetentionPolicy.SOURCE)
public @interface Layout {

    int TILED = 0; // 平铺视图
    int AUDIO = 1; // 语音视图
    int SPEAKER = 2; // 演讲者视图
}
