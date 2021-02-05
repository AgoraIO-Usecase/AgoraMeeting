package io.agora.rtc.ss.utils;

import java.util.ArrayDeque;
import java.util.Queue;

/**
 * Description:
 *
 * @author xcz
 * @since 2/5/21
 */
public class SimpleSafeData<T> {
    private T data;
    private final Queue<Runnable> runnableQueue = new ArrayDeque<>();

    public T getData() {
        return data;
    }

    public synchronized void setData(T data) {
        this.data = data;
        if (data != null) {
            Runnable poll = runnableQueue.poll();
            while (poll != null){
                poll.run();
                poll = runnableQueue.poll();
            }
        }
    }

    public void clean() {
        this.data = null;
        this.runnableQueue.clear();
    }

    public synchronized void exec(Runnable runnable) {
        if (data != null) {
            runnable.run();
        } else {
            runnableQueue.add(runnable);
        }
    }

}
