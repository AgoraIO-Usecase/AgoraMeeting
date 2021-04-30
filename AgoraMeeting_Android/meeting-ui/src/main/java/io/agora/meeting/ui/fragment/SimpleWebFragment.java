package io.agora.meeting.ui.fragment;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.ViewGroup;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.agora.meeting.ui.R;
import io.agora.meeting.ui.adapter.BindingAdapters;
import io.agora.meeting.ui.base.BaseFragment;
import io.agora.meeting.ui.databinding.FragmentSimpleWebBinding;

/**
 * Description:
 *
 *
 * @since 3/11/21
 */
public class SimpleWebFragment extends BaseFragment<FragmentSimpleWebBinding> {

    private String mUrl;

    @Override
    protected FragmentSimpleWebBinding createBinding(@NonNull LayoutInflater inflater, @Nullable ViewGroup container) {
        return FragmentSimpleWebBinding.inflate(inflater);
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        SimpleWebFragmentArgs args = SimpleWebFragmentArgs.fromBundle(requireArguments());
        mUrl = args.getUrl();
    }

    @Override
    protected void init() {
        setupAppBar(binding.toolbar, false);
        binding.toolbar.setTitle("");
        WebSettings webSettings = binding.webview.getSettings();
        webSettings.setJavaScriptEnabled(true);

        binding.webview.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageFinished(WebView view, String url) {
                super.onPageFinished(view, url);
                String title = view.getTitle();
                if (!TextUtils.isEmpty(title) && binding != null) {
                    BindingAdapters.bindToolbarTitle(binding.toolbar, true, title,
                            getResources().getColor(R.color.global_text_color_black),
                            getResources().getDimension(R.dimen.global_text_size_middle));
                }
            }
        });
        binding.webview.loadUrl(mUrl);
    }
}
