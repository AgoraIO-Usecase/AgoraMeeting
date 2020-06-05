package io.agora.meeting;

import android.Manifest;
import android.app.DownloadManager;
import android.content.IntentFilter;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.databinding.DataBindingUtil;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.NavController;
import androidx.navigation.Navigation;

import io.agora.meeting.service.body.res.AppVersionRes;
import io.agora.meeting.util.Events;
import io.agora.meeting.viewmodel.CommonViewModel;
import pub.devrel.easypermissions.AfterPermissionGranted;
import pub.devrel.easypermissions.EasyPermissions;

public class MainActivity extends AppCompatActivity {
    private static final int RC_CAMERA_AND_RECORD_AUDIO = 100;
    private static final int RC_STORAGE = 101;

    private DownloadReceiver receiver;
    private CommonViewModel commonVM;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        setStatusBarTransparent();
        super.onCreate(savedInstanceState);
        DataBindingUtil.setContentView(this, R.layout.activity_main);

        checkPermission();
        initReceiver();

        commonVM = new ViewModelProvider(this).get(CommonViewModel.class);
        commonVM.checkVersion(true);
        commonVM.initMultiLanguage();
    }

    @Override
    protected void onResume() {
        super.onResume();
        Events.UpgradeEvent.addListener(this, observer);
    }

    @Override
    protected void onPause() {
        super.onPause();
        Events.UpgradeEvent.removeListener(observer);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        unregisterReceiver(receiver);
    }

    @Override
    public boolean onSupportNavigateUp() {
        NavController navController = Navigation.findNavController(this, R.id.nav_host_fragment);
        return navController.navigateUp() || super.onSupportNavigateUp();
    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        NavController navController = Navigation.findNavController(this, R.id.nav_host_fragment);
        try {
            navController.navigate(item.getItemId());
            return true;
        } catch (Exception e) {
            return super.onOptionsItemSelected(item);
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        EasyPermissions.onRequestPermissionsResult(requestCode, permissions, grantResults, this);
    }

    public void setupAppBar(@NonNull Toolbar toolbar, boolean isLight) {
        setStatusBarStyle(isLight);
        setSupportActionBar(toolbar);
    }

    private void setStatusBarStyle(boolean isLight) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Window window = getWindow();
            if (isLight) {
                window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_VISIBLE);
            } else {
                window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
            }
        }
    }

    private void setStatusBarTransparent() {
        Window window = getWindow();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            window.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
            window.setStatusBarColor(Color.TRANSPARENT);
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            window.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
        }
    }

    private void initReceiver() {
        receiver = new DownloadReceiver();
        IntentFilter filter = new IntentFilter();
        filter.addAction(DownloadManager.ACTION_DOWNLOAD_COMPLETE);
        filter.setPriority(IntentFilter.SYSTEM_LOW_PRIORITY);
        registerReceiver(receiver, filter);
    }

    @AfterPermissionGranted(RC_CAMERA_AND_RECORD_AUDIO)
    private void checkPermission() {
        String[] perms = {Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO};
        if (EasyPermissions.hasPermissions(this, perms)) {

        } else {
            EasyPermissions.requestPermissions(this, "", RC_CAMERA_AND_RECORD_AUDIO, perms);
        }
    }

    private Observer<Events.UpgradeEvent> observer = event -> {
        if (event.forcedUpgrade == 0) return;

        AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this)
                .setTitle(R.string.upgrade_title)
                .setPositiveButton(R.string.upgrade, (dialog, which) -> downloadApk());
        if (!TextUtils.isEmpty(event.upgradeDescription)) {
            builder.setMessage(event.upgradeDescription);
        }
        if (event.forcedUpgrade == 2) {
            builder.setCancelable(false);
        } else {
            builder.setNegativeButton(R.string.later, null);
        }
        builder.show();
    };

    @AfterPermissionGranted(RC_STORAGE)
    private void downloadApk() {
        String[] perms = {Manifest.permission.WRITE_EXTERNAL_STORAGE};
        if (EasyPermissions.hasPermissions(this, perms)) {
            AppVersionRes res = commonVM.appVersion.getValue();
            if (res != null) {
                receiver.downloadApk(this, res.upgradeUrl);
            }
        } else {
            EasyPermissions.requestPermissions(this, "", RC_STORAGE, perms);
        }
    }
}
