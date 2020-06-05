package io.agora.meeting.fragment.nav;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.Navigation;
import androidx.preference.Preference;
import androidx.preference.PreferenceDataStore;
import androidx.preference.PreferenceFragmentCompat;
import androidx.preference.PreferenceScreen;
import androidx.preference.SwitchPreferenceCompat;

import io.agora.meeting.R;
import io.agora.meeting.base.AppBarDelegate;
import io.agora.meeting.base.BaseFragment;
import io.agora.meeting.data.Me;
import io.agora.meeting.fragment.InviteFragment;
import io.agora.meeting.util.LogUtil;
import io.agora.meeting.viewmodel.MeetingViewModel;

public class MeetingSettingFragment extends PreferenceFragmentCompat implements AppBarDelegate {
    private MeetingViewModel meetingVM;
    private String key_room_name, key_room_pwd, key_name, key_camera, key_mic;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        meetingVM = new ViewModelProvider(requireActivity()).get(MeetingViewModel.class);
        key_room_name = getString(R.string.key_room_name);
        key_room_pwd = getString(R.string.key_room_pwd);
        key_name = getString(R.string.key_name);
        key_camera = getString(R.string.key_camera);
        key_mic = getString(R.string.key_mic);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        setDivider(null);
        getToolbar().setTitle(R.string.setting);
        BaseFragment.setupActionBar(this);
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        meetingVM.me.observe(getViewLifecycleOwner(), me -> {
            PreferenceScreen preferenceScreen = getPreferenceScreen();
            preferenceScreen.findPreference(key_name).setSummary(me.userName);
            ((SwitchPreferenceCompat) preferenceScreen.findPreference(key_camera)).setChecked(me.isVideoEnable());
            ((SwitchPreferenceCompat) preferenceScreen.findPreference(key_mic)).setChecked(me.isAudioEnable());
        });
        meetingVM.room.observe(getViewLifecycleOwner(), room -> {
            PreferenceScreen preferenceScreen = getPreferenceScreen();
            preferenceScreen.findPreference(key_room_name).setSummary(room.roomName);
            preferenceScreen.findPreference(key_room_pwd).setSummary(room.password);
        });
    }

    @Override
    public void onCreatePreferences(Bundle savedInstanceState, String rootKey) {
        setPreferencesFromResource(R.xml.meeting_setting_preferences, rootKey);
        getPreferenceManager().setPreferenceDataStore(new PreferenceDataStore() {
            @Override
            public void putBoolean(String key, boolean value) {
                PreferenceScreen preferenceScreen = getPreferenceScreen();
                if (TextUtils.equals(key, key_camera)) {
                    meetingVM.switchVideoState(meetingVM.getMeValue());
                    ((SwitchPreferenceCompat) preferenceScreen.findPreference(key_camera)).setChecked(!value);
                } else if (TextUtils.equals(key, key_mic)) {
                    meetingVM.switchAudioState(meetingVM.getMeValue(), requireContext());
                    ((SwitchPreferenceCompat) preferenceScreen.findPreference(key_mic)).setChecked(!value);
                }
            }

            @Override
            public boolean getBoolean(String key, boolean defValue) {
                Me me = meetingVM.getMeValue();
                if (me == null) return defValue;

                if (TextUtils.equals(key, key_camera)) {
                    return me.isVideoEnable();
                } else if (TextUtils.equals(key, key_mic)) {
                    return me.isAudioEnable();
                }

                return defValue;
            }
        });
    }

    @Override
    public boolean onPreferenceTreeClick(Preference preference) {
        String key = preference.getKey();
        if (TextUtils.equals(key, getString(R.string.key_about))) {
            Navigation.findNavController(requireView()).navigate(MeetingSettingFragmentDirections.actionMeetingSettingFragmentToAboutFragment());
        } else if (TextUtils.equals(key, getString(R.string.key_invite))) {
            new InviteFragment().show(getChildFragmentManager(), null);
        } else if (TextUtils.equals(key, getString(R.string.key_upload))) {
            LogUtil.upload(requireActivity(), meetingVM.getRoomId());
        }
        return super.onPreferenceTreeClick(preference);
    }

    @Override
    public Toolbar getToolbar() {
        return requireView().findViewById(R.id.toolbar);
    }

    @Override
    public boolean lightMode() {
        return false;
    }
}
