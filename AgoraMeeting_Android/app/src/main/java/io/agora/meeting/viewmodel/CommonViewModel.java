package io.agora.meeting.viewmodel;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import java.util.Map;

import io.agora.base.network.RetrofitManager;
import io.agora.meeting.BuildConfig;
import io.agora.meeting.base.BaseCallback;
import io.agora.meeting.service.CommonService;
import io.agora.meeting.service.body.res.AppVersionRes;
import io.agora.meeting.util.Events;

public class CommonViewModel extends ViewModel {
    public static final MutableLiveData<Map<String, Map<Integer, String>>> multiLanguage = new MutableLiveData<>();

    public final MutableLiveData<AppVersionRes> appVersion = new MutableLiveData<>();

    private CommonService service;

    public CommonViewModel() {
        service = RetrofitManager.instance()
                .getService(BuildConfig.API_BASE_URL, CommonService.class);
    }

    public void checkVersion(boolean isInit) {
        service.appVersion()
                .enqueue(new BaseCallback<>(data -> {
                    if (appVersion.getValue() == null || !isInit) {
                        Events.UpgradeEvent.setEvent(data);
                    }
                    appVersion.postValue(data);
                }));
    }

    public void initMultiLanguage() {
        service.language().enqueue(new BaseCallback<>(multiLanguage::postValue));
    }
}
