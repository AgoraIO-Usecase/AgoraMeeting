package io.agora.meeting.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;

import androidx.constraintlayout.widget.ConstraintLayout;

import io.agora.meeting.databinding.LayoutMediaViewBinding;

public class MediaView extends ConstraintLayout {
    public LayoutMediaViewBinding binding;

    public MediaView(Context context) {
        this(context, null);
    }

    public MediaView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public MediaView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        binding = LayoutMediaViewBinding.inflate(LayoutInflater.from(context), this, true);
    }
}
