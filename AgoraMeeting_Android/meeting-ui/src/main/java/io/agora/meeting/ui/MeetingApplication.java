package io.agora.meeting.ui;

import android.app.Application;
import android.content.Context;
import android.text.TextUtils;

import com.tencent.bugly.crashreport.CrashReport;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

import io.agora.meeting.core.MeetingConfig;
import io.agora.meeting.core.MeetingEngine;
import io.agora.meeting.ui.util.Utils;

/**
 * Description:
 *
 *
 * @since 2/19/21
 */
public abstract class MeetingApplication extends Application {
    private static MeetingApplication instance;

    private MeetingEngine meetingEngine;

    @Override
    public void onCreate() {
        super.onCreate();
        instance = this;
        Utils.init(this);
        initBugly();

        // 会议初始化
        meetingEngine = new MeetingEngine(this, getMeetingConfig());
    }

    protected abstract MeetingConfig getMeetingConfig();
    protected abstract String getBuglyAppId();

    public static Context getContext(){
        return instance;
    }

    public static MeetingEngine getMeetingEngine(){
        return instance.meetingEngine;
    }


    private void initBugly(){
        if(TextUtils.isEmpty(getBuglyAppId())){
            return;
        }
        Context context = getApplicationContext();
        // 获取当前包名
        String packageName = context.getPackageName();
        // 获取当前进程名
        String processName = getProcessName(android.os.Process.myPid());
        // 设置是否为上报进程
        CrashReport.UserStrategy strategy = new CrashReport.UserStrategy(context);
        strategy.setUploadProcess(processName == null || processName.equals(packageName));
        // 初始化Bugly
        CrashReport.initCrashReport(context, getBuglyAppId(), BuildConfig.DEBUG, strategy);
        // 设置标签
        CrashReport.setUserSceneTag(context, BuildConfig.DEBUG ? 999 : 0);
    }


    /**
     * 获取进程号对应的进程名
     *
     * @param pid 进程号
     * @return 进程名
     */
    private static String getProcessName(int pid) {
        BufferedReader reader = null;
        try {
            reader = new BufferedReader(new FileReader("/proc/" + pid + "/cmdline"));
            String processName = reader.readLine();
            if (!TextUtils.isEmpty(processName)) {
                processName = processName.trim();
            }
            return processName;
        } catch (Throwable throwable) {
            throwable.printStackTrace();
        } finally {
            try {
                if (reader != null) {
                    reader.close();
                }
            } catch (IOException exception) {
                exception.printStackTrace();
            }
        }
        return null;
    }

}
