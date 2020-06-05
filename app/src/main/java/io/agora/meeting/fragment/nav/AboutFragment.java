package io.agora.meeting.fragment.nav;

import android.content.Intent;
import android.graphics.Paint;
import android.net.Uri;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;

import io.agora.base.ToastManager;
import io.agora.meeting.BuildConfig;
import io.agora.meeting.R;
import io.agora.meeting.base.BaseFragment;
import io.agora.meeting.databinding.FragmentAboutBinding;
import io.agora.meeting.viewmodel.CommonViewModel;

public class AboutFragment extends BaseFragment<FragmentAboutBinding> {
    private CommonViewModel commonVM;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        commonVM = new ViewModelProvider(requireActivity()).get(CommonViewModel.class);
    }

    @Override
    protected FragmentAboutBinding createBinding(@NonNull LayoutInflater inflater, @Nullable ViewGroup container) {
        return FragmentAboutBinding.inflate(inflater, container, false);
    }

    @Override
    protected void init() {
        binding.tvAgreement.getPaint().setFlags(Paint.UNDERLINE_TEXT_FLAG);
        binding.tvPolicy.getPaint().setFlags(Paint.UNDERLINE_TEXT_FLAG);
        binding.setClickListener(v -> startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(BuildConfig.POLICY_URL))));
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        commonVM.appVersion.observe(getViewLifecycleOwner(), appVersion -> {
            if (appVersion != null && appVersion.forcedUpgrade == 0) {
                ToastManager.showShort(R.string.version_tips, BuildConfig.VERSION_NAME);
            }
        });
        binding.setViewModel(commonVM);
    }
}
