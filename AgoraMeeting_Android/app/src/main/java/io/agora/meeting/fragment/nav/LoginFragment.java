package io.agora.meeting.fragment.nav;

import android.graphics.Color;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.Navigation;

import io.agora.base.util.UUIDUtil;
import io.agora.meeting.R;
import io.agora.meeting.annotaion.member.ModuleState;
import io.agora.meeting.annotaion.room.NetworkQuality;
import io.agora.meeting.base.BaseFragment;
import io.agora.meeting.databinding.FragmentLoginBinding;
import io.agora.meeting.service.body.req.RoomEntryReq;
import io.agora.meeting.viewmodel.MeetingViewModel;
import io.agora.meeting.viewmodel.PreferenceViewModel;
import io.agora.meeting.viewmodel.RtcViewModel;
import io.agora.meeting.widget.TipsPopup;

public class LoginFragment extends BaseFragment<FragmentLoginBinding> {
    private PreferenceViewModel preferenceVM;
    private MeetingViewModel meetingVM;
    private RtcViewModel rtcVM;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);

        ViewModelProvider provider = new ViewModelProvider(this);
        preferenceVM = provider.get(PreferenceViewModel.class);
        meetingVM = provider.get(MeetingViewModel.class);
        rtcVM = provider.get(RtcViewModel.class);
    }

    @Override
    protected FragmentLoginBinding createBinding(@NonNull LayoutInflater inflater, @Nullable ViewGroup container) {
        return FragmentLoginBinding.inflate(inflater, container, false);
    }

    @Override
    protected void init() {
        binding.setClickListener(v -> {
            switch (v.getId()) {
                case R.id.btn_tips:
                    new TipsPopup(this)
                            .setBackgroundColor(Color.TRANSPARENT)
                            .setPopupGravity(Gravity.BOTTOM)
                            .showPopupWindow(v);
                    break;
                case R.id.btn_enter:
                    meetingVM.entryRoom(new RoomEntryReq() {{
                        userName = binding.etName.getText().toString();
                        userUuid = UUIDUtil.getUUID();
                        roomName = binding.etRoomName.getText().toString();
                        roomUuid = roomName;
                        password = binding.etRoomPwd.getText().toString();
                        enableVideo = binding.swCamera.isChecked() ? ModuleState.ENABLE : ModuleState.DISABLE;
                        enableAudio = binding.swMic.isChecked() ? ModuleState.ENABLE : ModuleState.DISABLE;
                    }}, res -> {
                        try {
                            Navigation.findNavController(v).navigate(LoginFragmentDirections.actionLoginFragmentToMeetingFragment(res));
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    });
                    break;
            }
        });
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        rtcVM.networkQuality.observe(getViewLifecycleOwner(), networkQuality -> {
            MenuItem item = binding.toolbar.getMenu().findItem(R.id.menu_signal);
            int drawableId;
            switch (networkQuality) {
                case NetworkQuality.GOOD:
                    drawableId = R.drawable.ic_signal_good;
                    break;
                case NetworkQuality.POOR:
                    drawableId = R.drawable.ic_signal_poor;
                    break;
                case NetworkQuality.BAD:
                    drawableId = R.drawable.ic_signal_bad;
                    break;
                case NetworkQuality.IDLE:
                default:
                    drawableId = R.drawable.ic_signal_idle;
                    break;
            }
            item.setIcon(drawableId);
        });
        rtcVM.enableLastMileTest(true);
        binding.setViewModel(preferenceVM);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        rtcVM.enableLastMileTest(false);
    }

    @Override
    public void onCreateOptionsMenu(@NonNull Menu menu, @NonNull MenuInflater inflater) {
        inflater.inflate(R.menu.fragment_login, menu);
        super.onCreateOptionsMenu(menu, inflater);
    }
}
