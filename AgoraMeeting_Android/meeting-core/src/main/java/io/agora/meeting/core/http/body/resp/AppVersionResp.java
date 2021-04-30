package io.agora.meeting.core.http.body.resp;

import java.util.Map;

import io.agora.meeting.core.annotaion.Keep;
import io.agora.meeting.core.annotaion.ModuleState;
import io.agora.meeting.core.annotaion.OS;
import io.agora.meeting.core.annotaion.Terminal;

/**
 * Description:
 *
 *
 * @since 3/3/21
 */
@Keep
public final class AppVersionResp {
    public String appPackage;
    public String appVersion;
    @ModuleState
    public int forcedUpgrade;
    public String id;
    public String latestVersion;
    @OS
    public int osType;
    @Terminal
    public int terminalType;
    public int remindTimes;
    @ModuleState
    public int reviewing;
    public String upgradeDescription;
    public String upgradeUrl;

    public Config config;

    @Keep
    public static class Config {
        public Map<String, Map<String, String>> multiLanguage;
        public int whiteboardOperatorCount;
    }

}
