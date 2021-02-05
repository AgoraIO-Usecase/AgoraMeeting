package io.agora.rtc.ss.utils;

import android.annotation.TargetApi;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.os.Build;

import androidx.annotation.RequiresApi;
import androidx.core.app.NotificationCompat;

import io.agora.rtc.ss.R;

public class NotificationHelper {

    public static Notification getForeNotification(Context context) {
        Notification notification;
        String eventTitle = context.getResources().getString(R.string.app_name);
        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, NotificationHelper.generateChannelId(context, 55431))
                .setContentTitle(eventTitle)
                .setContentText(eventTitle);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
            builder.setColor(context.getResources().getColor(android.R.color.black));
        notification = builder.build();
        notification.flags |= Notification.FLAG_ONGOING_EVENT;

        return notification;
    }

    public static String generateChannelId(Context ctx, int notification) {
        String channelId;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            channelId = NotificationHelper.createNotificationChannel(ctx, notification);
        } else {
            // If earlier version channel ID is not used
            // https://developer.android.com/reference/android/support/v4/app/NotificationCompat.Builder.html#NotificationCompat.Builder(android.content.Context)
            channelId = "";
        }
        return channelId;
    }

    @RequiresApi(Build.VERSION_CODES.O)
    @TargetApi(Build.VERSION_CODES.O)
    private static String createNotificationChannel(Context ctx, int notification) {


        String channelId;
        String channelName;

        NotificationChannel chan;

        switch (notification) {
            default:
                channelId = "generic_noti";
                channelName = "Generic";

                chan = new NotificationChannel(channelId,
                        channelName, NotificationManager.IMPORTANCE_NONE);
                break;

        }

        chan.setLockscreenVisibility(Notification.VISIBILITY_PRIVATE);
        NotificationManager service = (NotificationManager) ctx.getSystemService(Context.NOTIFICATION_SERVICE);
        service.createNotificationChannel(chan);
        return channelId;
    }
}
