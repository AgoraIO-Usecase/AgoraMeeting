package io.agora.meeting.fragment.nav;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.Navigation;
import androidx.recyclerview.widget.DividerItemDecoration;

import java.util.ArrayList;
import java.util.HashMap;

import io.agora.meeting.R;
import io.agora.meeting.adapter.MemberListAdapter;
import io.agora.meeting.base.BaseFragment;
import io.agora.meeting.base.OnItemClickListener;
import io.agora.meeting.data.Member;
import io.agora.meeting.databinding.FragmentMemberListBinding;
import io.agora.meeting.fragment.ActionSheetFragment;
import io.agora.meeting.fragment.InviteFragment;
import io.agora.meeting.util.TipsUtil;
import io.agora.meeting.viewmodel.MeetingViewModel;
import io.agora.meeting.viewmodel.MemberViewModel;

public class MemberListFragment extends BaseFragment<FragmentMemberListBinding> implements OnItemClickListener {
    private MeetingViewModel meetingVM;
    private MemberViewModel memberVM;
    private MemberListAdapter adapter;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        meetingVM = new ViewModelProvider(requireActivity()).get(MeetingViewModel.class);
        memberVM = new ViewModelProvider(this).get(MemberViewModel.class);
        memberVM.init(meetingVM);
    }

    @Override
    protected FragmentMemberListBinding createBinding(@NonNull LayoutInflater inflater, @Nullable ViewGroup container) {
        return FragmentMemberListBinding.inflate(inflater, container, false);
    }

    @Override
    protected void init() {
        binding.list.addItemDecoration(new DividerItemDecoration(requireContext(), DividerItemDecoration.VERTICAL));
        adapter = new MemberListAdapter();
        adapter.setOnItemClickListener(this);
        binding.list.setAdapter(adapter);

        binding.setClickListener(v -> {
            switch (v.getId()) {
                case R.id.btn_invite:
                    new InviteFragment().show(getChildFragmentManager(), null);
                    break;
                case R.id.btn_chat:
                    Navigation.findNavController(v).navigate(MemberListFragmentDirections.actionMemberListFragmentToChatFragment());
                    break;
            }
        });
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        meetingVM.me.observe(getViewLifecycleOwner(), me -> setHasOptionsMenu(me.isHost()));
        memberVM.members.observe(getViewLifecycleOwner(), members -> {
            binding.setMemberNum(members.size());
            adapter.submitList(members);
        });
    }

    @Override
    public void onCreateOptionsMenu(@NonNull Menu menu, @NonNull MenuInflater inflater) {
        inflater.inflate(R.menu.fragment_member_list, menu);
        super.onCreateOptionsMenu(menu, inflater);
    }

    @Override
    public void onItemClick(View view, int position, long id) {
        Member member = adapter.getItem(position);
        showActionSheet(member);
    }

    private void showActionSheet(Member member) {
        final int boardMenuTitle = TipsUtil.getBoardMenuTitle(meetingVM, member);
        ActionSheetFragment actionSheet = ActionSheetFragment.getInstance(R.menu.member_control);
        actionSheet.resetMenuTitle(new HashMap<Integer, Integer>() {{
            put(R.id.menu_mic, member.isAudioEnable() ? R.string.mute_audio : R.string.unmute_audio);
            put(R.id.menu_video, member.isVideoEnable() ? R.string.close_video : R.string.open_video);
            put(R.id.menu_board, boardMenuTitle);
        }});
        actionSheet.removeMenu(new ArrayList<Integer>() {{
            if (meetingVM.isHost(meetingVM.getMeValue())) { // I'm host
                if (meetingVM.isMe(member)) {
                    add(R.id.menu_host);
                    add(R.id.menu_room);
                }
            } else { // I'm not host
                if (!meetingVM.isMe(member)) {
                    add(R.id.menu_mic);
                    add(R.id.menu_video);
                }
                add(R.id.menu_host);
                add(R.id.menu_room);
            }
            if (boardMenuTitle == 0) {
                add(R.id.menu_board);
            }
        }});
        actionSheet.setOnItemClickListener((view, position, id) -> {
            if (id == R.id.menu_mic) {
                meetingVM.switchAudioState(member, requireContext());
            } else if (id == R.id.menu_video) {
                meetingVM.switchVideoState(member);
            } else if (id == R.id.menu_host) {
                meetingVM.setHost(member);
            } else if (id == R.id.menu_board) {
                meetingVM.switchBoardState(member);
            } else if (id == R.id.menu_room) {
                meetingVM.exitRoom(member);
            }
        });
        actionSheet.show(getChildFragmentManager(), null);
    }
}
