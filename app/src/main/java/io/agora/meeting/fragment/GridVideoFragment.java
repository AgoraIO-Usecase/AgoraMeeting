package io.agora.meeting.fragment;

import android.graphics.Rect;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.RecyclerView;

import io.agora.meeting.adapter.GridVideoAdapter;
import io.agora.meeting.base.BaseFragment;
import io.agora.meeting.databinding.FragmentGridVideoBinding;
import io.agora.meeting.viewmodel.RenderVideoModel;

public class GridVideoFragment extends BaseFragment<FragmentGridVideoBinding> {
    private static final int SPAN_COUNT = 2;

    private RenderVideoModel renderVM;
    private int fromIndex;
    private int toIndex;
    private GridVideoAdapter adapter;

    public static GridVideoFragment getInstance(int fromIndex, int toIndex) {
        GridVideoFragment fragment = new GridVideoFragment();
        Bundle bundle = new GridVideoFragmentArgs.Builder(fromIndex, toIndex).build().toBundle();
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        renderVM = new ViewModelProvider(requireActivity()).get(RenderVideoModel.class);

        GridVideoFragmentArgs args = GridVideoFragmentArgs.fromBundle(requireArguments());
        fromIndex = args.getFromIndex();
        toIndex = args.getToIndex();
    }

    @Override
    protected FragmentGridVideoBinding createBinding(@NonNull LayoutInflater inflater, @Nullable ViewGroup container) {
        return FragmentGridVideoBinding.inflate(inflater, container, false);
    }

    @Override
    protected void init() {
        binding.list.addItemDecoration(new RecyclerView.ItemDecoration() {
            @Override
            public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
                int offset = 3;
                int width = (parent.getWidth() - offset * 2 * SPAN_COUNT) / SPAN_COUNT;
                int height = (parent.getHeight() - offset * 2 * SPAN_COUNT) / SPAN_COUNT;
                ViewGroup.LayoutParams layoutParams = view.getLayoutParams();
                layoutParams.width = width;
                layoutParams.height = height;
                view.setLayoutParams(layoutParams);
                outRect.set(offset, offset, offset, offset);
            }
        });
        adapter = new GridVideoAdapter();
        binding.list.setAdapter(adapter);
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        renderVM.renders.observe(getViewLifecycleOwner(), renders -> adapter.submitList(renders.subList(Math.min(fromIndex, renders.size()), Math.min(toIndex, renders.size()))));
    }
}
