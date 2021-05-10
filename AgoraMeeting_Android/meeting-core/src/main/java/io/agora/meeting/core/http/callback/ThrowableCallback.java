package io.agora.meeting.core.http.callback;

import androidx.annotation.Nullable;

public interface ThrowableCallback<T> extends Callback<T> {
    void onFailure(@Nullable Throwable throwable);
}
