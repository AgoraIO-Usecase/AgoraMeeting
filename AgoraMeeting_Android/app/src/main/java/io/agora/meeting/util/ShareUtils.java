package io.agora.meeting.util;

import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;

import io.agora.meeting.R;
import io.agora.meeting.data.Me;
import io.agora.meeting.data.Room;

/**
 * Description:
 *
 * @author xcz
 * @since 1/27/21
 */
public class ShareUtils {


    public static void shareMeetingInfo(Context context, Room room, Me me){
        String meetingShareInfo = getMeetingShareInfo(context, room, me);
        shareTextBySystem(context, meetingShareInfo);
    }

    private static String getMeetingShareInfo(Context context, Room room, Me me){
        Resources resources = context.getResources();
        String shareInfo = resources.getString(R.string.meeting_name, room.roomName) +
                "\n" + resources.getString(R.string.meeting_pwd, room.password) +
                "\n" + resources.getString(R.string.invited_by, me.userName) +
                "\n" + resources.getString(R.string.web_link, resources.getString(R.string.web_url)) +
                "\n" + resources.getString(R.string.android_link, resources.getString(R.string.android_url)) +
                "\n" + resources.getString(R.string.ios_link, resources.getString(R.string.ios_url));
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
