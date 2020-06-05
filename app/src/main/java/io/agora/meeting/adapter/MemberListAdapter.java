package io.agora.meeting.adapter;

import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.DiffUtil;
import androidx.recyclerview.widget.ListAdapter;
import androidx.recyclerview.widget.RecyclerView;

import java.util.Objects;

import io.agora.meeting.base.OnItemClickListener;
import io.agora.meeting.data.Member;
import io.agora.meeting.databinding.LayoutMemberListItemBinding;

public class MemberListAdapter extends ListAdapter<Member, MemberListAdapter.ViewHolder> {
    private OnItemClickListener listener;

    public MemberListAdapter() {
        super(new DiffCallback());
        setHasStableIds(true);
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        this.listener = listener;
    }

    @NonNull
    @Override
    public MemberListAdapter.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new ViewHolder(
                LayoutMemberListItemBinding.inflate(
                        LayoutInflater.from(parent.getContext())
                        , parent, false
                )
        );
    }

    @Override
    public void onBindViewHolder(@NonNull MemberListAdapter.ViewHolder holder, int position) {
        holder.bind(getItem(position));
    }

    @Override
    public Member getItem(int position) {
        return super.getItem(position);
    }

    @Override
    public long getItemId(int position) {
        return Long.parseLong(getItem(position).userId);
    }

    class ViewHolder extends RecyclerView.ViewHolder {
        public LayoutMemberListItemBinding binding;

        ViewHolder(LayoutMemberListItemBinding binding) {
            super(binding.getRoot());
            this.binding = binding;
            this.binding.setClickListener(v -> {
                if (listener != null) {
                    listener.onItemClick(v, getAdapterPosition(), getItemId());
                }
            });
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
                    && Objects.equals(oldItem.enableAudio, newItem.enableAudio)
                    && Objects.equals(oldItem.grantBoard, newItem.grantBoard)
                    && Objects.equals(oldItem.grantScreen, newItem.grantScreen);
        }
    }
}
