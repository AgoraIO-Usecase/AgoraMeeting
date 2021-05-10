package io.agora.meeting.ui.adapter;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.RecyclerView;
import androidx.viewpager2.adapter.FragmentStateAdapter;

import java.util.ArrayList;
import java.util.List;

import io.agora.meeting.ui.annotation.Layout;
import io.agora.meeting.ui.data.RenderInfo;
import io.agora.meeting.ui.fragment.GridAudioFragment;
import io.agora.meeting.ui.fragment.GridVideoFragment;
import io.agora.meeting.ui.fragment.MeetingFragment;
import io.agora.meeting.ui.fragment.SpeakerVideoFragment;

public class VideoFragmentAdapter extends FragmentStateAdapter {

    private final List<RenderInfo> renders = new ArrayList<>();
    private final List<RenderInfo> data = new ArrayList<>();
    private volatile boolean dataDirty = false;
    private Handler mHandler;

    private final Runnable dataChangeRun = new Runnable() {
        @Override
        public void run() {
            long minDelay = 2000;
            long maxDelay = 8000;
            long delay = minDelay;
            if (dataDirty) {
                flushData();
                delay = Math.min(Math.max(minDelay, renders.size() * 100), maxDelay);
            }
            if (mHandler != null) {
                mHandler.postDelayed(this, delay);
            }
        }
    };


    public VideoFragmentAdapter(@NonNull MeetingFragment fragment) {
        super(fragment);
    }

    public void setListAsync(List<RenderInfo> renders) {
        synchronized (data) {
            boolean dataFirstInit = data.size() == 0;
            data.clear();
            data.addAll(renders);
            if (dataFirstInit) {
                setListSync(data);
            }else{
                dataDirty = true;
            }
        }
    }

    public void setListSync(List<RenderInfo> renders){
        this.renders.clear();
        this.renders.addAll(renders);
        notifyDataSetChanged();
    }

    public void flushData() {
        synchronized (data){
            dataDirty = false;
            renders.clear();
            renders.addAll(data);
            notifyDataSetChanged();
        }
    }

    @NonNull
    @Override
    public Fragment createFragment(int position) {
        int displayMode = getItemViewType(position);
        if (displayMode == Layout.TILED) {
            return GridVideoFragment.getInstance(position);
        } else if (displayMode == Layout.AUDIO) {
            return GridAudioFragment.getInstance(position);
        } else if (displayMode == Layout.SPEAKER) {
            return SpeakerVideoFragment.getInstance(position);
        }
        return null;
    }

    @Override
    public long getItemId(int position) {
        return renders.get(position).getItemId(position);
    }

    @Override
    public boolean containsItem(long itemId) {
        for (int i = 0; i < renders.size(); i++) {
            int _id = renders.get(i).getItemId(i);
            if(_id == itemId){
                return true;
            }
        }
        return false;
    }

    @Override
    public int getItemViewType(int position) {
        RenderInfo renderInfo = renders.get(position);
        return renderInfo.layout;
    }

    @Override
    public int getItemCount() {
        return renders.size();
    }


    @Override
    public void onAttachedToRecyclerView(@NonNull RecyclerView recyclerView) {
        super.onAttachedToRecyclerView(recyclerView);
        mHandler = new Handler(Looper.getMainLooper());
        mHandler.post(dataChangeRun);
    }

    @Override
    public void onDetachedFromRecyclerView(@NonNull RecyclerView recyclerView) {
        super.onDetachedFromRecyclerView(recyclerView);
        mHandler.removeCallbacks(dataChangeRun);
        mHandler = null;
    }
}
