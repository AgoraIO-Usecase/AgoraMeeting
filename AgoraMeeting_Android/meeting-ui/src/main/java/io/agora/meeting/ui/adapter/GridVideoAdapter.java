package io.agora.meeting.ui.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.ListAdapter;
import androidx.recyclerview.widget.RecyclerView;

import java.util.List;

import io.agora.meeting.core.model.StreamModel;
import io.agora.meeting.ui.databinding.LayoutMediaViewBinding;
import io.agora.meeting.ui.util.AvatarUtil;

public class GridVideoAdapter extends ListAdapter<StreamModel, GridVideoAdapter.ViewHolder> {

    private OnItemEventListener onItemEventListener;

    public GridVideoAdapter() {
        super(new StreamDiffCallback());
    }

    public void setOnItemEventListener(OnItemEventListener onItemEventListener) {
        this.onItemEventListener = onItemEventListener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new ViewHolder(parent, LayoutMediaViewBinding.inflate(LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        holder.bind(getItem(position));
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position, @NonNull List<Object> payloads) {
        holder.bind(getItem(position));
    }

    class ViewHolder extends RecyclerView.ViewHolder {
        private View parent;
        public LayoutMediaViewBinding binding;

        ViewHolder(View parent, LayoutMediaViewBinding binding) {
            super(binding.getRoot());
            this.parent = parent;
            this.binding = binding;
        }

        void bind(StreamModel stream) {
            binding.setStream(stream);
            binding.executePendingBindings();
            StreamBinding.bindStream(binding.flVideo, stream, false, true, false, true, true);
            AvatarUtil.loadCircleAvatar(parent, binding.ivAvatar, stream.getOwnerUserName());

            View child = binding.flVideo.getChildAt(0);
            if (child != null) {
                child.setOnClickListener(v -> {
                    if(onItemEventListener != null){
                        onItemEventListener.onLayoutClick(v, stream);
                    }
                });
            }

            // 更多操作菜单
            if(onItemEventListener != null){
                onItemEventListener.onMoreRender(binding.cbMore, stream);
            }
            binding.cbMore.setOnClickListener(v -> {
                if(onItemEventListener != null){
                    onItemEventListener.onMoreClick(binding.cbMore, stream);
                }
            });

            // 用户置顶
            binding.cbTop.setOnClickListener((btn) -> {
                if(onItemEventListener != null){
                    onItemEventListener.onTopClick(binding.cbTop, stream);
                }
            });
        }

    }


    public interface OnItemEventListener {
        void onMoreRender(CheckBox v, StreamModel stream);
        void onMoreClick(CheckBox v, StreamModel stream);
        void onTopClick(CheckBox v, StreamModel stream);
        void onLayoutClick(View v, StreamModel stream);
    }
}
