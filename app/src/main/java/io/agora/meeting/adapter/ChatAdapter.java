package io.agora.meeting.adapter;

import android.text.TextUtils;
import android.text.format.DateUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.DiffUtil;
import androidx.recyclerview.widget.ListAdapter;
import androidx.recyclerview.widget.RecyclerView;

import io.agora.meeting.data.BroadcastMsg;
import io.agora.meeting.databinding.LayoutChatItemBinding;

import static android.text.format.DateUtils.FORMAT_SHOW_TIME;

public class ChatAdapter extends ListAdapter<BroadcastMsg.Chat, ChatAdapter.ViewHolder> {
    private BroadcastMsg.Chat lastMsg;

    public ChatAdapter() {
        super(new DiffCallback());
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
        BroadcastMsg.Chat message = getItem(position);
        holder.bind(message);

        if (position == 0) {
            holder.binding.tvTime.setVisibility(View.VISIBLE);
            holder.binding.tvTime.setText(DateUtils.formatDateTime(holder.binding.getRoot().getContext(), message.timestamp, FORMAT_SHOW_TIME));
            lastMsg = message;
        } else {
            if (lastMsg != null) {
                if (message.timestamp - lastMsg.timestamp >= 60 * 1000 * 2) {
                    holder.binding.tvTime.setVisibility(View.VISIBLE);
                    holder.binding.tvTime.setText(DateUtils.formatDateTime(holder.binding.getRoot().getContext(), message.timestamp, FORMAT_SHOW_TIME));
                    lastMsg = message;
                    return;
                }
            }
            holder.binding.tvTime.setVisibility(View.GONE);
        }
    }

    static class ViewHolder extends RecyclerView.ViewHolder {
        public LayoutChatItemBinding binding;

        ViewHolder(LayoutChatItemBinding binding) {
            super(binding.getRoot());
            this.binding = binding;
        }

        void bind(BroadcastMsg.Chat message) {
            binding.setMessage(message);
            binding.executePendingBindings();
        }
    }

    private static class DiffCallback extends DiffUtil.ItemCallback<BroadcastMsg.Chat> {
        @Override
        public boolean areItemsTheSame(@NonNull BroadcastMsg.Chat oldItem, @NonNull BroadcastMsg.Chat newItem) {
            return oldItem == newItem;
        }

        @Override
        public boolean areContentsTheSame(@NonNull BroadcastMsg.Chat oldItem, @NonNull BroadcastMsg.Chat newItem) {
            return TextUtils.equals(oldItem.data.userId, newItem.data.userId)
                    && TextUtils.equals(oldItem.data.userName, newItem.data.userName)
                    && TextUtils.equals(oldItem.data.message, newItem.data.message)
                    && oldItem.data.type == newItem.data.type;
        }
    }
}
