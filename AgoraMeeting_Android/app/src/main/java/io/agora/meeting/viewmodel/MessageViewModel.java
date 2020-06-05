package io.agora.meeting.viewmodel;

import androidx.annotation.NonNull;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.Transformations;
import androidx.lifecycle.ViewModel;

import java.util.ArrayList;
import java.util.List;

import io.agora.meeting.data.BroadcastMsg;
import io.agora.meeting.data.PeerMsg;

public class MessageViewModel extends ViewModel {
    public final MutableLiveData<List<BroadcastMsg.Chat>> chatMsgs = new MutableLiveData<>();
    public final LiveData<List<BroadcastMsg.Chat>> unReadChatMsgs = Transformations.map(chatMsgs, input -> {
        List<BroadcastMsg.Chat> messages = new ArrayList<>();
        for (BroadcastMsg.Chat chat : input) {
            if (!chat.data.isRead) {
                messages.add(chat);
            }
        }
        return messages;
    });

    public final MutableLiveData<List<PeerMsg.Admin>> adminMsgs = new MutableLiveData<>();
    public final MutableLiveData<List<PeerMsg.Normal>> normalMsgs = new MutableLiveData<>();

    @NonNull
    public List<BroadcastMsg.Chat> getChatMsgsValue() {
        List<BroadcastMsg.Chat> messages = this.chatMsgs.getValue();
        if (messages == null) {
            messages = new ArrayList<>();
        }
        return new ArrayList<>(messages);
    }

    public void updateChatMsgs(@NonNull List<BroadcastMsg.Chat> messages) {
        this.chatMsgs.postValue(messages);
    }

    public void readChatMsgs() {
        List<BroadcastMsg.Chat> messages = getChatMsgsValue();
        for (BroadcastMsg.Chat message : messages) {
            message.data.isRead = true;
        }
        updateChatMsgs(messages);
    }

    @NonNull
    public List<PeerMsg.Admin> getAdminMsgsValue() {
        List<PeerMsg.Admin> adminMsgs = this.adminMsgs.getValue();
        if (adminMsgs == null) {
            adminMsgs = new ArrayList<>();
        }
        return new ArrayList<>(adminMsgs);
    }

    @NonNull
    public List<PeerMsg.Normal> getNormalMsgsValue() {
        List<PeerMsg.Normal> normalMsgs = this.normalMsgs.getValue();
        if (normalMsgs == null) {
            normalMsgs = new ArrayList<>();
        }
        return new ArrayList<>(normalMsgs);
    }

    public void updateAdminMsgs(@NonNull List<PeerMsg.Admin> adminMsgs) {
        this.adminMsgs.postValue(adminMsgs);
    }

    public void updateNormalMsgs(@NonNull List<PeerMsg.Normal> normalMsgs) {
        this.normalMsgs.postValue(normalMsgs);
    }
}
