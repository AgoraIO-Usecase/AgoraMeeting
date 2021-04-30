package io.agora.meeting.ui.util;

import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;

import io.agora.meeting.core.model.RoomModel;
import io.agora.meeting.core.model.UserModel;
import io.agora.meeting.ui.R;

/**
 * Description:
 *
 *
 * @since 1/27/21
 */
public class ShareUtils {


    public static void shareMeetingInfo(Context context, RoomModel room){
        String meetingShareInfo = getMeetingShareInfo(context, room, room.getUserModelByUserId(room.getLocalUserId()));
        shareTextBySystem(context, meetingShareInfo);
    }

    public static String getMeetingShareInfo(Context context, RoomModel room, UserModel me){
        Resources resources = context.getResources();
        String shareInfo = resources.getString(R.string.invite_meeting_name, room.roomName) +
                "\n" + resources.getString(R.string.invite_meeting_pwd, room.roomPwd) +
                "\n" + resources.getString(R.string.invite_invited_by, me.getUserName()) +
                //"\n" + resources.getString(R.string.invite_web_link, resources.getString(R.string.web_url)) +
                "\n" + resources.getString(R.string.invite_android_link, resources.getString(R.string.android_url)) +
                "\n" + resources.getString(R.string.invite_ios_link, resources.getString(R.string.ios_url));
        return shareInfo;
    }

    private static void shareTextBySystem(Context context, String content){
        Intent sendIntent = new Intent();
        sendIntent.setAction(Intent.ACTION_SEND);
        sendIntent.putExtra(Intent.EXTRA_TEXT, content);
        sendIntent.setType("text/plain");
        context.startActivity(Intent.createChooser(sendIntent, ""));
    }
}
