package io.agora.meeting.util;

import android.app.AlertDialog;
import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;

import org.jetbrains.annotations.NotNull;

import java.util.HashMap;
import java.util.Map;

import io.agora.meeting.MainApplication;
import io.agora.meeting.R;
import io.agora.meeting.annotaion.message.AdminAction;
import io.agora.meeting.annotaion.message.NormalAction;
import io.agora.meeting.annotaion.room.Module;
import io.agora.meeting.data.Me;
import io.agora.meeting.data.Member;
import io.agora.meeting.data.PeerMsg;
import io.agora.meeting.viewmodel.MeetingViewModel;

public class TipsUtil {
    private static final Map<Integer, Map<Integer, Integer>> adminTitles = new HashMap<Integer, Map<Integer, Integer>>() {{
        put(Module.AUDIO, new HashMap<Integer, Integer>() {{
            put(AdminAction.INVITE, R.string.invite_audio_title);
            put(AdminAction.REJECT_APPLY, R.string.reject_audio_apply_title);
        }});
        put(Module.VIDEO, new HashMap<Integer, Integer>() {{
            put(AdminAction.INVITE, R.string.invite_video_title);
//            put(HostAction.REJECT_APPLY, R.string.reject_video_apply_title);
        }});
        put(Module.BOARD, new HashMap<Integer, Integer>() {{
//            put(AdminAction.INVITE, R.string.invite_board_title);
            put(AdminAction.REJECT_APPLY, R.string.reject_board_apply_title);
        }});
    }};
    private static final Map<Integer, Map<Integer, Integer>> normalTitles = new HashMap<Integer, Map<Integer, Integer>>() {{
        put(Module.AUDIO, new HashMap<Integer, Integer>() {{
            put(NormalAction.APPLY, R.string.apply_audio_title);
            put(NormalAction.REJECT_INVITE, R.string.reject_audio_invite_title);
        }});
        put(Module.VIDEO, new HashMap<Integer, Integer>() {{
//            put(NormalAction.APPLY, R.string.apply_video_title);
            put(NormalAction.REJECT_INVITE, R.string.reject_video_invite_title);
        }});
        put(Module.BOARD, new HashMap<Integer, Integer>() {{
            put(NormalAction.APPLY, R.string.apply_board_title);
//            put(NormalAction.REJECT_INVITE, R.string.reject_board_invite_title);
        }});
    }};

    public static void processAdmin(Context context, PeerMsg.Admin admin, MeetingViewModel viewModel) {
        int module = admin.data.module;
        int action = admin.data.action;
        String userName = admin.data.userName;
        AlertDialog.Builder builder = new AlertDialog.Builder(context);

        Map<Integer, Integer> moduleTitles = adminTitles.get(module);
        if (moduleTitles == null) return;
        Integer actionTitle = moduleTitles.get(action);
        if (actionTitle == null) return;
        builder.setTitle(context.getString(actionTitle, userName));

        if (action == AdminAction.INVITE) {
            builder.setMessage(R.string.invite_message);
            builder.setPositiveButton(R.string.accept, (dialog, which) -> viewModel.acceptInvite(admin));
            builder.setNegativeButton(R.string.reject, (dialog, which) -> viewModel.rejectInvite(admin));
        } else if (action == AdminAction.REJECT_APPLY) {
            builder.setPositiveButton(R.string.know, null);
        }

        builder.show();
    }

    public static void processNormal(Context context, PeerMsg.Normal normal, MeetingViewModel viewModel) {
        int module = normal.data.module;
        int action = normal.data.action;
        String userName = normal.data.userName;
        AlertDialog.Builder builder = new AlertDialog.Builder(context);

        Map<Integer, Integer> moduleTitles = normalTitles.get(module);
        if (moduleTitles == null) return;
        Integer actionTitle = moduleTitles.get(action);
        if (actionTitle == null) return;
        builder.setTitle(context.getString(actionTitle, userName));

        if (action == NormalAction.APPLY) {
            builder.setMessage(R.string.apply_message);
            builder.setPositiveButton(R.string.accept, (dialog, which) -> viewModel.acceptApply(normal));
            builder.setNegativeButton(R.string.reject, (dialog, which) -> viewModel.rejectApply(normal));
        } else if (action == NormalAction.REJECT_INVITE) {
            builder.setPositiveButton(R.string.know, null);
        }

        builder.show();
    }

    @StringRes
    public static int getBoardMenuTitle(@NonNull MeetingViewModel viewModel, @Nullable Member member) {
        Me me = viewModel.getMeValue();
        if (viewModel.isBoardSharing()) {
            if (viewModel.isBoardHost(me)) {
                if (viewModel.isMe(member)) {
                    return R.string.close_board;
                } else {
                    if (viewModel.isGrantBoard(member)) {
                        if (viewModel.isHost(member)) return 0;

                        return R.string.cancel_board;
                    } else {
                        return R.string.authorize_board;
                    }
                }
            } else {
                if (!viewModel.isMe(member)) return 0;

                if (viewModel.isGrantBoard(member)) {
                    if (viewModel.isHost(member)) return 0;

                    return R.string.cancel_board;
                } else {
                    return R.string.apply_board;
                }
            }
        } else {
            if (!viewModel.isMe(member)) return 0;

            // TODO hide open whiteboard interaction
            return 0;
//            return R.string.open_board;
        }
    }

    public static String getMemberName(@NotNull Member member) {
        StringBuilder builder = new StringBuilder(member.userName);
        if (member instanceof Me) {
            builder.append(MainApplication.instance.getString(R.string.me));
        }
        if (member.isHost()) {
            builder.append(MainApplication.instance.getString(R.string.host));
        }
        return builder.toString();
    }
}
