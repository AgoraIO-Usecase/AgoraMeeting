package io.agora.meeting.util;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.Observer;

import com.jeremyliao.liveeventbus.LiveEventBus;

import io.agora.meeting.R;
import io.agora.meeting.annotaion.EventType;
import io.agora.meeting.annotaion.room.GlobalModuleState;
import io.agora.meeting.service.body.res.AppVersionRes;

public class Events {
    private static <T> void post(@EventType String eventType, Class<T> eventClass, T event) {
        LiveEventBus.get(eventType, eventClass).post(event);
    }

    private static <T> void postDelay(@EventType String eventType, Class<T> eventClass, T event, long delay) {
        LiveEventBus.get(eventType, eventClass).postDelay(event, delay);
    }

    private static <T> void observe(@EventType String eventType, Class<T> eventClass, @NonNull LifecycleOwner owner, @NonNull Observer<T> observer) {
        LiveEventBus.get(eventType, eventClass).observe(owner, observer);
    }

    private static <T> void removeObserver(@EventType String eventType, Class<T> eventClass, @NonNull Observer<T> observer) {
        LiveEventBus.get(eventType, eventClass).removeObserver(observer);
    }

    public static class AlertEvent {
        @StringRes
        public int title;
        @StringRes
        public int message;
        @StringRes
        public int positive = R.string.know;

        private AlertEvent(@GlobalModuleState int moduleState) {
            switch (moduleState) {
                case GlobalModuleState.ENABLE:
                    title = R.string.enable_audio_title;
                    message = R.string.enable_audio_message;
                    break;
                case GlobalModuleState.CLOSE:
                    title = R.string.mute_audio_title;
                    message = R.string.close_audio_message;
                    break;
                case GlobalModuleState.DISABLE:
                    title = R.string.mute_audio_title;
                    message = R.string.disable_audio_message;
                    break;
            }
        }

        public static void setEvent(@GlobalModuleState int moduleState) {
            post(EventType.ALERT, AlertEvent.class, new AlertEvent(moduleState));
        }

        public static void addListener(@NonNull LifecycleOwner owner, @NonNull Observer<AlertEvent> observer) {
            observe(EventType.ALERT, AlertEvent.class, owner, observer);
        }
    }

    public static class KickEvent {
        public static void setEvent() {
            post(EventType.KICK, KickEvent.class, null);
        }

        public static void addListener(@NonNull LifecycleOwner owner, @NonNull Observer<KickEvent> observer) {
            observe(EventType.KICK, KickEvent.class, owner, observer);
        }
    }

    public static class TimeEvent {
        public long time;

        public static void setEvent(long startTime) {
            postDelay(EventType.TIME, TimeEvent.class, new TimeEvent() {{
                time = startTime;
            }}, 1000);
        }

        public static void addListener(@NonNull LifecycleOwner owner, @NonNull Observer<TimeEvent> observer) {
            observe(EventType.TIME, TimeEvent.class, owner, observer);
        }
    }

    public static class UpgradeEvent extends AppVersionRes {
        public UpgradeEvent(AppVersionRes res) {
            super(res);
        }

        public static void setEvent(@Nullable AppVersionRes version) {
            if (version == null) return;
            post(EventType.UPGRADE, UpgradeEvent.class, new UpgradeEvent(version));
        }

        public static void addListener(@NonNull LifecycleOwner owner, @NonNull Observer<UpgradeEvent> observer) {
            observe(EventType.UPGRADE, UpgradeEvent.class, owner, observer);
        }

        public static void removeListener(@NonNull Observer<UpgradeEvent> observer) {
            removeObserver(EventType.UPGRADE, UpgradeEvent.class, observer);
        }
    }
}
