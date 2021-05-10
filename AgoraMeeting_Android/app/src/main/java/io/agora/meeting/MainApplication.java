package io.agora.meeting;

import io.agora.meeting.core.MeetingConfig;
import io.agora.meeting.ui.MeetingApplication;

public class MainApplication extends MeetingApplication {

    @Override
    protected MeetingConfig getMeetingConfig() {
        MeetingConfig meetingConfig = new MeetingConfig();
        meetingConfig.appId = getString(R.string.agora_app_id);
        meetingConfig.customId = getString(R.string.agora_customer_id);
        meetingConfig.customCer = getString(R.string.agora_customer_cer);
        return meetingConfig;
    }

    @Override
    protected String getBuglyAppId() {
        return getString(R.string.bugly_app_id);
    }

}
