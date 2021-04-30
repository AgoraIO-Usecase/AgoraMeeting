package io.agora.meeting.core.http;

import io.agora.meeting.core.http.body.ResponseBody;
import io.agora.meeting.core.http.body.req.ChatReq;
import io.agora.meeting.core.http.body.req.KickOutReq;
import io.agora.meeting.core.http.body.req.MuteAllReq;
import io.agora.meeting.core.http.body.req.TargetUserIdReq;
import io.agora.meeting.core.http.body.req.UserPermAccessReq;
import io.agora.meeting.core.http.body.req.UserPermCloseReq;
import io.agora.meeting.core.http.body.req.UserPermOpenReq;
import io.agora.meeting.core.http.body.req.UserUpdateReq;
import io.agora.meeting.core.http.body.resp.NullResp;
import io.agora.meeting.core.http.body.resp.ScreenStartResp;
import io.agora.meeting.core.http.body.resp.UserPermOpenResp;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.POST;
import retrofit2.http.PUT;
import retrofit2.http.Path;

/**
 * Description:
 *
 *
 * @since 2/7/21
 */
public interface UserService {


    @PUT("/scenario/meeting/apps/{appId}/v2/rooms/{roomId}/users/{userId}/userPermissions")
    Call<ResponseBody<NullResp>> changeUserPermissions(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Path("userId") String userId,
            @Body UserPermAccessReq body
    );

    /**
     * 转交主持人
     */
    @POST("/scenario/meeting/apps/{appId}/v2/rooms/{roomId}/users/{userId}/hosts/transfer")
    Call<ResponseBody<NullResp>> hostsTransfer(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Path("userId") String userId,
            @Body TargetUserIdReq body
    );

    /**
     * 设为主持人
     */
    @POST("/scenario/meeting/apps/{appId}/v2/rooms/{roomId}/users/{userId}/hosts/appoint")
    Call<ResponseBody<NullResp>> hostsAppoint(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Path("userId") String userId,
            @Body TargetUserIdReq body
    );


    /**
     * 放弃主持人
     */
    @POST("/scenario/meeting/apps/{appId}/v2/rooms/{roomId}/users/{userId}/hosts/abandon")
    Call<ResponseBody<NullResp>> hostsAbandon(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Path("userId") String userId
    );

    /**
     * 申请成为主持人
     */
    @POST("/scenario/meeting/apps/{appId}/v2/rooms/{roomId}/users/{userId}/hosts/apply")
    Call<ResponseBody<NullResp>> hostsApply(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Path("userId") String userId
    );


    /**
     * 踢人
     */
    @POST("/scenario/meeting/apps/{appId}/v2/rooms/{roomId}/users/{userId}/kickOut")
    Call<ResponseBody<NullResp>> kickOut(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Path("userId") String userId,
            @Body KickOutReq body
    );

    /**
     * 更新用户信息
     */
    @PUT("/scenario/meeting/apps/{appId}/v2/rooms/{roomId}/users/{userId}")
    Call<ResponseBody<NullResp>> updateUserInfo(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Path("userId") String userId,
            @Body UserUpdateReq body
    );

    @POST("/scenario/meeting/apps/{appId}/v2/rooms/{roomId}/users/{userId}/screen/start")
    Call<ResponseBody<ScreenStartResp>> startScreen(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Path("userId") String userId
    );


    @POST("/scenario/meeting/apps/{appId}/v2/rooms/{roomId}/users/{userId}/screen/stop")
    Call<ResponseBody<NullResp>> stopScreen(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Path("userId") String userId
    );


    @POST("/scenario/meeting/apps/{appId}/v2/rooms/{roomId}/users/{userId}/board/start")
    Call<ResponseBody<NullResp>> startBoard(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Path("userId") String userId
    );

    @POST("/scenario/meeting/apps/{appId}/v2/rooms/{roomId}/users/{userId}/board/stop")
    Call<ResponseBody<NullResp>> stopBoard(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Path("userId") String userId
    );

    @POST("/scenario/meeting/apps/{appId}/v2/rooms/{roomId}/users/{userId}/board/interact")
    Call<ResponseBody<NullResp>> applyBoardInteract(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Path("userId") String userId
    );


    @POST("/scenario/meeting/apps/{appId}/v2/rooms/{roomId}/users/{userId}/board/leave")
    Call<ResponseBody<NullResp>> cancelBoardInteract(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Path("userId") String userId
    );


    @POST("/scenario/meeting/apps/{appId}/v2/rooms/{roomId}/users/{userId}/userPermissions/close")
    Call<ResponseBody<NullResp>> closeUserPermissions(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Path("userId") String userId,
            @Body UserPermCloseReq body
    );

    @POST("/scenario/meeting/apps/{appId}/v2/rooms/{roomId}/users/{userId}/requests")
    Call<ResponseBody<UserPermOpenResp>> requestUserPermissions(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Path("userId") String userId,
            @Body UserPermOpenReq body
    );

    @POST("/scenario/meeting/apps/{appId}/v2/rooms/{roomId}/users/{userId}/requests/{requestId}/cancel")
    Call<ResponseBody<NullResp>> cancelUserPermissionsReq(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Path("userId") String userId,
            @Path("requestId") String requestId
    );

    @POST("/scenario/meeting/apps/{appId}/v2/rooms/{roomId}/users/{userId}/requests/{requestId}/accept")
    Call<ResponseBody<NullResp>> acceptUserPermissionsReq(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Path("userId") String userId,
            @Path("requestId") String requestId,
            @Body TargetUserIdReq body
    );

    @POST("/scenario/meeting/apps/{appId}/v2/rooms/{roomId}/users/{userId}/requests/{requestId}/reject")
    Call<ResponseBody<NullResp>> rejectUserPermissionsReq(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Path("userId") String userId,
            @Path("requestId") String requestId,
            @Body TargetUserIdReq body
    );


    @POST("/scenario/meeting/apps/{appId}/v2/rooms/{roomId}/users/{userId}/userPermissions/closeAll")
    Call<ResponseBody<NullResp>> muteAll(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Path("userId") String userId,
            @Body MuteAllReq body
    );

    @POST("scenario/meeting/apps/{appId}/v2/rooms/{roomId}/users/{userId}/chat/channel")
    Call<ResponseBody<NullResp>> chat(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Path("userId") String userId,
            @Body ChatReq body
    );

}
