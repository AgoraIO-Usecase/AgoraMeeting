package io.agora.meeting.adapter;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.viewpager2.adapter.FragmentStateAdapter;

import io.agora.meeting.fragment.GridVideoFragment;
import io.agora.meeting.fragment.SimpleContainerFragment;

public class VideoFragmentAdapter extends FragmentStateAdapter {
    private static final int CONTAINER_COUNT = 2;
    private static final int GRID_COUNT = 4;

    private int itemCount;

    public VideoFragmentAdapter(@NonNull Fragment fragment) {
        super(fragment);
    }

    public void setItemCount(int count) {
        this.itemCount = count;
        this.notifyDataSetChanged();
    }

    @NonNull
    @Override
    public Fragment createFragment(int position) {
        if (position == 0) {
            return new SimpleContainerFragment();
        }

        int fromIndex = (position - 1) * GRID_COUNT + CONTAINER_COUNT;
        int toIndex = fromIndex + GRID_COUNT;
        return GridVideoFragment.getInstance(fromIndex, toIndex);
    }

    @Override
    public int getItemCount() {
        double count = itemCount - CONTAINER_COUNT;
        if (count < 0) count = 0;
        return (int) Math.ceil(count / GRID_COUNT) + 1;
    }
}
