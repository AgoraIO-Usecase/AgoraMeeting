package io.agora.meeting.ui.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.ListAdapter;
import androidx.recyclerview.widget.RecyclerView;

import io.agora.meeting.core.model.UserModel;
import io.agora.meeting.ui.R;
import io.agora.meeting.ui.databinding.LayoutMemberListItemBinding;
import io.agora.meeting.ui.util.AvatarUtil;

public class MemberListAdapter extends ListAdapter<UserModel, MemberListAdapter.ViewHolder> {
    private OnItemClickListener listener;

    public MemberListAdapter() {
        super(new UserDiffCallback());
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        this.listener = listener;
    }

    @NonNull
    @Override
    public MemberListAdapter.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new ViewHolder(parent,
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
    public UserModel getItem(int position) {
        return super.getItem(position);
    }


    class ViewHolder extends RecyclerView.ViewHolder {
        private View parent;
        public LayoutMemberListItemBinding binding;


        ViewHolder(View parent, LayoutMemberListItemBinding binding) {
            super(binding.getRoot());
            this.parent = parent;
            this.binding = binding;
            this.binding.setClickListener(v -> {
                if (listener != null) {
                    listener.onItemClick(v, getAdapterPosition(), getItemId());
                }
            });
        }

        void bind(UserModel member) {
            binding.setMember(member);
            binding.executePendingBindings();
            AvatarUtil.loadCircleAvatar(parent, binding.ivAvatar, member.getUserName());
            if(member.isHost() && member.isLocal()){
                binding.tvName.setText(binding.getRoot().getResources().getString(R.string.member_list_host_me, member.getUserName()));
            } else if(member.isHost()){
                binding.tvName.setText(binding.getRoot().getResources().getString(R.string.member_list_host, member.getUserName()));
            } else if (member.isLocal()) {
                binding.tvName.setText(binding.getRoot().getResources().getString(R.string.member_list_me, member.getUserName()));
            }
        }
    }


    public interface OnItemClickListener {
        void onItemClick(View v, int position, long viewId);
    }

}
