package io.agora.meeting.ui.data;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.Observer;

import java.util.Objects;

public class CleanableLiveData<T> extends MutableLiveData<T>{

    private volatile boolean dataDirty = true;

    @Override
    public void setValue(T value) {
        dataDirty = false;
        super.setValue(value);
    }

    @Override
    public void postValue(T value) {
        dataDirty = false;
        super.postValue(value);
    }

    @Nullable
    @Override
    public T getValue() {
        if (dataDirty) {
            return null;
        }
        return super.getValue();
    }

    public void clean(){
        dataDirty = true;
        super.setValue(null);
    }

    @Override
    public void observe(@NonNull LifecycleOwner owner, @NonNull Observer<? super T> observer) {
        super.observe(owner, new InnerWrapObserver<>(observer));
    }

    @Override
    public void observeForever(@NonNull Observer<? super T> observer) {
        super.observeForever(new InnerWrapObserver<>(observer));
    }

    @Override
    public void removeObserver(@NonNull Observer<? super T> observer) {
        if(observer instanceof InnerWrapObserver){
            super.removeObserver(observer);
        }else{
            super.removeObserver(new InnerWrapObserver<>(observer));
        }
    }

    private class InnerWrapObserver<E extends T> implements Observer<E> {
        private final Observer<? super T> observer;

        private InnerWrapObserver(@NonNull Observer<? super T> observer){
            this.observer = observer;
        }

        @Override
        public void onChanged(E e) {
            if(!dataDirty){
                this.observer.onChanged(e);
            }
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;

            InnerWrapObserver<?> that = (InnerWrapObserver<?>) o;

            return Objects.equals(observer, that.observer);
        }

        @Override
        public int hashCode() {
            return observer != null ? observer.hashCode() : 0;
        }
    }
}
