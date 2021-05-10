package io.agora.meeting.ui.util;

import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.SimpleItemAnimator;

public class UIUtil {

    /**
     * 打开默认局部刷新动画
     */
    public static void openRVAnimator(RecyclerView recyclerView) {
        recyclerView.getItemAnimator().setAddDuration(120);
        recyclerView.getItemAnimator().setChangeDuration(250);
        recyclerView.getItemAnimator().setMoveDuration(250);
        recyclerView.getItemAnimator().setRemoveDuration(120);
        ((SimpleItemAnimator) recyclerView.getItemAnimator()).setSupportsChangeAnimations(true);
    }

    /**
     * 关闭默认局部刷新动画
     */
    public static void closeRVtAnimator(RecyclerView recyclerView) {
        recyclerView.getItemAnimator().setAddDuration(0);
        recyclerView.getItemAnimator().setChangeDuration(0);
        recyclerView.getItemAnimator().setMoveDuration(0);
        recyclerView.getItemAnimator().setRemoveDuration(0);
        ((SimpleItemAnimator) recyclerView.getItemAnimator()).setSupportsChangeAnimations(false);
    }
}
