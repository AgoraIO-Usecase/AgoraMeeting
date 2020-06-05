package io.agora.meeting.adapter;

import android.text.TextUtils;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.DiffUtil;
import androidx.recyclerview.widget.ListAdapter;
import androidx.recyclerview.widget.RecyclerView;

import java.util.List;
import java.util.Objects;

import io.agora.meeting.data.Member;
import io.agora.meeting.databinding.LayoutMediaViewBinding;
import io.agora.meeting.widget.MediaView;

public class GridVideoAdapter extends ListAdapter<Member, GridVideoAdapter.ViewHolder> {
    public GridVideoAdapter() {
        super(new DiffCallback());
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        MediaView view = new MediaView(parent.getContext());
        return new ViewHolder(view);
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
        public LayoutMediaViewBinding binding;

        ViewHolder(MediaView view) {
            super(view);
            binding = view.binding;
        }

        void bind(Member member) {
            binding.setMember(member);
            binding.executePendingBindings();
        }
    }

    private static class DiffCallback extends DiffUtil.ItemCallback<Member> {
        @Override
        public boolean areItemsTheSame(@NonNull Member oldItem, @NonNull Member newItem) {
            return TextUtils.equals(oldItem.userId, newItem.userId);
        }

        @Override
        public boolean areContentsTheSame(@NonNull Member oldItem, @NonNull Member newItem) {
            return TextUtils.equals(oldItem.userName, newItem.userName)
                    && Objects.equals(oldItem.role, newItem.role)
                    && Objects.equals(oldItem.enableChat, newItem.enableChat)
                    && Objects.equals(oldItem.enableVideo, newItem.enableVideo)
                    && Objects.equals(oldItem.enableAudio, newItem.enableAudio);
        }

        @Nullable
        @Override
        public Object getChangePayload(@NonNull Member oldItem, @NonNull Member newItem) {
            // disable ViewHolder change
            return true;
        }
    }
}
