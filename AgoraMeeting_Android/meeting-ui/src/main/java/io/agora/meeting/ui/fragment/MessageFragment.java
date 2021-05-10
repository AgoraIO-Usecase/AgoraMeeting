package io.agora.meeting.ui.fragment;

import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import androidx.viewpager2.adapter.FragmentStateAdapter;

import com.google.android.material.tabs.TabLayoutMediator;

import io.agora.meeting.ui.R;
import io.agora.meeting.ui.base.BaseFragment;
import io.agora.meeting.ui.databinding.FragmentMessageBinding;
import io.agora.meeting.ui.util.KeyboardUtil;


/**
 * Description: 聊天+通知
 *
 *
 * @since 2/1/21
 */
public class MessageFragment extends BaseFragment<FragmentMessageBinding> {

    @Override
    protected FragmentMessageBinding createBinding(@NonNull LayoutInflater inflater, @Nullable ViewGroup container) {
        return FragmentMessageBinding.inflate(inflater, container, false);
    }

    @Override
    protected void init() {
        setupAppBar(binding.toolbar, false);
        binding.toolbar.setNavigationOnClickListener(v -> {
            KeyboardUtil.hideInput(requireActivity());
            ((AppCompatActivity)requireActivity()).onSupportNavigateUp();
        });
        binding.viewpager2.setAdapter(new FragmentStateAdapter(this) {
            @NonNull
            @Override
            public Fragment createFragment(int position) {
                if (position == 0) {
                    return new ChatFragment();
                }
                return new NotifyFragment();
            }

            @Override
            public int getItemCount() {
                return 2;
            }
        });
        new TabLayoutMediator(binding.tablayout, binding.viewpager2, (tab, position) -> {
            tab.setText(position == 0 ? R.string.main_chat : R.string.main_notification);
        }).attach();
    }

}
