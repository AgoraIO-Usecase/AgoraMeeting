package io.agora.log.service;

import io.agora.log.service.bean.ResponseBody;
import io.agora.log.service.bean.response.LogParamsRes;
import retrofit2.Call;
import retrofit2.http.GET;
import retrofit2.http.POST;
import retrofit2.http.Query;
import retrofit2.http.Url;

public interface LogService {
    @GET
    Call<ResponseBody<LogParamsRes>> logParams(
            @Url String url,
            @Query("appId") String appId,
            @Query("appCode") String appCode,
            @Query("appVersion") String appVersion,
            @Query("roomId") String roomId
    );

    @POST
    Call<ResponseBody<String>> logStsCallback(@Url String url);
}
