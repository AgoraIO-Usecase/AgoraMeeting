package io.agora.rtc.ss.protect;

import android.app.Service;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.IBinder;
import android.os.RemoteException;
import android.util.Log;

import androidx.annotation.Nullable;

import io.agora.rtc.ss.aidl.IProtect;

/**
 * Description:
 *
 * @author xcz
 * @since 1/27/21
 */
public class LocalProtectService extends Service {

    private LocalProtectBinder mBinder;

    private final ServiceConnection connection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            IProtect iProtect = IProtect.Stub.asInterface(service);
            try {
                Log.i("LocalProtectService", "connected with " + iProtect.getServiceName());
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            startService(new Intent(LocalProtectService.this,RemoteProtectService.class));
            bindService(new Intent(LocalProtectService.this,RemoteProtectService.class),connection, Context.BIND_IMPORTANT);
        }
    };

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        startService(new Intent(this, RemoteProtectService.class));
        bindService(new Intent(this, RemoteProtectService.class), connection, Context.BIND_IMPORTANT);
        return START_STICKY;
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        mBinder = new LocalProtectBinder();
        return mBinder;
    }

    private static class LocalProtectBinder extends IProtect.Stub{

        @Override
        public String getServiceName() throws RemoteException {
            return LocalProtectService.class.getName();
        }

    }

}
