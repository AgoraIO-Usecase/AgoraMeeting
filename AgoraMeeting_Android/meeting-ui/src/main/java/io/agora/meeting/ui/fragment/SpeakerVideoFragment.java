package io.agora.meeting.ui.fragment;

import android.graphics.Rect;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import java.util.List;

import io.agora.meeting.core.model.RoomModel;
import io.agora.meeting.core.model.StreamModel;
import io.agora.meeting.ui.MeetingActivity;
import io.agora.meeting.ui.R;
import io.agora.meeting.ui.adapter.SpeakerVideoAdapter;
import io.agora.meeting.ui.adapter.StreamBinding;
import io.agora.meeting.ui.base.BaseFragment;
import io.agora.meeting.ui.data.RenderInfo;
import io.agora.meeting.ui.databinding.FragmentSpeakerVideoBinding;
import io.agora.meeting.ui.viewmodel.RoomViewModel;
import io.agora.meeting.ui.viewmodel.StreamsVideoModel;

/**
 * Description: 演讲者视图
 *
 *
 * @since 1/21/21
 */
public class SpeakerVideoFragment extends BaseFragment<FragmentSpeakerVideoBinding> {

    private StreamsVideoModel streamsVM;
    private RoomViewModel roomVM;
    private int index;
    private SpeakerVideoAdapter adapter;
    private FrameLayout mMainVideoContainer;


    public static SpeakerVideoFragment getInstance(int index) {
        SpeakerVideoFragment fragment = new SpeakerVideoFragment();
        Bundle bundle = new SpeakerVideoFragmentArgs.Builder(index).build().toBundle();
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    protected FragmentSpeakerVideoBinding createBinding(@NonNull LayoutInflater inflater, @Nullable ViewGroup container) {
        return FragmentSpeakerVideoBinding.inflate(inflater, container, false);
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        roomVM = new ViewModelProvider(requireActivity()).get(RoomViewModel.class);
        streamsVM = roomVM.getStreamsViewModel();
        GridVideoFragmentArgs args = GridVideoFragmentArgs.fromBundle(requireArguments());
        index = args.getIndex();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        detachMainVideoContainer();
    }

    private void detachMainVideoContainer(){
        if(mMainVideoContainer != null && mMainVideoContainer.getParent() != null){
            ((ViewGroup)mMainVideoContainer.getParent()).removeView(mMainVideoContainer);
            mMainVideoContainer = null;
        }
    }

    private void renderMainStream(ViewGroup container, StreamModel stream, boolean overlay){
        if(mMainVideoContainer == null){
            mMainVideoContainer = new FrameLayout(requireContext());
        }
        if(mMainVideoContainer.getParent() != container){
            detachMainVideoContainer();
            container.addView(mMainVideoContainer, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        }
        StreamBinding.bindStream(binding.flVideo, stream, false, overlay, true, false, true);
    }

    @Override
    protected void init() {
        final int offset = (int) getResources().getDimension(R.dimen.meeting_speaker_video_offset);
        binding.list.addItemDecoration(new RecyclerView.ItemDecoration() {
            @Override
            public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
                outRect.set(offset, offset, offset, offset);
            }
        });
        binding.list.setLayoutManager(new LinearLayoutManager(requireContext(), LinearLayoutManager.HORIZONTAL, false));
        adapter = new SpeakerVideoAdapter();
        binding.list.setAdapter(adapter);
        adapter.setOnItemClickListener(stream -> {
            streamsVM.tiled2Speaker(stream);
        });

        binding.ivTiledSwitch.setOnClickListener(v->streamsVM.speaker2Tiled());

        binding.tvEnterWhiteboard.setOnClickListener(v->{
            StreamModel streamModel = streamsVM.renders.getValue().get(index).streams.get(0);
            ((MeetingActivity)requireActivity()).navigateToBoardPage(requireView(), streamModel.getOwnerUserId(), streamModel.getStreamId());
        });
        binding.tvStopScreen.setOnClickListener(v -> new AlertDialog.Builder(requireContext())
                .setMessage(R.string.notify_popup_leave_with_screenshare_on)
                .setNegativeButton(R.string.cmm_no, (dialog, which) -> dialog.dismiss())
                .setPositiveButton(R.string.cmm_yes, (dialog, which) -> {
                    roomVM.getLocalUserViewModel().getUserModel().stopScreenShare();
                })
                .show());
    }

    private void updateLayout(RenderInfo renderInfo) {
        RoomModel roomModel = roomVM.getRoomModel();
        if(roomModel == null){
            return;
        }
        binding.ivTiledSwitch.setVisibility(roomModel.isBoardSharing() || roomModel.isScreenSharing() ? View.GONE : View.VISIBLE);

        List<StreamModel> members = renderInfo.streams;

        // 主演讲者
        StreamModel speaker = members.get(0);
        binding.setSpeakerStream(speaker);
        binding.executePendingBindings();
        renderMainStream(binding.flVideo, speaker, members.size() == 1);

        // 其他与会者
        if(members.size() > 1){
            adapter.submitList(members.subList(1, members.size()));
        }else{
            adapter.submitList(null);
        }
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        streamsVM.renders.observe(getViewLifecycleOwner(), renders -> updateLayout(renders.get(index)));
    }

}
