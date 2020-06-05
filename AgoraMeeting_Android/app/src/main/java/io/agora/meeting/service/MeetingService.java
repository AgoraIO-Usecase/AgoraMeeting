package io.agora.meeting.service;

import io.agora.meeting.annotaion.member.Role;
import io.agora.meeting.service.body.ResponseBody;
import io.agora.meeting.service.body.req.ApplyReq;
import io.agora.meeting.service.body.req.BoardReq;
import io.agora.meeting.service.body.req.ChatReq;
import io.agora.meeting.service.body.req.InviteReq;
import io.agora.meeting.service.body.req.MemberReq;
import io.agora.meeting.service.body.req.RoomEntryReq;
import io.agora.meeting.service.body.req.RoomReq;
import io.agora.meeting.service.body.req.ScreenReq;
import io.agora.meeting.service.body.res.RoomBoardRes;
import io.agora.meeting.service.body.res.RoomEntryRes;
import io.agora.meeting.service.body.res.RoomMemberRes;
import io.agora.meeting.service.body.res.RoomRes;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.POST;
import retrofit2.http.Path;
import retrofit2.http.Query;

public interface MeetingService {
    @POST("meeting/apps/{appId}/v1/room/entry")
    Call<ResponseBody<RoomEntryRes>> roomEntry(
            @Path("appId") String appId,
            @Body RoomEntryReq body
    );

    @GET("meeting/apps/{appId}/v1/room/{roomId}/board")
    Call<ResponseBody<RoomBoardRes>> roomBoard(
            @Path("appId") String appId,
            @Path("roomId") String roomId
    );

    @GET("meeting/apps/{appId}/v1/room/{roomId}")
    Call<ResponseBody<RoomRes>> room(
            @Path("appId") String appId,
            @Path("roomId") String roomId
    );

    @GET("meeting/apps/{appId}/v1/room/{roomId}/user/page")
    Call<ResponseBody<RoomMemberRes>> userPage(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Query("role") @Role int role,
            @Query("nextId") String nextId,
            @Query("count") int count
    );

    @POST("meeting/apps/{appId}/v1/room/{roomId}")
    Call<ResponseBody<Boolean>> room(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Body RoomReq body
    );

    @POST("meeting/apps/{appId}/v1/room/{roomId}/user/{userId}")
    Call<ResponseBody<Boolean>> roomUser(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Path("userId") String userId,
            @Body MemberReq body
    );

    @POST("meeting/apps/{appId}/v1/room/{roomId}/user/{userId}/host/invite")
    Call<ResponseBody<Boolean>> invite(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Path("userId") String userId,
            @Body InviteReq body
    );

    @POST("meeting/apps/{appId}/v1/room/{roomId}/user/{userId}/audience/apply")
    Call<ResponseBody<Boolean>> apply(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Path("userId") String userId,
            @Body ApplyReq body
    );

    @POST("meeting/apps/{appId}/v1/room/{roomId}/user/{userId}/screen")
    Call<ResponseBody<Boolean>> screen(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Path("userId") String userId,
            @Body ScreenReq body
    );

    @POST("meeting/apps/{appId}/v1/room/{roomId}/user/{userId}/board")
    Call<ResponseBody<Boolean>> board(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Path("userId") String userId,
            @Body BoardReq body
    );

    @POST("meeting/apps/{appId}/v1/room/{roomId}/user/{userId}/host")
    Call<ResponseBody<Boolean>> host(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Path("userId") String userId
    );

    @POST("meeting/apps/{appId}/v1/room/{roomId}/chat")
    Call<ResponseBody<Boolean>> roomChat(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Body ChatReq body
    );

    @POST("meeting/apps/{appId}/v1/room/{roomId}/user/{userId}/exit")
    Call<ResponseBody<Boolean>> roomExit(
            @Path("appId") String appId,
            @Path("roomId") String roomId,
            @Path("userId") String userId
    );
}
