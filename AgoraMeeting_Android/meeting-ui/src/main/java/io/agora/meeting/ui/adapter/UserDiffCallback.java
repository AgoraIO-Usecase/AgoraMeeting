package io.agora.meeting.ui.adapter;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.DiffUtil;

import io.agora.meeting.core.model.UserModel;

/**
 * Description:
 *
 *
 * @since 1/21/21
 */
public class UserDiffCallback extends DiffUtil.ItemCallback<UserModel> {
    @Override
    public boolean areItemsTheSame(@NonNull UserModel oldItem, @NonNull UserModel newItem) {
        if(oldItem.isReleased()){
            return false;
        }
        return newItem.getClass() == oldItem.getClass() && newItem.getUserId().equals(oldItem.getUserId());
    }

    @Override
    public boolean areContentsTheSame(@NonNull UserModel oldItem, @NonNull UserModel newItem) {
        if(oldItem.getMainStreamModel() == null || newItem.getMainStreamModel() == null || oldItem.isReleased()){
            return false;
        }
        return Boolean.compare(oldItem.getMainStreamModel().hasVideo(), newItem.getMainStreamModel().hasVideo()) != 0
                || Boolean.compare(oldItem.getMainStreamModel().hasVideo(), newItem.getMainStreamModel().hasVideo()) != 0;
    }

    @Nullable
    @Override
    public Object getChangePayload(@NonNull UserModel oldItem, @NonNull UserModel newItem) {
        // disable ViewHolder change
        return true;
    }
}
