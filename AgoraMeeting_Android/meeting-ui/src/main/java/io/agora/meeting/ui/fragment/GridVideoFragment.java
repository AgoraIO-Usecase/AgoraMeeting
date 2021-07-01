package io.agora.meeting.ui.fragment;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Rect;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.CheckBox;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.ListPopupWindow;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import java.util.ArrayList;
import java.util.List;

import io.agora.meeting.core.log.Logger;
import io.agora.meeting.core.model.StreamModel;
import io.agora.meeting.core.model.UserModel;
import io.agora.meeting.ui.R;
import io.agora.meeting.ui.adapter.GridVideoAdapter;
import io.agora.meeting.ui.adapter.StreamBinding;
import io.agora.meeting.ui.base.BaseFragment;
import io.agora.meeting.ui.data.RenderInfo;
import io.agora.meeting.ui.databinding.FragmentGridVideoBinding;
import io.agora.meeting.ui.util.UIUtil;
import io.agora.meeting.ui.util.UserOptionsUtil;
import io.agora.meeting.ui.viewmodel.RoomViewModel;
import io.agora.meeting.ui.viewmodel.StreamsVideoModel;
import io.agora.meeting.ui.viewmodel.UserViewModel;

public class GridVideoFragment extends BaseFragment<FragmentGridVideoBinding> {

    private StreamsVideoModel streamsVM;
    private int index;
    private GridVideoAdapter adapter;
    private RoomViewModel roomVM;
    private UserViewModel localUserVM;
    private final Runnable openRvAnimRun = () -> {
        if (binding != null) {
            UIUtil.openRVAnimator(binding.list);
        }
    };

    private View.OnLayoutChangeListener listLayoutChangeListener = new View.OnLayoutChangeListener() {
        @Override
        public void onLayoutChange(View v, int left, int top, int right, int bottom, int oldLeft, int oldTop, int oldRight, int oldBottom) {
            if (adapter != null) {
                adapter.notifyDataSetChanged();
            }
        }
    };

    public static GridVideoFragment getInstance(int index) {
        GridVideoFragment fragment = new GridVideoFragment();
        Bundle bundle = new GridVideoFragmentArgs.Builder(index).build().toBundle();
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        roomVM = new ViewModelProvider(requireActivity()).get(RoomViewModel.class);
        streamsVM = roomVM.getStreamsViewModel();
        localUserVM = roomVM.getLocalUserViewModel();

        GridVideoFragmentArgs args = GridVideoFragmentArgs.fromBundle(requireArguments());
        index = args.getIndex();
    }

    @Override
    protected FragmentGridVideoBinding createBinding(@NonNull LayoutInflater inflater, @Nullable ViewGroup container) {
        return FragmentGridVideoBinding.inflate(inflater, container, false);
    }

    @Override
    protected void init() {
        List<RenderInfo> value = streamsVM.renders.getValue();
        if (value == null || value.size() <= index) {
            return;
        }
        final RenderInfo renderInfo = value.get(index);

        binding.list.addOnLayoutChangeListener(listLayoutChangeListener);
        binding.list.addItemDecoration(new RecyclerView.ItemDecoration() {
            @Override
            public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
                int offset = 3;
                int width = (int) ((parent.getWidth() - offset * 2 * renderInfo.column) / renderInfo.column);
                int height = (int) ((parent.getHeight() - offset * 2 * renderInfo.row) / renderInfo.row);
                ViewGroup.LayoutParams layoutParams = view.getLayoutParams();
                layoutParams.width = width;
                layoutParams.height = height;
                view.setLayoutParams(layoutParams);
                outRect.set(offset, offset, offset, offset);
            }
        });
        binding.list.setLayoutManager(new GridLayoutManager(requireContext(), (int) renderInfo.column));
        adapter = new GridVideoAdapter();
        binding.list.setAdapter(adapter);
        adapter.setOnItemEventListener(new GridVideoAdapter.OnItemEventListener() {
            @Override
            public void onMoreRender(CheckBox v, StreamModel stream) {
                UserOptionsUtil.getUsersOptionIdsAsync(roomVM.getRoomModel(), localUserVM.getUserModel(), stream.getOwner(), stream, optionIds -> {
                    v.post(() -> {
                        v.setVisibility(optionIds.size() > 0 ? View.VISIBLE : View.GONE);
                    });
                });
            }

            @Override
            public void onMoreClick(CheckBox v, StreamModel stream) {
                // 弹出操作浮窗
                alertPopWindow(v, stream, localUserVM.getUserModel());
            }

            @Override
            public void onTopClick(CheckBox v, StreamModel stream) {
                // 置顶
                streamsVM.setTiledTop(stream, v.isChecked());
            }

            @Override
            public void onLayoutClick(View v, StreamModel stream) {
                // 切换成演讲者视图
                streamsVM.tiled2Speaker(stream);
            }
        });
    }

    @Override
    public void onDestroyView() {
        binding.list.removeOnLayoutChangeListener(listLayoutChangeListener);
        adapter = null;
        super.onDestroyView();
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        streamsVM.renders.observe(getViewLifecycleOwner(), renders -> {
            if(adapter != null){
                if(isSelected() || adapter.getItemCount() == 0){
                    adapter.submitList(getLatestStreams());
                }
            }
        });
    }

    @Override
    protected void onSelectedChanged(boolean selected) {
        super.onSelectedChanged(selected);
        Logger.d("GridVideoFragment", index + " index >> onSelectedChanged selected=" + selected);
        if(adapter != null){
            adapter.submitList(getLatestStreams());
        }
        if(!selected){
            binding.list.removeCallbacks(openRvAnimRun);
            UIUtil.closeRVtAnimator(binding.list);
        }else{
            postOpenRvAnimator();
        }
    }

    private void postOpenRvAnimator(){
        binding.list.removeCallbacks(openRvAnimRun);
        binding.list.postDelayed(openRvAnimRun, 1000);
    }

    private List<StreamModel> getLatestStreams(){
        List<RenderInfo> renders = streamsVM.renders.getValue();
        if(renders != null && renders.size() > index){
            RenderInfo renderInfo = renders.get(index);
            if (renderInfo.streams != null && renderInfo.streams.size() > 0) {
                for (StreamModel stream : renderInfo.streams) {
                    StreamBinding.setVisibleToUser(stream, isSelected());
                }
                return new ArrayList<>(renderInfo.streams);
            }
        }
        return new ArrayList<>();
    }

    private void alertPopWindow(CheckBox v, StreamModel streamModel, UserModel meUserModel) {
        Context context = v.getContext().getApplicationContext();
        UserOptionsUtil.getUsersOptionIdsAsync(roomVM.getRoomModel(), meUserModel, streamModel.getOwner(), streamModel, optionIds -> {
            if (optionIds.size() == 0) {
                return;
            }

            v.post(() -> {
                List<String> optionStrList = new ArrayList<>();
                for (Integer id : optionIds) {
                    optionStrList.add(context.getResources().getString(id));
                }

                // 弹窗
                final ListPopupWindow popupWindow = new ListPopupWindow(context);
                popupWindow.setWidth((int) context.getResources().getDimension(R.dimen.meeting_pop_dialog_width));
                popupWindow.setAnchorView(v);
                popupWindow.setVerticalOffset((int) context.getResources().getDimension(R.dimen.meeting_pop_dialog_offset));
                popupWindow.setDropDownGravity(Gravity.END);
                popupWindow.setBackgroundDrawable(getResources().getDrawable(R.drawable.bg_video_popup_window));
                popupWindow.setListSelector(new ColorDrawable(Color.TRANSPARENT));
                popupWindow.setAdapter(new ArrayAdapter<String>(context,
                        R.layout.layout_video_popup_item,
                        android.R.id.text1,
                        optionStrList) {
                    @NonNull
                    @Override
                    public View getView(int position, @Nullable View convertView, @NonNull ViewGroup parent) {
                        View view = super.getView(position, convertView, parent);
                        if (position != optionStrList.size() - 1) {
                            view.findViewById(R.id.divider).setVisibility(View.VISIBLE);
                        }
                        return view;
                    }
                });
                popupWindow.setOnItemClickListener((parent, view, position, id) -> {
                    UserOptionsUtil.handleOnClickEvent(optionIds.get(position), meUserModel, streamModel.getOwner(), streamModel);
                    popupWindow.dismiss();
                });
                popupWindow.setOnDismissListener(() -> {
                    v.setChecked(false);
                    v.post(() -> v.setEnabled(true));
                });
                v.setEnabled(false);
                popupWindow.show();
            });
        });
    }
}
