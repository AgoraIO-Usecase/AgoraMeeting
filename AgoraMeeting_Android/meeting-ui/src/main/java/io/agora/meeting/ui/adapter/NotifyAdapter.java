package io.agora.meeting.ui.adapter;

import android.text.TextUtils;
import android.text.format.DateUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.DiffUtil;
import androidx.recyclerview.widget.ListAdapter;
import androidx.recyclerview.widget.RecyclerView;
import androidx.viewbinding.ViewBinding;

import io.agora.meeting.core.utils.TimeSyncUtil;
import io.agora.meeting.ui.R;
import io.agora.meeting.ui.annotation.ActionMsgShowType;
import io.agora.meeting.ui.data.ActionWrapMsg;
import io.agora.meeting.ui.databinding.AdapterNotifyApproveBinding;
import io.agora.meeting.ui.databinding.AdapterNotifyTextBinding;
import io.agora.meeting.ui.databinding.AdapterNotifyUrlBinding;
import io.agora.meeting.ui.util.ClipboardUtil;

import static android.text.format.DateUtils.FORMAT_SHOW_TIME;

/**
 * Description:
 *
 *
 * @since 2/1/21
 */
public class NotifyAdapter extends ListAdapter<ActionWrapMsg, NotifyAdapter.ViewHolder<?>> {

    public NotifyAdapter() {
        super(new DiffCallback());
    }

    @NonNull
    @Override
    public ViewHolder<?> onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        switch (viewType) {
            case ActionMsgShowType.ACTION:
                return new ViewHolder<AdapterNotifyApproveBinding>(AdapterNotifyApproveBinding.inflate(LayoutInflater.from(parent.getContext()), parent, false)) {
                    @Override
                    protected void bind(ActionWrapMsg notify) {
                        super.bind(notify);
                        binding.setNotify(notify);
                        binding.executePendingBindings();

                        long left = notify.actionCountDownEndTime - TimeSyncUtil.getSyncCurrentTimeMillis();

                        binding.cdTv.setVisibility(View.VISIBLE);
                        binding.cdTv.setText(notify.actionText);
                        binding.cdTv.setEnabled(notify.actionClick != null && (left > 0 || notify.actionCountDownEndTime <= 0));

                        binding.cdTv.setOnClickListener(v->{
                            binding.cdTv.stopCount();
                            binding.cdTv.setText(notify.actionText);
                            if (notify.actionClick != null) {
                                notify.actionClick.onClick(v);
                            }
                        });

                        if(left > 0){
                            binding.cdTv.startCount((int) (left / 1000));
                        }else{
                            binding.cdTv.stopCount();
                        }
                    }
                };
            case ActionMsgShowType.URL:
                return new ViewHolder<AdapterNotifyUrlBinding>(AdapterNotifyUrlBinding.inflate(LayoutInflater.from(parent.getContext()), parent, false)) {
                    @Override
                    protected void bind(ActionWrapMsg notify) {
                        super.bind(notify);
                        binding.setNotify(notify);
                        binding.executePendingBindings();
                        binding.tvCopyLink.setOnClickListener(v->{
                            ClipboardUtil.copy2Clipboard(v.getContext(), "");
                        });
                    }
                };
            default:
                // ActionMsgShowType.TEXT
                return new ViewHolder<AdapterNotifyTextBinding>(AdapterNotifyTextBinding.inflate(LayoutInflater.from(parent.getContext()), parent, false)) {
                    @Override
                    protected void bind(ActionWrapMsg notify) {
                        super.bind(notify);
                        binding.setNotify(notify);
                        binding.executePendingBindings();
                    }
                };
        }
    }

    @Override
    public int getItemViewType(int position) {
        return getItem(position).type;
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        holder.bind(getItem(position));
    }

    abstract class ViewHolder<T extends ViewBinding> extends RecyclerView.ViewHolder {
        protected T binding;

        public ViewHolder(T binding) {
            super(binding.getRoot());
            this.binding = binding;
        }

        protected void bind(ActionWrapMsg notify) {
            updateTimeView(notify);
        }

        private void updateTimeView(ActionWrapMsg notify) {
            if(notify.message == null){
                return;
            }
            setTimeVisible(notify.showTime, notify.message.timestamp);
        }

        protected void setTimeVisible(boolean visible, long timeMs) {
            TextView timeTv = binding.getRoot().findViewById(R.id.tv_time);
            if (timeTv != null) {
                timeTv.setVisibility(visible ? View.VISIBLE : View.GONE);
                if (visible) {
                    timeTv.setText(DateUtils.formatDateTime(binding.getRoot().getContext(), timeMs, FORMAT_SHOW_TIME));
                }
            }
        }
    }

    private static class DiffCallback extends DiffUtil.ItemCallback<ActionWrapMsg> {
        @Override
        public boolean areItemsTheSame(@NonNull ActionWrapMsg oldItem, @NonNull ActionWrapMsg newItem) {
            return oldItem == newItem;
        }

        @Override
        public boolean areContentsTheSame(@NonNull ActionWrapMsg oldItem, @NonNull ActionWrapMsg newItem) {
            return TextUtils.equals(oldItem.message.userId, newItem.message.userId)
                    && TextUtils.equals(oldItem.message.userName, newItem.message.userName)
                    && Boolean.compare(oldItem.showTime, newItem.showTime) == 0
                    && oldItem.message.type == newItem.message.type;
        }
    }

}
