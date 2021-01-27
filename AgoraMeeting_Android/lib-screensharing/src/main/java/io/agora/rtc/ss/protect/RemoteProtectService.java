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
public class RemoteProtectService extends Service {
    private RemoteProtectBinder mBinder;

    private final ServiceConnection connection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            IProtect iProtect = IProtect.Stub.asInterface(service);
            try {
                Log.i("RemoteProtectService", "connected with " + iProtect.getServiceName());
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            startService(new Intent(RemoteProtectService.this, LocalProtectService.class));
            bindService(new Intent(RemoteProtectService.this, LocalProtectService.class), connection, Context.BIND_IMPORTANT);
        }
    };

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        bindService(new Intent(this, LocalProtectService.class), connection, Context.BIND_IMPORTANT);
        return START_STICKY;
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        mBinder = new RemoteProtectBinder();
        return mBinder;
    }

    private static class RemoteProtectBinder extends IProtect.Stub {

        @Override
        public String getServiceName() throws RemoteException {
            return RemoteProtectService.class.getName();
        }

    }
}
