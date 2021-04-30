package io.agora.meeting.core.bean;

import io.agora.meeting.core.annotaion.Keep;

/**
 * Description:
 *
 *
 * @since 2/17/21
 */
@Keep
public final class ChatMessage {
    public long timestamp;
    public long messageId;
    public String fromUserId;
    public String fromUserName;
    public String content;

    public ChatMessage(long timestamp, long messageId, String fromUserId, String fromUserName, String content) {
        this.timestamp = timestamp;
        this.messageId = messageId;
        this.fromUserId = fromUserId;
        this.fromUserName = fromUserName;
        this.content = content;
    }
}
