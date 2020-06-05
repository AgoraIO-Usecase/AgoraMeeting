package io.agora.meeting.base;

import android.text.TextUtils;

import androidx.annotation.Nullable;

import java.util.Locale;
import java.util.Map;

import io.agora.base.ToastManager;
import io.agora.base.callback.ThrowableCallback;
import io.agora.base.network.BusinessException;
import io.agora.base.network.RetrofitManager;
import io.agora.meeting.MainApplication;
import io.agora.meeting.R;
import io.agora.meeting.service.body.ResponseBody;
import io.agora.meeting.viewmodel.CommonViewModel;

public class BaseCallback<T> extends RetrofitManager.Callback<ResponseBody<T>> {
    public BaseCallback(@Nullable SuccessCallback<T> callback) {
        super(0, new ThrowableCallback<ResponseBody<T>>() {
            @Override
            public void onSuccess(ResponseBody<T> res) {
                if (callback != null) {
                    callback.onSuccess(res.data);
                }
            }

            @Override
            public void onFailure(Throwable throwable) {
                checkError(throwable);
            }
        });
    }

    public BaseCallback(@Nullable SuccessCallback<T> success, @Nullable FailureCallback failure) {
        super(0, new ThrowableCallback<ResponseBody<T>>() {
            @Override
            public void onSuccess(ResponseBody<T> res) {
                if (success != null) {
                    success.onSuccess(res.data);
                }
            }

            @Override
            public void onFailure(Throwable throwable) {
                checkError(throwable);
                if (failure != null) {
                    failure.onFailure(throwable);
                }
            }
        });
    }

    private static void checkError(Throwable throwable) {
        String message = throwable.getMessage();
        if (throwable instanceof BusinessException) {
            int code = ((BusinessException) throwable).getCode();
            Map<String, Map<Integer, String>> languages = CommonViewModel.multiLanguage.getValue();
            if (languages != null) {
                Locale locale = Locale.getDefault();
                if (!Locale.SIMPLIFIED_CHINESE.toString().equals(locale.toString())) {
                    locale = Locale.US;
                }
                String key = String.format("%s-%s", locale.getLanguage(), locale.getCountry()).toLowerCase();
                Map<Integer, String> stringMap = languages.get(key);
                if (stringMap != null) {
                    String string = stringMap.get(code);
                    if (!TextUtils.isEmpty(string)) {
                        message = string;
                    }
                }
            }
            if (TextUtils.isEmpty(message)) {
                message = MainApplication.instance.getString(R.string.request_error, code);
            }
        }
        if (!TextUtils.isEmpty(message)) {
            ToastManager.showShort(message);
        }
    }

    public interface SuccessCallback<T> {
        void onSuccess(T data);
    }

    public interface FailureCallback {
        void onFailure(Throwable throwable);
    }
}
