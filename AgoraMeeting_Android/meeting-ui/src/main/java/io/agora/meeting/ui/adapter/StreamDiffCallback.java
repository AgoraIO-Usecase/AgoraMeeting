package io.agora.meeting.ui.adapter;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.DiffUtil;

import io.agora.meeting.core.model.StreamModel;
import io.agora.meeting.ui.viewmodel.StreamsVideoModel;

/**
 * Description:
 *
 *
 * @since 1/21/21
 */
public class StreamDiffCallback extends DiffUtil.ItemCallback<StreamModel> {
    @Override
    public boolean areItemsTheSame(@NonNull StreamModel oldItem, @NonNull StreamModel newItem) {
        if(oldItem.isReleased()){
            return false;
        }
        return newItem.getClass() == oldItem.getClass() && newItem.getStreamId().equals(oldItem.getStreamId());
    }

    @Override
    public boolean areContentsTheSame(@NonNull StreamModel oldItem, @NonNull StreamModel newItem) {
        if(oldItem.isReleased()){
            return false;
        }
        return Boolean.compare(oldItem.hasAudio(), newItem.hasAudio()) != 0
                || Boolean.compare(oldItem.hasVideo(), newItem.hasVideo()) != 0
                || Boolean.compare(StreamsVideoModel.getMeIsHost(oldItem), StreamsVideoModel.getMeIsHost(newItem)) != 0
                || Boolean.compare(StreamBinding.isVisibleToUser(oldItem), StreamBinding.isVisibleToUser(newItem)) != 0;
    }

    @Nullable
    @Override
    public Object getChangePayload(@NonNull StreamModel oldItem, @NonNull StreamModel newItem) {
        // disable ViewHolder change
        return true;
    }
}
