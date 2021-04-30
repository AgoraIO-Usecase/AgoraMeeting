package io.agora.meeting.core.http.network;

import androidx.annotation.NonNull;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import io.agora.meeting.core.http.callback.ThrowableCallback;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.internal.platform.Platform;
import okhttp3.logging.HttpLoggingInterceptor;
import retrofit2.Call;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class RetrofitManager {
    private static RetrofitManager instance;

    private OkHttpClient client;
    private Map<String, String> headers = new HashMap<>();
    private HttpLoggingInterceptor.Logger logger;

    private RetrofitManager() {
        OkHttpClient.Builder clientBuilder = new OkHttpClient.Builder();
        clientBuilder.connectTimeout(30, TimeUnit.SECONDS);
        clientBuilder.readTimeout(30, TimeUnit.SECONDS);
        clientBuilder.addInterceptor(chain -> {
            Request request = chain.request();
            Request.Builder requestBuilder = request.newBuilder()
                    .method(request.method(), request.body());
            if (headers != null) {
                for (Map.Entry<String, String> entry : headers.entrySet()) {
                    requestBuilder.addHeader(entry.getKey(), entry.getValue());
                }
            }
            return chain.proceed(requestBuilder.build());
        });
        clientBuilder.addInterceptor(new HttpLoggingInterceptor(s -> {
            if (logger == null) {
                Platform.get().log(s, Platform.INFO, null);
            } else {
                logger.log(s);
            }
        }).setLevel(HttpLoggingInterceptor.Level.BODY));
        clientBuilder.addInterceptor(chain -> {
            okhttp3.Response response = chain.proceed(chain.request());
            if(response.code() != 500){
                return response;
            }
            return new okhttp3.Response.Builder(response)
                    .code(200)
                    .build();
        });
        client = clientBuilder.build();
    }

    public static RetrofitManager instance() {
        if (instance == null) {
            synchronized (RetrofitManager.class) {
                if (instance == null) {
                    instance = new RetrofitManager();
                }
            }
        }
        return instance;
    }

    public OkHttpClient getClient() {
        return client;
    }

    public void addHeader(@NonNull String key, @NonNull String value) {
        headers.put(key, value);
    }

    public void setAuth(String auth){
        headers.put("Authorization", getBasicAuth(auth));
    }

    private String getBasicAuth(String auth){
        String prefix = "Basic ";
        if (auth.startsWith(prefix)) {
            return auth;
        } else {
            return prefix + auth;
        }
    }

    public void setLogger(@NonNull HttpLoggingInterceptor.Logger logger) {
        this.logger = logger;
    }

    public <T> T getService(@NonNull String baseUrl, @NonNull Class<T> tClass) {
        Retrofit retrofit = new Retrofit.Builder()
                .client(client)
                .baseUrl(baseUrl)
                .addConverterFactory(GsonConverterFactory.create())
                .build();
        return retrofit.create(tClass);
    }

    public static class Callback<T extends BaseResponse<?>> implements retrofit2.Callback<T> {
        private int code;
        private io.agora.meeting.core.http.callback.Callback<T> callback;

        public Callback(int code, @NonNull io.agora.meeting.core.http.callback.Callback<T> callback) {
            this.code = code;
            this.callback = callback;
        }

        @Override
        public void onResponse(@NonNull Call<T> call, @NonNull Response<T> response) {
            if (response.errorBody() != null) {
                try {
                    throwableCallback(new Throwable(response.errorBody().string()));
                } catch (IOException e) {
                    throwableCallback(e);
                }
            } else {
                T body = response.body();
                if (body == null) {
                    throwableCallback(new Throwable("response body is null"));
                } else {
                    if (body.code != code) {
                        throwableCallback(new HttpException(body.code, body.msg.toString()));
                    } else {
                        callback.onSuccess(body);
                    }
                }
            }
        }

        @Override
        public void onFailure(@NonNull Call<T> call, @NonNull Throwable t) {
            throwableCallback(t);
        }

        private void throwableCallback(Throwable throwable) {
            if (callback instanceof ThrowableCallback) {
                ((ThrowableCallback<T>) callback).onFailure(throwable);
            }
        }
    }
}
