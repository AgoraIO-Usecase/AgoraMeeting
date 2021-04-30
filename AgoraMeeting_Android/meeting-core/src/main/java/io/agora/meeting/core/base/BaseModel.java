package io.agora.meeting.core.base;

import android.util.SparseArray;

import java.util.ArrayList;

/**
 * Description:
 *
 *
 * @since 2/9/21
 */
public class BaseModel<Callback> {
    protected final ArrayList<Callback> mObservers = new ArrayList<Callback>();
    private final SparseArray<Object> tags = new SparseArray<>();
    private volatile boolean isReleased = false;


    public void setTag(int key, Object value){
        tags.put(key, value);
    }

    public <T> T getTag(int key) {
        return (T) tags.get(key);
    }


    public void registerCallback(Callback observer){
        if (observer == null) {
            throw new IllegalArgumentException("The observer is null.");
        }
        synchronized(mObservers) {
            if (mObservers.contains(observer)) {
                throw new IllegalStateException("Observer " + observer + " is already registered.");
            }
            mObservers.add(observer);
        }
    }

    public void unregisterCallback(Callback observer){
        if (observer == null) {
            throw new IllegalArgumentException("The observer is null.");
        }
        synchronized(mObservers) {
            int index = mObservers.indexOf(observer);
            if (index == -1) {
                throw new IllegalStateException("Observer " + observer + " was not registered.");
            }
            mObservers.remove(index);
        }
    }

    public void unregisterAll() {
        synchronized(mObservers) {
            mObservers.clear();
        }
    }

    public void release() {
        unregisterAll();
        isReleased = true;
    }

    public boolean isReleased() {
        return isReleased;
    }

    protected void invokeCallback(CallbackInvoker<Callback> invoker){
        synchronized (mObservers){
            for (int i = mObservers.size() - 1; i >= 0; i--) {
                invoker.invoke(mObservers.get(i));
            }
        }
    }

}
