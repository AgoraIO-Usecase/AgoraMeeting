package io.agora.meeting.ui.fragment;

import android.content.Intent;
import android.graphics.Paint;
import android.net.Uri;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;

import java.util.Locale;

import io.agora.meeting.ui.MeetingActivity;
import io.agora.meeting.ui.R;
import io.agora.meeting.ui.base.BaseFragment;
import io.agora.meeting.ui.databinding.FragmentAboutBinding;
import io.agora.meeting.ui.viewmodel.CommonViewModel;

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
        setupAppBar(binding.toolbar, false);
        binding.tvProductDisclaimer.getPaint().setFlags(Paint.UNDERLINE_TEXT_FLAG);
        binding.tvPolicy.getPaint().setFlags(Paint.UNDERLINE_TEXT_FLAG);
        binding.tvUserPolicy.getPaint().setFlags(Paint.UNDERLINE_TEXT_FLAG);
        binding.setClickListener(v -> {
            if(v.getId() == R.id.tv_policy){
                ((MeetingActivity)requireActivity()).navigateToWebPage(requireView(), getString(R.string.proxy_url, getLocalLanguage()));
            }
            else if(v.getId() == R.id.tv_user_policy){
                ((MeetingActivity)requireActivity()).navigateToWebPage(requireView(), getString(R.string.user_proxy_url, getLocalLanguage()));
            }
            else if(v.getId() == R.id.tv_product_disclaimer){
                // 免费声明
                String accessUrl = String.format(Locale.US, "file:android_asset/disclaimer_%s.html", getLocalLanguage());
                ((MeetingActivity)requireActivity()).navigateToWebPage(requireView(), accessUrl);
            }
            else if(v.getId() == R.id.btn_register){
                startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(getString(R.string.sign_up_url, getLocalLanguage()))));
            }
            else if(v.getId() == R.id.btn_document){
                startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(getString(R.string.document_url, getLocalLanguage()))));
            }
            else if(v.getId() == R.id.btn_update){
                commonVM.checkVersion();
            }
        });
    }

    private String getLocalLanguage(){
        Locale locale = Locale.getDefault();
        if (!Locale.SIMPLIFIED_CHINESE.getLanguage().equalsIgnoreCase(locale.getLanguage())) {
            return "en";
        }
        return "cn";
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        //commonVM.versionInfo.observe(getViewLifecycleOwner(), resp -> {
        //    if (StringUtil.compareVersion(resp.appVersion, BuildConfig.VERSION_NAME) == 0) {
        //        ToastUtil.showShort(R.string.version_tips, BuildConfig.VERSION_NAME);
        //    }
        //});
    }
}
