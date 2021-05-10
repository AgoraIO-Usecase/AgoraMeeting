package io.agora.meeting.ui.fragment;

import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;
import androidx.lifecycle.ViewModelProvider;
import androidx.preference.Preference;
import androidx.preference.PreferenceFragmentCompat;
import androidx.preference.PreferenceScreen;
import androidx.preference.SwitchPreferenceCompat;

import com.bumptech.glide.request.target.CustomTarget;
import com.bumptech.glide.request.transition.Transition;

import io.agora.meeting.core.MeetingEngine;
import io.agora.meeting.core.annotaion.Device;
import io.agora.meeting.core.annotaion.UserRole;
import io.agora.meeting.ui.MeetingActivity;
import io.agora.meeting.ui.MeetingApplication;
import io.agora.meeting.ui.R;
import io.agora.meeting.ui.adapter.BindingAdapters;
import io.agora.meeting.ui.base.AppBarDelegate;
import io.agora.meeting.ui.util.AvatarUtil;
import io.agora.meeting.ui.util.ClipboardUtil;
import io.agora.meeting.ui.util.ToastUtil;
import io.agora.meeting.ui.viewmodel.RoomViewModel;
import io.agora.meeting.ui.viewmodel.UserViewModel;
import io.agora.meeting.ui.widget.OptionsDialogPreference;

public class MeetingSettingFragment extends PreferenceFragmentCompat implements AppBarDelegate {
    private RoomViewModel roomVM;
    private UserViewModel localUserVM;

    private SwitchPreferenceCompat cameraApproveSwitch;
    private SwitchPreferenceCompat micApproveSwitch;

    private final Handler mHandler = new Handler(Looper.getMainLooper());
    private Runnable unlockLogRun;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        roomVM = new ViewModelProvider(requireActivity()).get(RoomViewModel.class);
        localUserVM = roomVM.getLocalUserViewModel();
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        mHandler.removeCallbacksAndMessages(null);
    }

    @Override
    public void setupAppBar(@NonNull Toolbar toolbar, boolean isLight) {
        ((AppBarDelegate) requireActivity()).setupAppBar(toolbar, isLight);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        setDivider(null);
        Toolbar toolbar = view.findViewById(R.id.toolbar);
        BindingAdapters.bindToolbarTitle(toolbar, true, "", getResources().getColor(R.color.global_text_color_black), getResources().getDimensionPixelOffset(R.dimen.global_text_size_large));
        toolbar.setTitle(R.string.setting_title);
        setupAppBar(toolbar, false);
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        initPreferences();
    }

    private void initPreferences() {
        PreferenceScreen preferenceScreen = getPreferenceScreen();
        cameraApproveSwitch = (SwitchPreferenceCompat) preferenceScreen.findPreference(getString(R.string.key_camera_approve));
        micApproveSwitch = (SwitchPreferenceCompat) preferenceScreen.findPreference(getString(R.string.key_mic_approve));
        Preference roomNamePf = preferenceScreen.findPreference(getString(R.string.key_room_name));
        Preference roomPwdPf = preferenceScreen.findPreference(getString(R.string.key_room_pwd));
        Preference userNamePf = preferenceScreen.findPreference(getString(R.string.key_name));
        Preference userAvatarPf = preferenceScreen.findPreference(getString(R.string.key_avatar));
        Preference userRolePf = preferenceScreen.findPreference(getString(R.string.key_role));

        //roomPwdPf.setSummaryProvider(null);
        //roomPwdPf.setOnPreferenceClickListener(preference -> {
        //    DialogUtil.showEditAlertDialog(getContext(),
        //            R.layout.layout_text_input_room_pwd,
        //            preference.getTitle(),
        //            preference.getSummary(),
        //            result -> roomVM.roomModel.getValue().updateRoomInfo(result)
        //    );
        //    return true;
        //});
        cameraApproveSwitch.setChecked(!roomVM.roomProperties.getValue().userPermission.cameraAccess);
        cameraApproveSwitch.setOnPreferenceChangeListener((preference, newValue) -> {
            ((MeetingActivity)requireActivity()).showLoadingDialog();
            localUserVM.userModel.getValue().changeUserPermission(Device.CAMERA, !(Boolean) newValue,
                    null,
                    () -> ((MeetingActivity) requireActivity()).dismissLoadingDialog()
            );
            return true;
        });
        micApproveSwitch.setChecked(!roomVM.roomProperties.getValue().userPermission.micAccess);
        micApproveSwitch.setOnPreferenceChangeListener((preference, newValue) -> {
            ((MeetingActivity)requireActivity()).showLoadingDialog();
            localUserVM.userModel.getValue().changeUserPermission(Device.MIC, !(Boolean) newValue,
                    null,
                    () -> ((MeetingActivity) requireActivity()).dismissLoadingDialog()
            );
            return true;
        });

        roomVM.roomProperties.observe(getViewLifecycleOwner(), properties -> {
            ((MeetingActivity) requireActivity()).dismissLoadingDialog();
            cameraApproveSwitch.setChecked(!properties.userPermission.cameraAccess);
            micApproveSwitch.setChecked(!properties.userPermission.micAccess);
            roomNamePf.setSummary(properties.roomInfo.roomName);
            roomPwdPf.setSummary(properties.roomInfo.roomPassword);
        });
        localUserVM.userModel.observe(getViewLifecycleOwner(), userModel -> {
            cameraApproveSwitch.setEnabled(userModel.isHost());
            micApproveSwitch.setEnabled(userModel.isHost());
            userNamePf.setSummary(userModel.getUserName());
            if (userModel.getUserRole().equals(UserRole.HOST)) {
                userRolePf.setSummary(getString(R.string.cmm_admin));
            }else{
                userRolePf.setSummary(getString(R.string.cmm_member));
            }

            setAvatar(userAvatarPf, userNamePf);
        });

        ((OptionsDialogPreference)preferenceScreen.findPreference(getString(R.string.key_notify_max_num)))
                .addOption(getString(R.string.notify_member_option_always_mute), 0)
                .addOptions(10, 10, 10,  getString(R.string.notify_member_option))
                .addOption(getString(R.string.notify_member_option_never_mute), Integer.MAX_VALUE);
    }

    private void setAvatar(Preference avatarPreference, Preference namePreference) {
        if (TextUtils.isEmpty(namePreference.getSummary())) {
            return;
        }
        AvatarUtil.loadCircleAvatar(requireContext(), namePreference.getSummary().toString(), new CustomTarget<Drawable>() {
            @Override
            public void onResourceReady(@NonNull Drawable resource, @Nullable Transition<? super Drawable> transition) {
                avatarPreference.setIcon(resource);
            }

            @Override
            public void onLoadCleared(@Nullable Drawable placeholder) {

            }
        });
    }


    @Override
    public void onCreatePreferences(Bundle savedInstanceState, String rootKey) {
        setPreferencesFromResource(R.xml.meeting_setting_preferences, rootKey);
    }

    private void lockLogBtn(){
        Preference preference = getPreferenceScreen().findPreference(getString(R.string.key_upload));
        preference.setEnabled(false);
    }

    private void unlockLogBtn(){
        Preference preference = getPreferenceScreen().findPreference(getString(R.string.key_upload));
        preference.setEnabled(true);
    }

    private void unlockLogBtnDelay(){
        if(unlockLogRun != null){
            mHandler.removeCallbacks(unlockLogRun);
        }
        unlockLogRun = this::unlockLogBtn;
        mHandler.postDelayed(unlockLogRun, 6000);
    }

    @Override
    public boolean onPreferenceTreeClick(Preference preference) {
        String key = preference.getKey();
        if (TextUtils.equals(key, getString(R.string.key_about))) {
            ((MeetingActivity) requireActivity()).navigateToAboutFragment(requireView());
        } else if (TextUtils.equals(key, getString(R.string.key_upload))) {
            lockLogBtn();
            MeetingApplication.getMeetingEngine().uploadLog(new MeetingEngine.UploadLogCallback() {
                @Override
                public void success(String logId) {
                    unlockLogBtnDelay();
                    ClipboardUtil.copy2Clipboard(requireContext(), logId);
                    ToastUtil.showShort(R.string.net_upload_success);
                }

                @Override
                public void failed(Throwable error) {
                    unlockLogBtn();
                    ToastUtil.showShort(R.string.net_upload_failed);
                }
            });
        }
        return true;
    }

}
