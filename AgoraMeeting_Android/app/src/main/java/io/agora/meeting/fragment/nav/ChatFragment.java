package io.agora.meeting.fragment.nav;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;

import io.agora.meeting.adapter.ChatAdapter;
import io.agora.meeting.base.BaseFragment;
import io.agora.meeting.databinding.FragmentChatBinding;
import io.agora.meeting.viewmodel.MeetingViewModel;
import io.agora.meeting.viewmodel.MessageViewModel;

public class ChatFragment extends BaseFragment<FragmentChatBinding> {
    private MessageViewModel messageVM;
    private ChatAdapter adapter;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        messageVM = new ViewModelProvider(requireActivity()).get(MessageViewModel.class);
    }

    @Override
    protected FragmentChatBinding createBinding(@NonNull LayoutInflater inflater, @Nullable ViewGroup container) {
        return FragmentChatBinding.inflate(inflater, container, false);
    }

    @Override
    protected void init() {
        binding.list.addOnLayoutChangeListener((v, left, top, right, bottom, oldLeft, oldTop, oldRight, oldBottom) -> binding.list.scrollToPosition(adapter.getItemCount() - 1));
        adapter = new ChatAdapter();
        binding.list.setAdapter(adapter);

        binding.setClickListener(v -> {
            new ViewModelProvider(requireActivity()).get(MeetingViewModel.class)
                    .sendMessage(binding.etMsg.getText().toString());
            binding.etMsg.setText(null);
        });
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        messageVM.chatMsgs.observe(getViewLifecycleOwner(), messages -> {
            adapter.submitList(messages);
            binding.list.scrollToPosition(adapter.getItemCount());
        });
    }

    @Override
    public void onPause() {
        super.onPause();
        messageVM.readChatMsgs();
    }
}
