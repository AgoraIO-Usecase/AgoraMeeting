package io.agora.meeting.service;

import java.util.Map;

import io.agora.base.annotation.OS;
import io.agora.base.annotation.Terminal;
import io.agora.meeting.BuildConfig;
import io.agora.meeting.service.body.ResponseBody;
import io.agora.meeting.service.body.res.AppVersionRes;
import retrofit2.Call;
import retrofit2.http.GET;

public interface CommonService {
    @GET("meeting/v1/app/version?appCode=" + BuildConfig.CODE + "&osType=" + OS.ANDROID + "&terminalType=" + Terminal.PHONE + "&appVersion=" + BuildConfig.VERSION_NAME)
    Call<ResponseBody<AppVersionRes>> appVersion();

    @GET("meeting/v1/multi/language")
    Call<ResponseBody<Map<String, Map<Integer, String>>>> language();
}
