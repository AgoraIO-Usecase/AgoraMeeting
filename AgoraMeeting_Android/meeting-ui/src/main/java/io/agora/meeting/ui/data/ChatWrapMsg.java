package io.agora.meeting.ui.data;

import io.agora.meeting.core.bean.ChatMessage;
import io.agora.meeting.ui.annotation.ChatState;

/**
 * Description:
 *
 *
 * @since 3/10/21
 */
public final class ChatWrapMsg {
    public ChatMessage message;

    public boolean isFromMyself;
    public boolean hasRead = false;

    @ChatState
    public int state = ChatState.SUCCESS;

    public boolean showTime = false;

}
