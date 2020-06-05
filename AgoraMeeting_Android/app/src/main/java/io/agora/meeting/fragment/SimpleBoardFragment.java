package io.agora.meeting.fragment;

import android.graphics.Color;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.ViewGroup;
import android.widget.RadioGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;

import com.flask.colorpicker.builder.ColorPickerDialogBuilder;
import com.herewhite.sdk.RoomParams;
import com.herewhite.sdk.WhiteSdk;
import com.herewhite.sdk.WhiteSdkConfiguration;
import com.herewhite.sdk.domain.Appliance;
import com.herewhite.sdk.domain.DeviceType;

import io.agora.meeting.R;
import io.agora.meeting.base.BaseCallback;
import io.agora.meeting.base.BaseFragment;
import io.agora.meeting.databinding.FragmentSimpleBoardBinding;
import io.agora.meeting.viewmodel.MeetingViewModel;
import io.agora.whiteboard.netless.manager.BoardManager;

public class SimpleBoardFragment extends BaseFragment<FragmentSimpleBoardBinding> implements RadioGroup.OnCheckedChangeListener {
    private MeetingViewModel meetingVM;
    private BoardManager manager;
    private WhiteSdk whiteSdk;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        meetingVM = new ViewModelProvider(requireActivity()).get(MeetingViewModel.class);
        manager = new BoardManager();
    }

    @Override
    protected FragmentSimpleBoardBinding createBinding(@NonNull LayoutInflater inflater, @Nullable ViewGroup container) {
        return FragmentSimpleBoardBinding.inflate(inflater, container, false);
    }

    @Override
    protected void init() {
        WhiteSdkConfiguration configuration = new WhiteSdkConfiguration(DeviceType.touch, 10, 0.1);
        whiteSdk = new WhiteSdk(binding.whiteBoardView, requireContext(), configuration);

        binding.rgAppliance.setOnCheckedChangeListener(this);
        binding.setClickListener(v -> {
            switch (v.getId()) {
                case R.id.btn_color:
                    int[] strokeColor = manager.getStrokeColor();
                    if (strokeColor == null) return;
                    ColorPickerDialogBuilder.with(requireContext())
                            .initialColor(Color.argb(255, strokeColor[0], strokeColor[1], strokeColor[2]))
                            .showAlphaSlider(false)
                            .setPositiveButton(R.string._continue, (d, lastSelectedColor, allColors) ->
                                    manager.setStrokeColor(new int[]{Color.red(lastSelectedColor), Color.green(lastSelectedColor), Color.blue(lastSelectedColor)})
                            )
                            .setNegativeButton(R.string.cancel, null)
                            .build().show();
                    break;
                case R.id.btn_apply:
                    meetingVM.switchBoardState(meetingVM.getMeValue());
                    break;
            }
        });
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        meetingVM.roomBoard(meetingVM.getRoomId(), new BaseCallback<>(data -> {
            RoomParams roomParams = new RoomParams(data.boardId, data.boardToken);
            roomParams.setWritable(meetingVM.isGrantBoard(meetingVM.getMeValue()));
            manager.init(whiteSdk, roomParams);
        }));
        meetingVM.shareBoard.observe(getViewLifecycleOwner(), shareBoard -> manager.setWritable(meetingVM.isGrantBoard(meetingVM.getMeValue())));
        binding.setViewModel(meetingVM);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        whiteSdk.releaseRoom();
    }

    @Override
    public void onCheckedChanged(RadioGroup group, int checkedId) {
        switch (checkedId) {
            case R.id.rb_selector:
                manager.setAppliance(Appliance.SELECTOR);
                break;
            case R.id.rb_pencil:
                manager.setAppliance(Appliance.PENCIL);
                break;
            case R.id.rb_text:
                manager.setAppliance(Appliance.TEXT);
                break;
            case R.id.rb_eraser:
                manager.setAppliance(Appliance.ERASER);
                break;
        }
    }
}
