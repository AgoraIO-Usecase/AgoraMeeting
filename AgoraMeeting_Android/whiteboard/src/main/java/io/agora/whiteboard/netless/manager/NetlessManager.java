package io.agora.whiteboard.netless.manager;

import com.herewhite.sdk.domain.Promise;
import com.herewhite.sdk.domain.SDKError;

abstract class NetlessManager<T> {
    T t;
    Promise<T> promise = new Promise<T>() {
        @Override
        public void then(T t) {
            NetlessManager.this.t = t;
            onSuccess(t);
        }

        @Override
        public void catchEx(SDKError t) {
            onFail(t);
        }
    };

    abstract void onSuccess(T t);

    abstract void onFail(SDKError error);

}
