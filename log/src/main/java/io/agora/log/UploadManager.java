package io.agora.log;

import android.content.Context;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.alibaba.sdk.android.oss.ClientException;
import com.alibaba.sdk.android.oss.OSS;
import com.alibaba.sdk.android.oss.OSSClient;
import com.alibaba.sdk.android.oss.ServiceException;
import com.alibaba.sdk.android.oss.callback.OSSCompletedCallback;
import com.alibaba.sdk.android.oss.common.auth.OSSCredentialProvider;
import com.alibaba.sdk.android.oss.common.auth.OSSStsTokenCredentialProvider;
import com.alibaba.sdk.android.oss.model.PutObjectRequest;
import com.alibaba.sdk.android.oss.model.PutObjectResult;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.io.File;
import java.util.HashMap;

import io.agora.base.callback.Callback;
import io.agora.base.callback.ThrowableCallback;
import io.agora.base.network.RetrofitManager;
import io.agora.log.service.LogService;
import io.agora.log.service.bean.ResponseBody;
import io.agora.log.service.bean.response.LogParamsRes;

public class UploadManager {
    public static class UploadParam {
        public String host;
        public String url;
        public String appId;
        public String appCode;
        public String appVersion;
        public String roomId;
        public String uploadPath;
        public String callbackUrl;

        public UploadParam(
                @NonNull String host,
                @NonNull String url,
                @Nullable String appId,
                @NonNull String appCode,
                @NonNull String appVersion,
                @Nullable String roomId,
                @NonNull String uploadPath,
                @NonNull String callbackUrl
        ) {
            this.host = host;
            this.url = url;
            this.appId = appId;
            this.appCode = appCode;
            this.appVersion = appVersion;
            this.roomId = roomId;
            this.uploadPath = uploadPath;
            this.callbackUrl = callbackUrl;
        }
    }

    public static void upload(@NonNull Context context, @NonNull UploadParam param, @Nullable Callback<String> callback) {
        LogService service = RetrofitManager.instance().getService(param.host, LogService.class);
        service.logParams(param.url, TextUtils.isEmpty(param.appId) ? "default" : param.appId, param.appCode, param.appVersion, param.roomId)
                .enqueue(new RetrofitManager.Callback<>(0, new ThrowableCallback<ResponseBody<LogParamsRes>>() {
                    @Override
                    public void onSuccess(ResponseBody<LogParamsRes> res) {
                        res.data.callbackUrl = service.logStsCallback(param.callbackUrl).request().url().toString();
                        uploadByOss(context, param.uploadPath, res.data, callback);
                    }

                    @Override
                    public void onFailure(Throwable throwable) {
                        if (callback instanceof ThrowableCallback) {
                            ((ThrowableCallback<String>) callback).onFailure(throwable);
                        }
                    }
                }));
    }

    private static void uploadByOss(@NonNull Context context, @NonNull String uploadPath, @NonNull LogParamsRes param, @Nullable Callback<String> callback) {
        try {
            File file = new File(new File(uploadPath).getParentFile(), "temp.zip");
            ZipUtils.zipFile(new File(uploadPath), file);

            // 构造上传请求。
            PutObjectRequest put = new PutObjectRequest(param.bucketName, param.ossKey, file.getAbsolutePath());
            put.setCallbackParam(new HashMap<String, String>() {{
                put("callbackUrl", param.callbackUrl);
                put("callbackBodyType", param.callbackContentType);
                put("callbackBody", param.callbackBody);
            }});

            // 推荐使用OSSAuthCredentialsProvider。token过期可以及时更新。
            OSSCredentialProvider credentialProvider = new OSSStsTokenCredentialProvider(param.accessKeyId, param.accessKeySecret, param.securityToken);
            OSS oss = new OSSClient(context, param.ossEndpoint, credentialProvider);
            oss.asyncPutObject(put, new OSSCompletedCallback<PutObjectRequest, PutObjectResult>() {
                @Override
                public void onSuccess(PutObjectRequest request, PutObjectResult result) {
                    //noinspection ResultOfMethodCallIgnored
                    file.delete();
                    if (callback != null) {
                        String body = result.getServerCallbackReturnBody();
                        JsonObject json = JsonParser.parseString(body).getAsJsonObject();
                        callback.onSuccess(json.get("data").getAsString());
                    }
                }

                @Override
                public void onFailure(PutObjectRequest request, ClientException clientException, ServiceException serviceException) {
                    //noinspection ResultOfMethodCallIgnored
                    file.delete();
                    if (callback instanceof ThrowableCallback) {
                        if (clientException != null) {
                            ((ThrowableCallback<String>) callback).onFailure(clientException);
                        } else if (serviceException != null) {
                            ((ThrowableCallback<String>) callback).onFailure(serviceException);
                        } else {
                            ((ThrowableCallback<String>) callback).onFailure(null);
                        }
                    }
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
