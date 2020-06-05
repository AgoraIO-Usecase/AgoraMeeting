package io.agora.meeting.viewmodel;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.MediatorLiveData;
import androidx.lifecycle.ViewModel;

import java.util.ArrayList;
import java.util.List;

import io.agora.meeting.data.Me;
import io.agora.meeting.data.Member;

public class MemberViewModel extends ViewModel {
    public final MediatorLiveData<List<Member>> members = new MediatorLiveData<>();

    public void init(MeetingViewModel viewModel) {
        members.addSource(viewModel.me, me -> initMembers(me, viewModel.getHostsValue(), viewModel.getAudiencesValue()));
        members.addSource(viewModel.hosts, hosts -> initMembers(viewModel.getMeValue(), hosts, viewModel.getAudiencesValue()));
        members.addSource(viewModel.audiences, audiences -> initMembers(viewModel.getMeValue(), viewModel.getHostsValue(), audiences));
    }

    private void initMembers(@Nullable Me me, @NonNull List<Member> hosts, @NonNull List<Member> audiences) {
        List<Member> members = new ArrayList<>();
        members.add(me);
        members.addAll(hosts);
        members.addAll(audiences);
        this.members.setValue(members);
    }
}
