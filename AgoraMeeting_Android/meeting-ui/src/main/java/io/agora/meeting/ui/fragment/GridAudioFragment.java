package io.agora.meeting.ui.fragment;

import android.graphics.Rect;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import java.util.List;

import io.agora.meeting.core.log.Logger;
import io.agora.meeting.ui.R;
import io.agora.meeting.ui.adapter.GridAudioAdapter;
import io.agora.meeting.ui.base.BaseFragment;
import io.agora.meeting.ui.data.RenderInfo;
import io.agora.meeting.ui.databinding.FragmentGridAudioBinding;
import io.agora.meeting.ui.util.UIUtil;
import io.agora.meeting.ui.viewmodel.RoomViewModel;
import io.agora.meeting.ui.viewmodel.StreamsVideoModel;

/**
 * Description: 语音视图
 *
 *
 * @since 1/20/21
 */
public class GridAudioFragment extends BaseFragment<FragmentGridAudioBinding> {

    private StreamsVideoModel streamsVM;
    private int index;
    private GridAudioAdapter adapter;
    private Runnable updateLayoutRun = this::updateLayout;
    private int lastLayoutUpdateSize = 0;
    private RenderInfo mRenderInfo;

    public static GridAudioFragment getInstance(int index) {
        GridAudioFragment fragment = new GridAudioFragment();
        Bundle bundle = new GridAudioFragmentArgs.Builder(index).build().toBundle();
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    protected FragmentGridAudioBinding createBinding(@NonNull LayoutInflater inflater, @Nullable ViewGroup container) {
        return FragmentGridAudioBinding.inflate(inflater, container, false);
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        streamsVM = new ViewModelProvider(requireActivity()).get(RoomViewModel.class).getStreamsViewModel();
        GridVideoFragmentArgs args = GridVideoFragmentArgs.fromBundle(requireArguments());
        index = args.getIndex();
    }

    @Override
    protected void init() {
        List<RenderInfo> value = streamsVM.renders.getValue();
        if(value == null){
            return;
        }
        adapter = new GridAudioAdapter();
        UIUtil.closeRVtAnimator(binding.list);
        binding.list.setAdapter(adapter);

        if(index < value.size()){
            mRenderInfo = value.get(index);
            postUpdateLayout();
        }
    }

    private void postUpdateLayout(){
        if(getView() == null){
            return;
        }
        if(getView().getHeight() <= 0){
            getView().removeCallbacks(updateLayoutRun);
            getView().post(updateLayoutRun);
        }
        else{
            updateLayout();
        }
    }

    private void updateLayout() {
        if(getView() == null || mRenderInfo == null){
            return;
        }

        int size = mRenderInfo.streams.size();
        if(lastLayoutUpdateSize == size){
            return;
        }

        int column = (int) mRenderInfo.column * 2;
        int row = (int) mRenderInfo.row;
        if (row == 0) {
            return;
        }

        lastLayoutUpdateSize = size;
        int height = getView().getHeight();
        if(height == 0){
            height = getResources().getDimensionPixelOffset(R.dimen.meeting_grid_audio_height);
        }
        height -= getResources().getDimensionPixelOffset(R.dimen.meeting_grid_audio_padding) * 2;
        int itemHeight = height / row;
        binding.list.addItemDecoration(new RecyclerView.ItemDecoration() {
            @Override
            public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
                super.getItemOffsets(outRect, view, parent, state);
                ViewGroup.LayoutParams layoutParams = view.getLayoutParams();
                layoutParams.height = itemHeight;
                view.setLayoutParams(layoutParams);
            }
        });
        int showRowSize = size / (column / 2) + 1;
        GridLayoutManager layoutManager = new GridLayoutManager(requireContext(), column);
        layoutManager.setSpanSizeLookup(new GridLayoutManager.SpanSizeLookup() {
            @Override
            public int getSpanSize(int position) {
                int pRow = position / (column / 2);
                if(pRow == showRowSize - 1){
                    int leftCount = size - pRow * column / 2;
                    if(leftCount == 0){
                        return column / 3;
                    }
                    return column / leftCount;
                }
                return column / 3;
            }
        });
        binding.list.setLayoutManager(layoutManager);
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        if(streamsVM == null){
            return;
        }
        streamsVM.renders.observe(getViewLifecycleOwner(), renders -> {
            if(index < renders.size()){
                mRenderInfo = renders.get(index);
                if(isSelected() || adapter.getItemCount() == 0){
                    Logger.d("GridAudioFragment", index + " index >> refresh layout onActivityCreated: " + GridAudioFragment.this.toString());
                    adapter.submitList(mRenderInfo.streams);
                    postUpdateLayout();
                }
            }else{
                mRenderInfo = null;
            }
        });
    }

    @Override
    protected void onSelectedChanged(boolean selected) {
        super.onSelectedChanged(selected);
        if(selected && adapter != null && mRenderInfo != null){
            adapter.submitList(mRenderInfo.streams);
            postUpdateLayout();
        }
    }

}
