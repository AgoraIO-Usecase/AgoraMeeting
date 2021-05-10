package io.agora.meeting.core.http;

import androidx.annotation.Nullable;

import java.net.UnknownHostException;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import io.agora.meeting.core.annotaion.Keep;
import io.agora.meeting.core.http.body.ResponseBody;
import io.agora.meeting.core.http.callback.ThrowableCallback;
import io.agora.meeting.core.http.network.HttpException;
import io.agora.meeting.core.http.network.RetrofitManager;
import io.agora.meeting.core.utils.TimeSyncUtil;

@Keep
public final class BaseCallback<T> extends RetrofitManager.Callback<ResponseBody<T>> {
    private static final Map<String, Map<String, String>> errorMessagesDict = new HashMap<String, Map<String, String>>(){{
        put("zh", new HashMap<String, String>(){{
            put("-999999", "您的网络信号不佳");
            put("32409202", "该房间主持人数量已经达到最大值");
            put("32403100", "密码不正确");
            put("32409203", "房间内已经有主持人，请联系主持人指定您为主持人，最多3人同时为主持人");
            put("32409420", "白板分享正在进行中");
            put("32409300", "屏幕分享正在进行中");
            put("30404420", "白板已达到最大人数");
            put("32409200", "用户已经是主持人");
            put("20403002", "房间内人数已达上限");
            put("20403001", "房间内已达到主播数上限");
            put("20410200", "");
            put("32400005", "");
        }});
        put("en", new HashMap<String, String>(){{
            put("-999999", "Your network signal is poor");
            put("32409202", "This room already has max number of host");
            put("32403100", "Password is incorrect");
            put("32409203", "There is already a host in the room, please contact the host to designate you as the host, up to 3 people at the same time as the host");
            put("32409420", "Whiteboard is ongoing");
            put("32409300", "Screen share is ongoing");
            put("30404420", "The whiteboard participants has reached max number");
            put("32409200", "User is already the host");
            put("20403002", "The room is full!");
            put("20403001", "The number of broadcaster has reached max number  in the room!");
            put("20410200", "");
            put("32400005", "");
        }});
    }};


    public BaseCallback(@Nullable FailureCallback failure) {
        super(0, new ThrowableCallback<ResponseBody<T>>() {
            @Override
            public void onSuccess(ResponseBody<T> res) {
                TimeSyncUtil.syncLocalTimestamp(res.ts);
            }

            @Override
            public void onFailure(Throwable throwable) {
                checkError(throwable, failure);
            }
        });
    }

    public BaseCallback(@Nullable SuccessCallback<T> success, @Nullable FailureCallback failure) {
        super(0, new ThrowableCallback<ResponseBody<T>>() {
            @Override
            public void onSuccess(ResponseBody<T> res) {
                TimeSyncUtil.syncLocalTimestamp(res.ts);
                if (success != null) {
                    success.onSuccess(res.data);
                }
            }

            @Override
            public void onFailure(Throwable throwable) {
                checkError(throwable, failure);
            }
        });
    }

    /**
     * @param errorMessages 错误码字典
     */
    public static void setErrorMessagesDict(Map<String, Map<String, String>> errorMessages) {
        Set<String> keySet = errorMessages.keySet();
        for (String key : keySet) {
            Map<String, String> map = errorMessagesDict.get(key);
            Map<String, String> value = errorMessages.get(key);
            if (value == null) {
                continue;
            }
            if (map == null) {
                errorMessages.put(key, value);
            } else {
                map.putAll(value);
            }
        }
    }

    private static void checkError(Throwable throwable, FailureCallback failure) {
        String message = throwable.getMessage();
        int code = -1;
        if (throwable instanceof HttpException) {
            code = ((HttpException) throwable).getCode();
        }else if(throwable instanceof UnknownHostException){
            code = -999999;
        }

        Locale locale = Locale.getDefault();
        if (!Locale.SIMPLIFIED_CHINESE.getLanguage().equals(locale.getLanguage())) {
            locale = Locale.US;
        }
        String key = String.format("%s-%s", locale.getLanguage(), locale.getCountry()).toLowerCase();
        Map<String, String> stringMap = errorMessagesDict.get(key);
        if (stringMap != null) {
            String string = stringMap.get(code + "");
            if (string != null) {
                message = string;
            }
        }else{
            stringMap = errorMessagesDict.get(locale.getLanguage().toLowerCase());
            if (stringMap != null) {
                String string = stringMap.get(code + "");
                if (string != null) {
                    message = string;
                }
            }
        }

        if (failure != null) {
            failure.onFailure(new HttpException(code, message));
        }
    }

    @Keep
    public interface SuccessCallback<T> {
        void onSuccess(T data);
    }

    @Keep
    public interface FailureCallback {
        void onFailure(Throwable throwable);
    }
}
