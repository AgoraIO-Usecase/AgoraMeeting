package io.agora.meeting.core.http;

import io.agora.meeting.core.annotaion.OS;
import io.agora.meeting.core.annotaion.Terminal;
import io.agora.meeting.core.http.body.ResponseBody;
import io.agora.meeting.core.http.body.resp.AppVersionResp;
import retrofit2.Call;
import retrofit2.http.GET;
import retrofit2.http.Path;
import retrofit2.http.Query;

/**
 * Description:
 *
 *
 * @since 3/1/21
 */
public interface SystemService {


    @GET("/scenario/meeting/apps/{appId}/v2/appVersion")
    Call<ResponseBody<AppVersionResp>> checkVersion(
            @Path("appId") String appId,
            @Query("osType") @OS int osType,
            @Query("terminalType") @Terminal int terminalType,
            @Query("appVersion") String appVersion);

}
