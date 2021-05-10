package io.agora.meeting.ui.data;

import android.os.Handler;
import android.os.Looper;

import androidx.lifecycle.LiveData;

import java.util.ArrayDeque;
import java.util.Queue;

/**
 * Description:
 *
 *
 * @since 3/10/21
 */
public final class QueueLiveData<T> extends LiveData<T> {
    private static final Handler sMainHandler = new Handler(Looper.getMainLooper());

    private final Queue<T> queue = new ArrayDeque<>();
    private final Runnable deQueueRun = this::deQueueAll;

    @Override
    public void postValue(T value) {
        synchronized (queue){
            queue.offer(value);
        }
        exeDeQueueRun();
    }

    private void exeDeQueueRun() {
        sMainHandler.removeCallbacks(deQueueRun);
        sMainHandler.post(deQueueRun);
    }

    @Override
    public void setValue(T value) {
        synchronized (queue){
            queue.offer(value);
        }
        deQueueAll();
    }

    private void deQueueAll(){
        if (hasActiveObservers()) {
            synchronized (queue){
                T poll = queue.poll();
                while (poll != null){
                    super.setValue(poll);
                    poll = queue.poll();
                }
            }
        }
    }

    @Override
    protected void onActive() {
        super.onActive();
        exeDeQueueRun();
    }

    @Override
    protected void onInactive() {
        super.onInactive();
        sMainHandler.removeCallbacks(deQueueRun);
    }
}
