package io.agora.meeting.ui.fragment;

import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;
import androidx.lifecycle.ViewModelProvider;
import androidx.preference.Preference;
import androidx.preference.PreferenceFragmentCompat;

import com.bumptech.glide.request.target.CustomTarget;
import com.bumptech.glide.request.transition.Transition;

import io.agora.meeting.ui.MeetingActivity;
import io.agora.meeting.ui.R;
import io.agora.meeting.ui.adapter.BindingAdapters;
import io.agora.meeting.ui.base.AppBarDelegate;
import io.agora.meeting.ui.util.AvatarUtil;
import io.agora.meeting.ui.viewmodel.PreferenceViewModel;
import io.agora.meeting.ui.widget.OptionsDialogPreference;

public class SettingFragment extends PreferenceFragmentCompat implements AppBarDelegate {

    private PreferenceViewModel preferenceViewModel;

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
    public void setupAppBar(@NonNull Toolbar toolbar, boolean isLight) {
        ((AppBarDelegate) requireActivity()).setupAppBar(toolbar, isLight);
    }

    @Override
    public void onCreatePreferences(Bundle savedInstanceState, String rootKey) {
        setPreferencesFromResource(R.xml.setting_preferences, rootKey);
        initAvatar();
        initMaxNotifyNum();
    }


    private void initMaxNotifyNum(){
        ((OptionsDialogPreference)getPreferenceScreen().findPreference(getString(R.string.key_notify_max_num)))
                .addOption(getString(R.string.notify_member_option_always_mute), 0)
                .addOptions(10, 10, 10,  getString(R.string.notify_member_option))
                .addOption(getString(R.string.notify_member_option_never_mute), Integer.MAX_VALUE);
    }

    private PreferenceViewModel getPreferenceViewModel() {
        if(preferenceViewModel == null){
            preferenceViewModel = new ViewModelProvider(requireActivity()).get(PreferenceViewModel.class);
        }
        return preferenceViewModel;
    }

    private void initAvatar() {
        Preference avatarPreference = getPreferenceScreen().findPreference(getString(R.string.key_avatar));
        Preference namePreference = getPreferenceScreen().findPreference(getString(R.string.key_name));
        namePreference.setSummary(getPreferenceViewModel().getName().getValue());
        setAvatar(avatarPreference, namePreference);
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
    public boolean onPreferenceTreeClick(Preference preference) {
        String key = preference.getKey();
        if (TextUtils.equals(key, getString(R.string.key_about))) {
            ((MeetingActivity) requireActivity()).navigateToAboutFragment(requireView());
        }
        return super.onPreferenceTreeClick(preference);
    }

}
