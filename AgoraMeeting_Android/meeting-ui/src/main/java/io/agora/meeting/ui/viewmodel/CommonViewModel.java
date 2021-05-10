package io.agora.meeting.ui.viewmodel;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import io.agora.meeting.core.http.body.resp.AppVersionResp;
import io.agora.meeting.ui.MeetingApplication;
import io.agora.meeting.ui.util.ToastUtil;

public class CommonViewModel extends ViewModel {

    public final MutableLiveData<AppVersionResp> versionInfo = new MutableLiveData<>();

    public void checkVersion() {
        MeetingApplication.getMeetingEngine().checkVersion(versionInfo::setValue, throwable -> {
            versionInfo.setValue(null);
            ToastUtil.showShort(throwable.getMessage());
        });
    }

}
