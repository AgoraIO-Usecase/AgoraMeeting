package io.agora.meeting.data;

public class BaseMsg<T> {
    public int cmd;
    public int version;
    public long timestamp;
    public T data;
}
