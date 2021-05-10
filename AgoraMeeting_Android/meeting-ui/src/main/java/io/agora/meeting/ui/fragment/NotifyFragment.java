package io.agora.meeting.ui.fragment;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import java.util.ArrayList;

import io.agora.meeting.ui.adapter.NotifyAdapter;
import io.agora.meeting.ui.base.BaseFragment;
import io.agora.meeting.ui.databinding.FragmentNotifyBinding;
import io.agora.meeting.ui.viewmodel.MessageViewModel;
import io.agora.meeting.ui.viewmodel.RoomViewModel;

/**
 * Description: 通知
 *
 *
 * @since 2/1/21
 */
public class NotifyFragment extends BaseFragment<FragmentNotifyBinding> {
    private MessageViewModel messageVM;
    private NotifyAdapter adapter;
    private LinearLayoutManager mLayoutManager;
    private final Runnable scrollToBottomRun = ()->mLayoutManager.scrollToPositionWithOffset(Math.max(0, adapter.getItemCount() - 1), 0);

    @Override
    protected FragmentNotifyBinding createBinding(@NonNull LayoutInflater inflater,
                                                  @Nullable ViewGroup container) {
        return FragmentNotifyBinding.inflate(inflater);
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        RoomViewModel roomViewModel = new ViewModelProvider(requireActivity()).get(RoomViewModel.class);
        messageVM = roomViewModel.getMessageViewModel();
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        messageVM.actionMessages.observe(getViewLifecycleOwner(), actionMessages -> {
            if (binding != null) {
                if(adapter.getItemCount() == 0){
                    adapter.submitList(new ArrayList<>(actionMessages), this::postScrollToBottom);
                }else{
                    adapter.submitList(new ArrayList<>(actionMessages));
                }
            }
        });
    }

    private void postScrollToBottom(){
        scrollToBottomRun.run();
    }

    @Override
    protected void init() {
        mLayoutManager = new LinearLayoutManager(getContext(), LinearLayoutManager.VERTICAL, false);
        binding.list.setLayoutManager(mLayoutManager);
        //binding.list.addOnLayoutChangeListener((v, left, top, right, bottom, oldLeft, oldTop, oldRight, oldBottom) -> mLayoutManager.scrollToPositionWithOffset(adapter.getItemCount() - 1, 0));
        adapter = new NotifyAdapter();
        binding.list.setAdapter(adapter);
    }
}
