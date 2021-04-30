package io.agora.meeting.ui.adapter;

import android.text.TextUtils;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.appcompat.widget.AppCompatTextView;
import androidx.appcompat.widget.Toolbar;
import androidx.databinding.BindingAdapter;

public class BindingAdapters {

    @BindingAdapter(value = {
            "titleCenter",
            "title",
            "titleTextColor",
            "titleTextSize"
    })
    public static void bindToolbarTitle(View view, boolean isCenter, String title, int textColor, float textSize){
        if( !(view instanceof Toolbar)){
            return;
        }
        final String tag = "toolbar_center_title";
        TextView centerTitle = view.findViewWithTag(tag);
        final Toolbar toolbar = (Toolbar) view;
        if (toolbar.hasExpandedActionView()) {
            return;
        }
        if (isCenter) {
            if (centerTitle == null) {
                centerTitle = new AppCompatTextView(view.getContext());
                centerTitle.setLayoutParams(new Toolbar.LayoutParams(Gravity.CENTER));
                centerTitle.setTag(tag);
                final TextView _tv = centerTitle;
                toolbar.addOnLayoutChangeListener((v, left, top, right, bottom, oldLeft, oldTop, oldRight, oldBottom) -> {
                    CharSequence title1 = toolbar.getTitle();
                    if(!TextUtils.isEmpty(title1)){
                        _tv.setText(title1);
                        toolbar.setTitle("");
                    }
                });
                toolbar.addView(centerTitle);
            }
            centerTitle.setText(title);
            centerTitle.setTextColor(textColor);
            centerTitle.setTextSize(TypedValue.COMPLEX_UNIT_PX,textSize);
            toolbar.setTitle("");
        } else {
            if(centerTitle != null){
                toolbar.removeView(centerTitle);
            }
            toolbar.setTitle(title);
            toolbar.setTitleTextColor(textColor);
        }
    }

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

}
