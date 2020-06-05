package io.agora.meeting.service.body.res;

import io.agora.base.annotation.OS;
import io.agora.base.annotation.Terminal;

public class AppVersionRes {
    public String appCode;
    @OS
    public int osType;
    @Terminal
    public int terminalType;
    public String appVersion;
    public String latestVersion;
    public String appPackage;
    public String upgradeDescription;
    public int forcedUpgrade;
    public String upgradeUrl;
    public int reviewing;
    public int remindTimes;

    public AppVersionRes() {
    }

    public AppVersionRes(AppVersionRes res) {
        appCode = res.appCode;
        osType = res.osType;
        terminalType = res.terminalType;
        appVersion = res.appVersion;
        latestVersion = res.latestVersion;
        appPackage = res.appPackage;
        upgradeDescription = res.upgradeDescription;
        forcedUpgrade = res.forcedUpgrade;
        upgradeUrl = res.upgradeUrl;
        reviewing = res.reviewing;
        remindTimes = res.remindTimes;
    }
}
