package io.agora.meeting.ui;

import android.app.DownloadManager;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.text.TextUtils;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ProgressBar;
import android.widget.RatingBar;
import android.widget.TextView;

import androidx.annotation.IdRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.databinding.DataBindingUtil;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.NavController;
import androidx.navigation.Navigation;
import androidx.navigation.fragment.NavHostFragment;

import com.yanzhenjie.permission.AndPermission;
import com.yanzhenjie.permission.runtime.Permission;

import java.util.Locale;

import io.agora.meeting.core.annotaion.Keep;
import io.agora.meeting.core.annotaion.ModuleState;
import io.agora.meeting.core.http.body.resp.AppVersionResp;
import io.agora.meeting.core.log.Logger;
import io.agora.meeting.core.model.RoomModel;
import io.agora.meeting.ui.base.AppBarDelegate;
import io.agora.meeting.ui.databinding.LayoutRatingBinding;
import io.agora.meeting.ui.fragment.MeetingFragmentArgs;
import io.agora.meeting.ui.fragment.SimpleWebFragmentArgs;
import io.agora.meeting.ui.fragment.WhiteBoardFragmentArgs;
import io.agora.meeting.ui.util.NetworkUtil;
import io.agora.meeting.ui.util.ToastUtil;
import io.agora.meeting.ui.viewmodel.CommonViewModel;
import io.agora.meeting.ui.viewmodel.PreferenceViewModel;
import io.agora.meeting.ui.viewmodel.RoomViewModel;
import io.agora.meeting.ui.widget.PrivacyTermsDialog;

/**
 * Description:
 *
 * @since 2/19/21
 */
public class MeetingActivity extends AppCompatActivity implements AppBarDelegate {
    private CommonViewModel commonVM;
    private PreferenceViewModel preferenceVM;
    private DownloadReceiver downloadReceiver;
    private RoomViewModel roomVM;
    private AlertDialog mLoadingDialog;
    private AlertDialog mPoorNetDialog;
    private long lastNavigateTime;

    private PrivacyTermsDialog termsDialog;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(onCreateSavedInstanceState(savedInstanceState));
        initOnCreated();
        DataBindingUtil.setContentView(this, R.layout.activity_main);
        initPrivacy();
    }

    @Override
    public boolean onSupportNavigateUp() {
        NavController navController = Navigation.findNavController(this, getNavLayout());
        return navController.navigateUp() || super.onSupportNavigateUp();
    }

    protected Bundle onCreateSavedInstanceState(@Nullable Bundle savedInstanceState) {
        return null;
    }

    private int getNavLayout() {
        return R.id.nav_host_fragment;
    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        NavController navController = Navigation.findNavController(this, getNavLayout());
        try {
            navController.navigate(item.getItemId());
            return true;
        } catch (Exception e) {
            return super.onOptionsItemSelected(item);
        }
    }

    private void initPrivacy() {
        if (preferenceVM.getShowPrivacy()) {
            if (termsDialog != null) {
                return;
            }
            termsDialog = new PrivacyTermsDialog(MeetingActivity.this);
            termsDialog.setPrivacyTermsDialogListener(new PrivacyTermsDialog.OnPrivacyTermsDialogListener() {
                @Override
                public void onPositiveClick() {
                    initAfterAgreenPolicy();
                    termsDialog = null;
                    preferenceVM.setShowPrivacy(false);
                }

                @Override
                public void onNegativeClick() {
                    finish();
                }
            });
            termsDialog.show();
        }else{
            initAfterAgreenPolicy();
        }
    }

    private void initAfterAgreenPolicy() {
        doIfNetAvailable(() -> {
            listenNetworkChange();
            checkNeedPermissions();
            commonVM.checkVersion();
        });
    }

    protected void initOnCreated() {
        setStatusBarTransparent();
        initDownloadReceiver();
        ViewModelProvider viewModelProvider = new ViewModelProvider(this);
        roomVM = viewModelProvider.get(RoomViewModel.class);
        preferenceVM = viewModelProvider.get(PreferenceViewModel.class);
        commonVM = viewModelProvider.get(CommonViewModel.class);
        commonVM.versionInfo.observe(this, appVersionResp -> {
            if (appVersionResp == null) {
                return;
            }
            if (appVersionResp.forcedUpgrade != ModuleState.DISABLE) {
                showUpgradeDialog(appVersionResp);
            }
        });
        roomVM.failure.observe(this, throwable -> {
            dismissLoadingDialog();
            RoomModel roomModel = roomVM.getRoomModel();
            if (roomModel == null) {
                ToastUtil.showShort(throwable.getMessage());
                return;
            }
            String roomId = roomModel.roomId;
            String userid = roomModel.getLocalUserId();
            if (throwable instanceof RoomViewModel.MeetingEndException) {
                roomVM.reset();
                showForceExitDialog(roomId, userid, R.string.main_close_title, null);
            } else if (throwable instanceof RoomViewModel.LocaleUserExitException) {
                roomVM.reset();
                showForceExitDialog(roomId, userid, R.string.main_removed_from_room, null);
            } else {
                ToastUtil.showShort(throwable.getMessage());
            }
        });
        preferenceVM.setCameraFront(true);
    }

    /**
     * 网络改变监听
     */
    private void listenNetworkChange() {
        NetworkUtil.checkNetworkRealTime(
                this,
                () -> onNetStateChanged(true),
                () -> onNetStateChanged(true),
                () -> onNetStateChanged(true),
                () -> onNetStateChanged(false)
        );
    }

    private void onNetStateChanged(boolean available) {
        if (available) {
            dismissPoorNetDialog();
        } else {
            showPoorNetDialog();
        }
    }

    private void showPoorNetDialog() {
        if (mPoorNetDialog == null) {
            mPoorNetDialog = new AlertDialog.Builder(this)
                    .setMessage(R.string.net_unavailable)
                    .setPositiveButton(R.string.setting_title, (dialog, which) -> startActivity(new Intent(Settings.ACTION_SETTINGS)))
                    .setNegativeButton(R.string.cmm_cancel, (dialog, which) -> dialog.dismiss())
                    .create();
        }
        mPoorNetDialog.show();
    }

    private void dismissPoorNetDialog() {
        if (mPoorNetDialog != null) {
            mPoorNetDialog.dismiss();
        }
    }

    private void doIfNetAvailable(Runnable run) {
        if (NetworkUtil.isNetworkAvailable(this)) {
            run.run();
        } else {
            new AlertDialog.Builder(this)
                    .setMessage(R.string.net_unavailable)
                    .setCancelable(false)
                    .setPositiveButton(R.string.cmm_refresh, (dialog, which) -> doIfNetAvailable(run))
                    .show();
        }
    }

    private void checkNeedPermissions() {
        AndPermission.with(this)
                .runtime()
                .permission(Permission.CAMERA, Permission.RECORD_AUDIO)
                .start();
    }

    private void initDownloadReceiver() {
        downloadReceiver = new DownloadReceiver();
        IntentFilter filter = new IntentFilter();
        filter.addAction(DownloadManager.ACTION_DOWNLOAD_COMPLETE);
        filter.setPriority(IntentFilter.SYSTEM_LOW_PRIORITY);
        registerReceiver(downloadReceiver, filter);
    }

    private void showUpgradeDialog(@NonNull AppVersionResp versionInfo) {
        AlertDialog dialog = new AlertDialog.Builder(this)
                .setMessage(R.string.about_upgrade_title)
                .setCancelable(false)
                .setPositiveButton(R.string.cmm_update, null)
                .show();
        dialog.getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener(v -> {
            dialog.dismiss();
            startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(getString(R.string.download_url, getLocalCountry()))));
        });
    }

    private String getLocalCountry() {
        Locale locale = Locale.getDefault();
        if (!Locale.SIMPLIFIED_CHINESE.getLanguage().equalsIgnoreCase(locale.getLanguage())) {
            return "en";
        }
        return "cn";
    }

    private void showForceExitDialog(String roomId, String userId, @StringRes int titleRes, Runnable dismiss) {
        new AlertDialog.Builder(this)
                .setMessage(titleRes)
                .setPositiveButton(R.string.cmm_know, (dialog, which) -> {
                    if (titleRes == R.string.main_close_title) {
                        showRateDialog(roomId, userId, dismiss);
                    } else if (titleRes == R.string.main_removed_from_room) {
                        navigateToLoginPage(getWindow().getDecorView());
                    }
                }).setCancelable(false).show();
    }

    public void showRateDialog(String roomId, String userId, Runnable dismiss) {
        LayoutRatingBinding binding = LayoutRatingBinding.inflate(getLayoutInflater());
        bindRatingBarAndTv(binding.rbCallQuality, binding.tvCallQuality);
        bindRatingBarAndTv(binding.rbFunctionCompleteness, binding.tvFunctionCompleteness);
        bindRatingBarAndTv(binding.rbGeneralExperience, binding.tvGeneralExperience);
        new AlertDialog.Builder(this)
                .setTitle(R.string.rating_title)
                .setCancelable(true)
                .setView(binding.getRoot())
                .setPositiveButton(R.string.cmm_submit, (dialog1, which1) -> {
                    MeetingApplication.getMeetingEngine().userRate(
                            roomId, userId,
                            binding.rbCallQuality.getRating(),
                            binding.rbFunctionCompleteness.getRating(),
                            binding.rbGeneralExperience.getRating(),
                            binding.etComment.getText().toString(),
                            throwable -> ToastUtil.showShort(throwable.getMessage())
                    );
                })
                .setOnDismissListener(dialog1 -> {
                    if (dismiss != null) dismiss.run();
                    navigateToLoginPage(getWindow().getDecorView());
                })
                .show();
    }

    private void bindRatingBarAndTv(RatingBar ratingBar, TextView textView) {
        ratingBar.setOnRatingBarChangeListener((ratingBar1, rating, fromUser) -> {
            if (rating == 0) {
                rating = 1;
                ratingBar.setRating(1);
            }
            textView.setText(getString(R.string.rating_start, (int) rating));
        });
        textView.setText(getString(R.string.rating_start, (int) ratingBar.getRating()));
    }

    public void showLoadingDialog() {
        if (mLoadingDialog == null) {
            ProgressBar progressBar = new ProgressBar(this);
            int padding = (int) getResources().getDimension(R.dimen.loading_dialog_padding);
            progressBar.setPadding(padding, padding, padding, padding);
            mLoadingDialog = new AlertDialog.Builder(this)
                    .setView(progressBar)
                    .setCancelable(false)
                    .show();
        } else {
            mLoadingDialog.show();
        }
    }

    public void dismissLoadingDialog() {
        if (mLoadingDialog != null) {
            mLoadingDialog.dismiss();
        }
    }

    protected void downloadApk(String apkUrl) {
        String perms = Permission.WRITE_EXTERNAL_STORAGE;
        if (AndPermission.hasPermissions(this, perms)) {
            if (TextUtils.isEmpty(apkUrl)) {
                downloadReceiver.downloadApk(this, apkUrl);
            }
        } else {
            AndPermission.with(this)
                    .runtime()
                    .permission(perms)
                    .onGranted(data -> {
                        downloadApk(apkUrl);
                    })
                    .start();
        }
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
        } else {
            window.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        unregisterReceiver(downloadReceiver);
        if (termsDialog != null) {
            termsDialog.dismiss();
        }
    }

    @Override
    public void setupAppBar(@NonNull Toolbar toolbar, boolean isLight) {
        setStatusBarStyle(isLight);
        setSupportActionBar(toolbar);
    }

    protected void safeNavigate(View view, @IdRes int targetId, Bundle bundle) {
        // 两次点击间隔不能小于1s
        if (System.currentTimeMillis() - lastNavigateTime < 1000) {
            Logger.d("MeetingActivity", "safeNavigate click interval less than 1s");
            return;
        }
        lastNavigateTime = System.currentTimeMillis();
        try {
            Navigation.findNavController(view).navigate(targetId, bundle);
        } catch (Exception e) {
            Logger.d(e.toString());
            try {
                Navigation.findNavController(this, getNavLayout()).navigate(targetId, bundle);
            } catch (Exception e1) {
                Logger.d("MeetingActivity", "findNavController error: " + e1.toString());
            }
        }
    }

    public void navigateToWebPage(View view, String url) {
        safeNavigate(view, R.id.action_to_webFragment, new SimpleWebFragmentArgs.Builder(url).build().toBundle());
    }

    public void navigateToMainPage(View view, String roomId) {
        safeNavigate(view, R.id.action_to_meetingFragment, new MeetingFragmentArgs.Builder(roomId).build().toBundle());
    }

    public void navigateToBoardPage(View view, String userId, String streamId) {
        safeNavigate(view, R.id.action_to_whiteBoardFragment, new WhiteBoardFragmentArgs.Builder(userId, streamId).build().toBundle());
    }

    public void navigateToMemberListPage(View view) {
        safeNavigate(view, R.id.action_to_memberListFragment, null);
    }

    public void navigateToMessagePage(View view) {
        safeNavigate(view, R.id.action_to_messageFragment, null);
    }

    public void navigateToSettingPage(View view) {
        safeNavigate(view, R.id.action_to_meetingSettingFragment, null);
    }

    public void navigateToLoginPage(View view) {
        safeNavigate(view, R.id.action_global_loginFragment, null);
    }

    public void navigateToAboutFragment(View view) {
        safeNavigate(view, R.id.action_to_aboutFragment, null);
    }

    @Keep
    public static class MainNavHostFragment extends NavHostFragment {
        @Override
        public void onCreate(@Nullable Bundle savedInstanceState) {
            setReenterTransition(true);
            super.onCreate(savedInstanceState);
        }
    }
}
