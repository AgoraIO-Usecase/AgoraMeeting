package io.agora.rtc.ss.utils;

import androidx.annotation.NonNull;

import java.util.ArrayDeque;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Queue;
import java.util.Set;

public class SimpleSafeData<T> {
    private T data;
    private T originData;
    private final Queue<Callback<T>> runnableQueue = new ArrayDeque<>();
    private final Map<T, Callback<T>> runnableMap = new LinkedHashMap<>();

    public SimpleSafeData(){}

    public SimpleSafeData(T data){
        this.originData = data;
        this.data = data;
    }

    public T getData() {
        return data;
    }

    public synchronized void setData(T data) {
        this.data = data;
        if (data != null) {
            Callback<T> poll = runnableQueue.poll();
            while (poll != null) {
                poll.run(data);
                poll = runnableQueue.poll();
            }

            Set<T> mapKeys = runnableMap.keySet();
            for (T mapKey : mapKeys) {
                if(data.equals(mapKey)){
                    runnableMap.get(mapKey).run(data);
                }
            }
        }
    }

    public void clean() {
        this.data = originData;
        this.runnableQueue.clear();
        this.runnableMap.clear();
    }

    public int getRunnableSize(){
        return runnableQueue.size() + runnableMap.size();
    }

    public synchronized void execOnce(Callback<T> runnable) {
        if (data != null) {
            runnable.run(data);
        } else {
            runnableQueue.add(runnable);
        }
    }

    public synchronized void execWhen(Callback<T> runnable, @NonNull T when){
        if (when.equals(data)) {
            runnable.run(data);
        } else {
            runnableMap.put(when, runnable);
        }
    }

    public interface Callback<T> {
        void run(T data);
    }
}
