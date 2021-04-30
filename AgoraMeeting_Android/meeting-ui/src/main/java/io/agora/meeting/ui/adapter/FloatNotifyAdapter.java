package io.agora.meeting.ui.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.DiffUtil;
import androidx.recyclerview.widget.ListAdapter;
import androidx.recyclerview.widget.RecyclerView;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import io.agora.meeting.core.log.Logger;
import io.agora.meeting.core.utils.TimeSyncUtil;
import io.agora.meeting.ui.adapter.FloatNotifyAdapter.FNViewHolder;
import io.agora.meeting.ui.annotation.ActionMsgShowType;
import io.agora.meeting.ui.data.ActionWrapMsg;
import io.agora.meeting.ui.databinding.LayoutFloatNotifyBinding;

/**
 * Description:
 *
 *
 * @since 1/25/21
 */
public class FloatNotifyAdapter extends ListAdapter<ActionWrapMsg, FNViewHolder> {
    private static final int MAX_SHOW_NUM = 3;
    private static final int ITEM_STAY_DURATION = 10 * 1000;

    private final List<ActionWrapMsg> mList = new ArrayList<>();

    public FloatNotifyAdapter(){
        super(new DiffCallback());
    }

    @NonNull
    @Override
    public FNViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new FNViewHolder(LayoutFloatNotifyBinding.inflate(LayoutInflater.from(parent.getContext())));
    }

    @Override
    public void onBindViewHolder(@NonNull FNViewHolder holder, int position) {
        ActionWrapMsg notify = getItem(position);
        holder.bind(notify);
        holder.postDelay(() -> removeItem(notify), ITEM_STAY_DURATION);
    }

    public void addItem(ActionWrapMsg notify) {
        if(!mList.contains(notify)){
            mList.add(notify);
        }
        Iterator<ActionWrapMsg> iterator = mList.iterator();
        while (mList.size() > MAX_SHOW_NUM){
            iterator.next();
            iterator.remove();
        }
        submitList(new ArrayList<>(mList));
    }

    private void removeItem(ActionWrapMsg remove){
        if(remove != null){
            remove.hasRead = true;
            int index = mList.indexOf(remove);
            if(index >= 0){
                mList.remove(index);
                submitList(new ArrayList<>(mList));
            }
        }
    }

    static class FNViewHolder extends RecyclerView.ViewHolder {
        LayoutFloatNotifyBinding binding;

        private FNViewHolder(@NonNull LayoutFloatNotifyBinding binding) {
            super(binding.getRoot());
            this.binding = binding;
            this.binding.getRoot().addOnAttachStateChangeListener(new View.OnAttachStateChangeListener() {
                @Override
                public void onViewAttachedToWindow(View v) {

                }

                @Override
                public void onViewDetachedFromWindow(View v) {
                    Logger.d("FloatNotifyAdapter >> onViewDetachedFromWindow");
                    binding.getRoot().removeCallbacks((Runnable) binding.getRoot().getTag());
                }
            });
        }

        private void bind(ActionWrapMsg notify){
            binding.getRoot().setAlpha(1.0f);

            binding.getRoot().setVisibility(View.VISIBLE);
            binding.tvContent.setText(notify.content);

            if (notify.type == ActionMsgShowType.ACTION) {
                long left = notify.actionCountDownEndTime - TimeSyncUtil.getSyncCurrentTimeMillis();

                binding.btnAny.setVisibility(View.VISIBLE);
                binding.btnAny.setText(notify.actionText);
                binding.btnAny.setEnabled(notify.actionClick != null && (left > 0 || notify.actionCountDownEndTime <= 0));
                binding.btnAny.setOnClickListener(v -> {
                    binding.btnAny.stopCount();
                    binding.btnAny.setText(notify.actionText);
                    if (notify.actionClick != null) {
                        notify.actionClick.onClick(v);
                    }
                });

                if(left > 0){
                    binding.btnAny.startCount((int) (left / 1000));
                }else{
                    binding.btnAny.stopCount();
                }
            } else {
                binding.btnAny.stopCount();
                binding.btnAny.setVisibility(View.GONE);
            }
        }

        public void postDelay(Runnable runnable, long delay){
            binding.getRoot().removeCallbacks((Runnable) binding.getRoot().getTag());
            binding.getRoot().postDelayed(runnable, delay);
            binding.getRoot().setTag(runnable);
        }
    }

    private static class DiffCallback extends DiffUtil.ItemCallback<ActionWrapMsg> {
        @Override
        public boolean areItemsTheSame(@NonNull ActionWrapMsg oldItem, @NonNull ActionWrapMsg newItem) {
            return oldItem == newItem;
        }

        @Override
        public boolean areContentsTheSame(@NonNull ActionWrapMsg oldItem, @NonNull ActionWrapMsg newItem) {
            return oldItem.message != null && newItem.message != null
                    && oldItem.message.equals(newItem.message)
                    && oldItem.type == newItem.type;
        }
    }
}
