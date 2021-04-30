package io.agora.meeting.ui.data;

import android.view.View;

import io.agora.meeting.core.bean.ActionMessage;
import io.agora.meeting.ui.annotation.ActionMsgShowType;

/**
 * Description:
 *
 *
 * @since 3/5/21
 */
public final class ActionWrapMsg {
    public ActionMessage message;

    public View.OnClickListener actionClick;
    public String actionText;
    public long actionCountDownEndTime;

    public boolean hasRead = false;
    @ActionMsgShowType
    public int type;
    public String content;

    public boolean showTime = false;
    public Object tag;

    public ActionWrapMsg(ActionMessage message, @ActionMsgShowType int type, String content){
        this.message = message;
        this.type = type;
        this.content = content;
    }

    public ActionWrapMsg(){}

}
