package io.agora.meeting.fragment.nav;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;
import androidx.lifecycle.ViewModelProvider;
import androidx.preference.PreferenceDataStore;
import androidx.preference.PreferenceFragmentCompat;
import androidx.preference.PreferenceScreen;
import androidx.preference.SwitchPreferenceCompat;

import io.agora.meeting.R;
import io.agora.meeting.annotaion.room.GlobalModuleState;
import io.agora.meeting.base.AppBarDelegate;
import io.agora.meeting.base.BaseFragment;
import io.agora.meeting.viewmodel.MeetingViewModel;

public class MemberSettingFragment extends PreferenceFragmentCompat implements AppBarDelegate {
    private MeetingViewModel meetingVM;
    private String key_mute_all, key_allow_self_unmute;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        meetingVM = new ViewModelProvider(requireActivity()).get(MeetingViewModel.class);
        key_mute_all = getString(R.string.key_mute_all);
        key_allow_self_unmute = getString(R.string.key_allow_self_unmute);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        setDivider(null);
        getToolbar().setTitle(R.string.member_setting);
        BaseFragment.setupActionBar(this);
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        meetingVM.muteAllAudio.observe(getViewLifecycleOwner(), muteAllAudio -> {
            PreferenceScreen preferenceScreen = getPreferenceScreen();
            ((SwitchPreferenceCompat) preferenceScreen.findPreference(key_mute_all)).setChecked(muteAllAudio != GlobalModuleState.ENABLE);
            ((SwitchPreferenceCompat) preferenceScreen.findPreference(key_allow_self_unmute)).setChecked(muteAllAudio == GlobalModuleState.CLOSE);
        });
    }

    @Override
    public void onCreatePreferences(Bundle savedInstanceState, String rootKey) {
        setPreferencesFromResource(R.xml.member_setting_preferences, rootKey);
        getPreferenceManager().setPreferenceDataStore(new PreferenceDataStore() {
            @Override
            public void putBoolean(String key, boolean value) {
                PreferenceScreen preferenceScreen = getPreferenceScreen();
                if (TextUtils.equals(key, key_mute_all)) {
                    meetingVM.switchMuteAllAudio(requireContext());
                    ((SwitchPreferenceCompat) preferenceScreen.findPreference(key_mute_all)).setChecked(!value);
                } else if (TextUtils.equals(key, key_allow_self_unmute)) {
                    int muteAllAudio = meetingVM.getMuteAllAudio();
                    meetingVM.muteAllAudio(muteAllAudio == GlobalModuleState.CLOSE ? GlobalModuleState.DISABLE : GlobalModuleState.CLOSE);
                    ((SwitchPreferenceCompat) preferenceScreen.findPreference(key_allow_self_unmute)).setChecked(!value);
                }
            }

            @Override
            public boolean getBoolean(String key, boolean defValue) {
                int muteAllAudio = meetingVM.getMuteAllAudio();

                if (TextUtils.equals(key, key_mute_all)) {
                    return muteAllAudio != GlobalModuleState.ENABLE;
                } else if (TextUtils.equals(key, key_allow_self_unmute)) {
                    return muteAllAudio == GlobalModuleState.CLOSE;
                }

                return defValue;
            }
        });
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