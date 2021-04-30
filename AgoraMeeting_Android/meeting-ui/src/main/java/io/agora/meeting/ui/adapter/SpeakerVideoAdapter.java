package io.agora.meeting.ui.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.ListAdapter;
import androidx.recyclerview.widget.RecyclerView;

import io.agora.meeting.core.model.StreamModel;
import io.agora.meeting.ui.databinding.LayoutSpeakerVideoBinding;
import io.agora.meeting.ui.util.AvatarUtil;

public class SpeakerVideoAdapter extends ListAdapter<StreamModel, SpeakerVideoAdapter.ViewHolder> {
    private OnItemClickListener onItemClickListener;

    public SpeakerVideoAdapter() {
        super(new StreamDiffCallback());
    }

    public void setOnItemClickListener(OnItemClickListener onItemClickListener) {
        this.onItemClickListener = onItemClickListener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new ViewHolder(parent, LayoutSpeakerVideoBinding.inflate(
                LayoutInflater.from(parent.getContext()),
                parent,
                false
        ));
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        holder.bind(getItem(position));
    }


    class ViewHolder extends RecyclerView.ViewHolder {
        private View parent;
        public LayoutSpeakerVideoBinding binding;

        ViewHolder(View parent, LayoutSpeakerVideoBinding binding) {
            super(binding.getRoot());
            this.parent = parent;
            this.binding = binding;
        }

        void bind(StreamModel stream) {
            binding.setStream(stream);
            binding.executePendingBindings();
            StreamBinding.bindStream(binding.flVideo, stream, false, true, false, false, false);
            AvatarUtil.loadCircleAvatar(parent, binding.ivAvatar, stream.getOwnerUserName());

            View child = binding.flVideo.getChildAt(0);
            if(child != null){
                child.setOnClickListener(v->{
                    if(onItemClickListener != null){
                        onItemClickListener.onLayoutClick(stream);
                    }
                });
            }
        }
    }


    public interface OnItemClickListener{
        void onLayoutClick(StreamModel stream);
    }
}
