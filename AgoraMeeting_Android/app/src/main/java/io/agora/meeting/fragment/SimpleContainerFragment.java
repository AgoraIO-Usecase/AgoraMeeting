package io.agora.meeting.fragment;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentContainerView;
import androidx.fragment.app.FragmentManager;
import androidx.lifecycle.ViewModelProvider;

import io.agora.meeting.viewmodel.MeetingViewModel;

public class SimpleContainerFragment extends Fragment {
    private MeetingViewModel meetingVM;
    private FragmentManager manager;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        meetingVM = new ViewModelProvider(requireActivity()).get(MeetingViewModel.class);
        manager = getChildFragmentManager();
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        FragmentContainerView fragmentContainerView = new FragmentContainerView(requireContext());
        fragmentContainerView.setId(android.R.id.content);
        return fragmentContainerView;
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        meetingVM.shareBoard.observe(getViewLifecycleOwner(), shareBoard -> {
            if (shareBoard.isShareBoard()) {
                showBoard();
            } else {
                showVideo();
            }
        });
    }

    private void showBoard() {
        String tag = "board";
        if (manager.findFragmentByTag(tag) == null) {
            manager.beginTransaction()
                    .replace(android.R.id.content, new SimpleBoardFragment(), tag)
                    .commit();
        }
    }

    private void showVideo() {
        String tag = "video";
        if (manager.findFragmentByTag(tag) == null) {
            manager.beginTransaction()
                    .replace(android.R.id.content, new SimpleVideoFragment(), tag)
                    .commit();
        }
    }
}
