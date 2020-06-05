package io.agora.meeting.fragment;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;

import io.agora.meeting.base.BaseFragment;
import io.agora.meeting.databinding.FragmentSimpleVideoBinding;
import io.agora.meeting.viewmodel.RenderVideoModel;

public class SimpleVideoFragment extends BaseFragment<FragmentSimpleVideoBinding> {
    private RenderVideoModel renderVM;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        renderVM = new ViewModelProvider(requireActivity()).get(RenderVideoModel.class);
    }

    @Override
    protected FragmentSimpleVideoBinding createBinding(@NonNull LayoutInflater inflater, @Nullable ViewGroup container) {
        return FragmentSimpleVideoBinding.inflate(inflater, container, false);
    }

    @Override
    protected void init() {

    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        renderVM.renders.observe(getViewLifecycleOwner(), renders -> {
            if (renders.size() > 0) {
                if (renders.size() == 1) {
                    binding.setLittle(null);
                    binding.setLarge(renders.get(0));
                } else {
                    binding.setLittle(renders.get(0));
                    binding.setLarge(renders.get(1));
                }
            }
        });
    }
}
