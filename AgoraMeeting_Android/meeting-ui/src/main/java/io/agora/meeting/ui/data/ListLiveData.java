package io.agora.meeting.ui.data;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.lifecycle.LiveData;

import java.util.ArrayList;
import java.util.List;

/**
 * Description:
 *
 *
 * @since 3/10/21
 */
public final class ListLiveData<T> extends LiveData<List<T>> {
    private static final Handler sMainHandler = new Handler(Looper.getMainLooper());

    private final List<T> mList = new ArrayList<>();
    private final Runnable notifyRun = () -> {
        synchronized (mList) {
            setValue(mList);
        }
    };

    public void add(T item) {
        synchronized (mList) {
            mList.add(item);
        }
        exeNotifyRun();
    }

    public int size(){
        return mList.size();
    }

    public void remove(T item) {
        synchronized (mList) {
            mList.remove(item);
        }
        exeNotifyRun();
    }

    public T get(int index){
        T item;
        synchronized (mList){
            item = mList.get(index);
        }
        return item;
    }

    public void replace(int index, T item){
        synchronized (mList){
            mList.remove(index);
            mList.add(index, item);
        }
    }

    public void changeItem(int index, @NonNull Iterator<T> iterator) {
        synchronized (mList) {
            T t = mList.get(index);
            iterator.change(t);
        }
        exeNotifyRun();
    }

    public void changeAll(@NonNull Iterator<T> iterator) {
        synchronized (mList) {
            for (T t : mList) {
                iterator.change(t);
            }
        }
        exeNotifyRun();
    }

    public void clean(boolean notify) {
        synchronized (mList) {
            mList.clear();
        }
        if (notify) {
            exeNotifyRun();
        }
    }


    private void exeNotifyRun() {
        sMainHandler.removeCallbacks(notifyRun);
        sMainHandler.post(notifyRun);
    }

    @Override
    protected void onActive() {
        super.onActive();
        exeNotifyRun();
    }

    @Override
    protected void onInactive() {
        super.onInactive();
        sMainHandler.removeCallbacks(notifyRun);
    }

    public interface Iterator<T> {
        void change(T item);
    }
}
