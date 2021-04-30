package io.agora.meeting.ui.fragment;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import java.util.ArrayList;

import io.agora.meeting.ui.R;
import io.agora.meeting.ui.adapter.ChatAdapter;
import io.agora.meeting.ui.annotation.ChatState;
import io.agora.meeting.ui.base.BaseFragment;
import io.agora.meeting.ui.databinding.FragmentChatBinding;
import io.agora.meeting.ui.util.KeyboardUtil;
import io.agora.meeting.ui.util.ToastUtil;
import io.agora.meeting.ui.viewmodel.MessageViewModel;
import io.agora.meeting.ui.viewmodel.RoomViewModel;
import io.agora.meeting.ui.viewmodel.UserViewModel;

public class ChatFragment extends BaseFragment<FragmentChatBinding> {
    private RoomViewModel roomVM;
    private MessageViewModel messageVM;
    private UserViewModel localUserVM;

    private ChatAdapter adapter;
    private LinearLayoutManager mLayoutManager;
    private final Runnable scrollToBottomRun = () -> mLayoutManager.scrollToPositionWithOffset(Math.max(0, adapter.getItemCount() - 1), 0);

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        roomVM = new ViewModelProvider(requireActivity()).get(RoomViewModel.class);
        localUserVM = roomVM.getLocalUserViewModel();
        messageVM = roomVM.getMessageViewModel();
    }

    @Override
    protected FragmentChatBinding createBinding(@NonNull LayoutInflater inflater, @Nullable ViewGroup container) {
        return FragmentChatBinding.inflate(inflater, container, false);
    }

    @Override
    protected void init() {
        binding.touchOutside.setOnClickListener(v -> KeyboardUtil.hideInput(requireActivity()));
        binding.list.addOnLayoutChangeListener((v, left, top, right, bottom, oldLeft, oldTop, oldRight, oldBottom) -> mLayoutManager.scrollToPositionWithOffset(adapter.getItemCount() - 1, 0));
        mLayoutManager = new LinearLayoutManager(getContext(), LinearLayoutManager.VERTICAL, false);
        binding.list.setLayoutManager(mLayoutManager);
        adapter = new ChatAdapter();
        adapter.setOnItemClickListener((index, content) -> {
            sendMsg(content, index);
        });
        binding.list.setAdapter(adapter);

        binding.setClickListener(v -> {
            String content = binding.etMsg.getText().toString();
            if(!TextUtils.isEmpty(content)){
                int index = messageVM.sentLocalChatMsg(content);
                sendMsg(content, index);
                binding.etMsg.setText(null);
            }
        });
    }

    private void sendMsg(String content, int index) {
        messageVM.setLocalChatMsgState(index, ChatState.SENDING);
        adapter.notifyItemChanged(index);
        localUserVM.getUserModel().speak(content, data -> {
            messageVM.setLocalChatMsgState(index, ChatState.SUCCESS);
            adapter.notifyItemChanged(index);
        }, throwable -> {
            ToastUtil.showShort(R.string.chat_send_failed);
            messageVM.setLocalChatMsgState(index, ChatState.FAILED);
            adapter.notifyItemChanged(index);
        });
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        messageVM.chatMessages.observe(getViewLifecycleOwner(), messages -> {
            adapter.submitList(new ArrayList<>(messages), this::postScrollToBottom);
        });

        KeyboardUtil.listenKeyboardChange(getViewLifecycleOwner(), requireView(), visible -> {
            binding.touchOutside.setVisibility(visible ? View.VISIBLE : View.GONE);
        });
    }

    private void postScrollToBottom(){
        scrollToBottomRun.run();
    }

    @Override
    public void onPause() {
        super.onPause();
        messageVM.setChatMessagesRead();
        KeyboardUtil.hideInput(requireActivity());
    }
}
