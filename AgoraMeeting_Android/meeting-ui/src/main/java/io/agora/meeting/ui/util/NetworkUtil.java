package io.agora.meeting.ui.util;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkInfo;

import androidx.annotation.NonNull;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleEventObserver;
import androidx.lifecycle.LifecycleOwner;

/**
 * Description:
 *
 *
 * @since 3/3/21
 */
public class NetworkUtil {
    /**
     * 检查网络是否可用
     *
     * @param context
     * @return
     */
    public static boolean isNetworkAvailable(Context context) {
        ConnectivityManager manager = (ConnectivityManager) context
                .getApplicationContext().getSystemService(
                        Context.CONNECTIVITY_SERVICE);
        if (manager == null) {
            return false;
        }
        NetworkInfo networkinfo = manager.getActiveNetworkInfo();

        return networkinfo != null && networkinfo.isAvailable();
    }

    /**
     * 当receiver不为空时，能实时检测网络变化
     */
    public static void checkNetworkRealTime(LifecycleOwner owner,
                                            Runnable wifiCallback,
                                            Runnable mobileCallback,
                                            Runnable otherCallback,
                                            Runnable noNetCallback) {
        NetworkStateLifecycle lifecycle = new NetworkStateLifecycle();
        lifecycle.receiver.onReceiveRun = () -> checkNetworkOneTime((Context) owner, wifiCallback, mobileCallback, otherCallback, noNetCallback);
        owner.getLifecycle().addObserver(lifecycle);

        checkNetworkOneTime((Context) owner, wifiCallback, mobileCallback, otherCallback, noNetCallback);
    }

    public static void checkNetworkOneTime(Context context,
                                           Runnable wifiCallback,
                                           Runnable mobileCallback,
                                           Runnable otherCallback,
                                           Runnable noNetCallback) {
        //获得ConnectivityManager对象
        ConnectivityManager connMgr = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);

        //获取所有网络连接的信息
        Network[] networks = connMgr.getAllNetworks();
        boolean wifi = false, mobile = false, other = false;
        for (Network network : networks) {
            NetworkInfo networkInfo = connMgr.getNetworkInfo(network);
            if (networkInfo.getType() == ConnectivityManager.TYPE_WIFI) {
                wifi = networkInfo.isConnected();
            } else if (networkInfo.getType() == ConnectivityManager.TYPE_MOBILE) {
                mobile = networkInfo.isConnected();
            } else {
                other = networkInfo.isConnected();
            }
        }
        if (!wifi && !mobile && !other) {
            // 网络断开
            if (noNetCallback != null) noNetCallback.run();
        } else if (wifi) {
            // WIFI已连接
            if (wifiCallback != null) wifiCallback.run();
        } else if (mobile) {
            // WIFI已断开,移动数据已连接
            if (mobileCallback != null) mobileCallback.run();
        } else if (other) {
            // WIFI已断开,移动数据已断开,有其他网络连接
            if (otherCallback != null) otherCallback.run();
        }
    }

    private static class NetworkStateLifecycle implements LifecycleEventObserver {
        private final NetWorkStateReceiver receiver = new NetWorkStateReceiver();

        @Override
        public void onStateChanged(@NonNull LifecycleOwner source, @NonNull Lifecycle.Event event) {
            if(!(source instanceof Activity)){
                throw new RuntimeException("the LifecycleOwner of NetworkStateLifecycle must be activity.");
            }
            if(event == Lifecycle.Event.ON_CREATE){
                receiver.register((Context) source);
            }else if(event == Lifecycle.Event.ON_DESTROY){
                receiver.unRegister((Context) source);
                source.getLifecycle().removeObserver(this);
            }
        }

    }

    private static class NetWorkStateReceiver extends BroadcastReceiver {
        private Runnable onReceiveRun;

        public void register(Context context){
            IntentFilter filter = new IntentFilter();
            filter.addAction(ConnectivityManager.CONNECTIVITY_ACTION);
            context.registerReceiver(this, filter);
        }

        public void unRegister(Context context){
            onReceiveRun = null;
            context.unregisterReceiver(this);
        }

        @Override
        public void onReceive(Context context, Intent intent) {
            if(onReceiveRun != null) onReceiveRun.run();
        }
    }

}
