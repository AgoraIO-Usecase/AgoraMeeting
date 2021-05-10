package io.agora.meeting.core.bean;

import com.google.gson.Gson;

import java.util.Map;

import io.agora.meeting.core.annotaion.Keep;
import io.agora.meeting.core.annotaion.ModuleState;

/**
 * Description:
 *  用户属性，见 https://confluence.agoralab.co/pages/viewpage.action?pageId=713693791
 *
 *
 * @since 3/3/21
 */
@Keep
public final class UserProperties {
    // 污点，有污点的用户不允许进入房间
    public Dirty dirty;

    @Keep
    public static final class Dirty{
        @ModuleState
        public int state;
        public long endTime;
    }


    public static UserProperties parse(Map<String, Object> properties){
        Gson gson = new Gson();
        String json = gson.toJson(properties);
        return gson.fromJson(json, UserProperties.class);
    }
}
