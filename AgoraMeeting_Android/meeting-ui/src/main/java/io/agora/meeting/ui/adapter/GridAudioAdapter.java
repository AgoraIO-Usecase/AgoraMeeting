package io.agora.meeting.ui.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.ListAdapter;
import androidx.recyclerview.widget.RecyclerView;

import java.util.List;

import io.agora.meeting.core.model.StreamModel;
import io.agora.meeting.ui.databinding.LayoutAudioViewBinding;
import io.agora.meeting.ui.util.AvatarUtil;

public class GridAudioAdapter extends ListAdapter<StreamModel, GridAudioAdapter.ViewHolder> {
    public GridAudioAdapter() {
        super(new StreamDiffCallback());
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new ViewHolder(parent, LayoutAudioViewBinding.inflate(LayoutInflater.from(parent.getContext())));
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        holder.bind(getItem(position));
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position, @NonNull List<Object> payloads) {
        holder.bind(getItem(position));
    }

    static class ViewHolder extends RecyclerView.ViewHolder {
        private View parent;
        public LayoutAudioViewBinding binding;

        ViewHolder(View parent, LayoutAudioViewBinding binding) {
            super(binding.getRoot());
            this.parent = parent;
            this.binding = binding;
        }

        void bind(StreamModel stream) {
            binding.setStream(stream);
            binding.executePendingBindings();
            AvatarUtil.loadCircleAvatar(parent, binding.ivAvatar, stream.getOwnerUserName());
        }
    }

}
