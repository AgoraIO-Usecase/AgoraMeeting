package io.agora.meeting.adapter;

import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;

import androidx.databinding.BindingAdapter;

import io.agora.sdk.annotation.RenderMode;
import io.agora.sdk.manager.RtcManager;

public class BindingAdapters {
    @BindingAdapter("android:layout_alignParentEnd")
    public static void bindAlignParentEnd(View view, boolean alignParentEnd) {
        ViewGroup.LayoutParams layoutParams = view.getLayoutParams();

        if (layoutParams instanceof RelativeLayout.LayoutParams) {
            if (alignParentEnd) {
                ((RelativeLayout.LayoutParams) layoutParams).addRule(RelativeLayout.ALIGN_PARENT_END);
            } else {
                ((RelativeLayout.LayoutParams) layoutParams).removeRule(RelativeLayout.ALIGN_PARENT_END);
            }
            view.setLayoutParams(layoutParams);
        }
    }

    @BindingAdapter("isGone")
    public static void bindIsGone(View view, boolean isGone) {
        view.setVisibility(isGone ? View.GONE : View.VISIBLE);
    }

    @BindingAdapter("activated")
    public static void bindActivated(View view, boolean activated) {
        view.setActivated(activated);
    }

    @BindingAdapter({
            "video_enable",
            "video_uid",
            "video_overlay",
            "video_render_mode",
    })
    public static void bindVideo(View view, boolean enable, int uid, boolean overlay, @RenderMode int renderMode) {
        if (view instanceof ViewGroup) {
            if (enable) {
                SurfaceView surfaceView;
                // get child view from ViewGroup
                View child = ((ViewGroup) view).getChildAt(0);
                if (child instanceof SurfaceView) { // SurfaceView already exits
                    surfaceView = (SurfaceView) child;
                    Object tag = surfaceView.getTag();
                    if (tag instanceof Integer) {
                        if ((Integer) tag == uid) {
                            // return if the SurfaceView has bound this uid
                            return;
                        }
                    }
                } else { // SurfaceView not exits
                    // create new SurfaceView
                    surfaceView = RtcManager.instance().createRendererView(view.getContext());
                }

                surfaceView.setZOrderMediaOverlay(overlay);
                surfaceView.setTag(uid); // bind uid
                ((ViewGroup) view).removeAllViews();
                ((ViewGroup) view).addView(surfaceView, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);

                if (uid == 0) {
                    RtcManager.instance().setupLocalVideo(surfaceView, renderMode);
                } else {
                    RtcManager.instance().setupRemoteVideo(surfaceView, renderMode, uid);
                }
            } else {
                ((ViewGroup) view).removeAllViews();
            }
        }
    }
}
