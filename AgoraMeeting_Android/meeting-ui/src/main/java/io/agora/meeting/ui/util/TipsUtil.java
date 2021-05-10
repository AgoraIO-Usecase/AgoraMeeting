package io.agora.meeting.ui.util;

import android.content.Context;
import android.text.TextUtils;

import androidx.appcompat.app.AlertDialog;

import java.util.HashMap;
import java.util.Map;

import io.agora.meeting.core.annotaion.ActionMsgType;
import io.agora.meeting.core.annotaion.ApproveAction;
import io.agora.meeting.core.annotaion.ApproveRequest;
import io.agora.meeting.core.bean.ActionMessage;
import io.agora.meeting.core.model.UserModel;
import io.agora.meeting.ui.R;

public class TipsUtil {
    private static final Map<String, Map<Integer, Integer>> applyTitles = new HashMap<String, Map<Integer, Integer>>() {{
        put(ApproveRequest.CAMERA, new HashMap<Integer, Integer>() {{
            put(ApproveAction.APPLY, R.string.notify_popup_apply_video_title);
            put(ApproveAction.REJECT, R.string.notify_popup_reject_video_apply_title);
            put(ApproveAction.ACCEPT, R.string.notify_popup_accept_video_apply_title);
        }});
        put(ApproveRequest.MIC, new HashMap<Integer, Integer>() {{
            put(ApproveAction.APPLY, R.string.notify_popup_apply_audio_title);
            put(ApproveAction.REJECT, R.string.notify_popup_reject_audio_apply_title);
            put(ApproveAction.ACCEPT, R.string.notify_popup_accept_audio_apply_title);
        }});
    }};


    public static void processApply(Context context, ActionMessage message, UserModel userModel) {
        if(message == null || message.type != ActionMsgType.USER_APPROVE || TextUtils.isEmpty(message.userName)){
            return;
        }
        ActionMessage.Approve approve = (ActionMessage.Approve) message;
        String process = approve.requestId;
        int action = approve.action;
        String userName = message.userName;
        AlertDialog.Builder builder = new AlertDialog.Builder(context);

        Map<Integer, Integer> moduleTitles = applyTitles.get(process);
        if (moduleTitles == null) return;
        Integer actionTitle = moduleTitles.get(action);
        if (actionTitle == null) return;
        builder.setMessage(context.getString(actionTitle, userName));

        if (action == ApproveAction.APPLY) {
            builder.setTitle(R.string.notify_popup_apply_message);
            builder.setPositiveButton(R.string.cmm_accept, (dialog, which) -> userModel.acceptPermRequest(process, message.userId, null));
            builder.setNegativeButton(R.string.cmm_reject, (dialog, which) -> userModel.rejectPermRequest(process, message.userId, null));
        } else{
            builder.setPositiveButton(R.string.cmm_know, null);
        }

        builder.show();
    }

}
