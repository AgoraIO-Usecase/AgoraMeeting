package io.agora.meeting.data;

import io.agora.meeting.service.body.res.RoomRes;

public class Room {
    public String roomId;
    public String roomName;
    public String channelName;
    public String password;
    public long startTime;

    public Room(RoomRes.Room room) {
        roomId = room.roomId;
        roomName = room.roomName;
        channelName = room.channelName;
        password = room.password;
        startTime = room.startTime;
    }
}
