package io.agora.meeting.viewmodel;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.MediatorLiveData;
import androidx.lifecycle.ViewModel;

import java.util.ArrayList;
import java.util.List;

import io.agora.meeting.data.Me;
import io.agora.meeting.data.Member;
import io.agora.meeting.data.ShareBoard;
import io.agora.meeting.data.ShareScreen;

public class RenderVideoModel extends ViewModel {
    public final MediatorLiveData<List<Member>> renders = new MediatorLiveData<>();

    public void init(MeetingViewModel viewModel) {
        renders.addSource(viewModel.me, me -> initRenders(me, viewModel.shareBoard.getValue(), viewModel.shareScreen.getValue(), viewModel.getHostsValue(), viewModel.getAudiencesValue()));
        renders.addSource(viewModel.shareBoard, shareBoard -> initRenders(viewModel.getMeValue(), shareBoard, viewModel.shareScreen.getValue(), viewModel.getHostsValue(), viewModel.getAudiencesValue()));
        renders.addSource(viewModel.shareScreen, shareScreen -> initRenders(viewModel.getMeValue(), viewModel.shareBoard.getValue(), shareScreen, viewModel.getHostsValue(), viewModel.getAudiencesValue()));
        renders.addSource(viewModel.hosts, hosts -> initRenders(viewModel.getMeValue(), viewModel.shareBoard.getValue(), viewModel.shareScreen.getValue(), hosts, viewModel.getAudiencesValue()));
        renders.addSource(viewModel.audiences, audiences -> initRenders(viewModel.getMeValue(), viewModel.shareBoard.getValue(), viewModel.shareScreen.getValue(), viewModel.getHostsValue(), audiences));
    }

    private void initRenders(@Nullable Me me, @Nullable ShareBoard shareBoard, @Nullable ShareScreen shareScreen, @NonNull List<Member> hosts, @NonNull List<Member> audiences) {
        List<Member> renders = new ArrayList<>();
        renders.add(me);
        if (shareBoard != null && shareBoard.isShareBoard()) {
            renders.add(shareBoard.shareBoardUsers.get(0));
        }
        if (shareScreen != null && shareScreen.isShareScreen()) {
            for (ShareScreen.Screen screen : shareScreen.shareScreenUsers) {
                int index = hosts.indexOf(screen);
                if (index > -1) {
                    renders.add(new ShareScreen.Screen(hosts.get(index)));
                } else {
                    index = audiences.indexOf(screen);
                    if (index > -1) {
                        renders.add(new ShareScreen.Screen(audiences.get(index)));
                    } else {
                        renders.add(screen);
                    }
                }
            }
        }
        renders.addAll(hosts);
        renders.addAll(audiences);
        this.renders.setValue(renders);
    }
}
