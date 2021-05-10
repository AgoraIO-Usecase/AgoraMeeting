package io.agora.meeting.ui.adapter;

import android.text.format.DateUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.DiffUtil;
import androidx.recyclerview.widget.ListAdapter;
import androidx.recyclerview.widget.RecyclerView;

import io.agora.meeting.ui.data.ChatWrapMsg;
import io.agora.meeting.ui.databinding.LayoutChatItemBinding;

import static android.text.format.DateUtils.FORMAT_SHOW_TIME;

public class ChatAdapter extends ListAdapter<ChatWrapMsg, ChatAdapter.ViewHolder> {
    private OnItemClickListener onItemClickListener;

    public ChatAdapter() {
        super(new DiffCallback());
    }

    public void setOnItemClickListener(OnItemClickListener onItemClickListener) {
        this.onItemClickListener = onItemClickListener;
    }

    @NonNull
    @Override
    public ChatAdapter.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new ViewHolder(
                LayoutChatItemBinding.inflate(
                        LayoutInflater.from(parent.getContext())
                        , parent, false
                )
        );
    }

    @Override
    public void onBindViewHolder(@NonNull ChatAdapter.ViewHolder holder, int position) {
        ChatWrapMsg message = getItem(position);
        holder.bind(message, position);

        if (message.showTime) {
            holder.binding.tvTime.setVisibility(View.VISIBLE);
            holder.binding.tvTime.setText(DateUtils.formatDateTime(holder.binding.getRoot().getContext(), message.message.timestamp, FORMAT_SHOW_TIME));
        }else{
            holder.binding.tvTime.setVisibility(View.GONE);
        }
    }

    class ViewHolder extends RecyclerView.ViewHolder {
        public LayoutChatItemBinding binding;

        ViewHolder(LayoutChatItemBinding binding) {
            super(binding.getRoot());
            this.binding = binding;
        }

        void bind(ChatWrapMsg message, int position) {
            binding.setMessage(message);
            binding.executePendingBindings();
            binding.ivFailed.setOnClickListener(v -> {
                if(onItemClickListener != null){
                    onItemClickListener.onRetryClick(position, message.message.content);
                }
            });
        }
    }

    private static class DiffCallback extends DiffUtil.ItemCallback<ChatWrapMsg> {
        @Override
        public boolean areItemsTheSame(@NonNull ChatWrapMsg oldItem, @NonNull ChatWrapMsg newItem) {
            return oldItem.message.timestamp == newItem.message.timestamp;
        }

        @Override
        public boolean areContentsTheSame(@NonNull ChatWrapMsg oldItem, @NonNull ChatWrapMsg newItem) {
            return Boolean.compare(oldItem.isFromMyself, newItem.isFromMyself) == 0
                    && Boolean.compare(oldItem.showTime, newItem.showTime) == 0
                    && oldItem.state == newItem.state;
        }
    }

    public interface OnItemClickListener{
        void onRetryClick(int index, String content);
    }
}
