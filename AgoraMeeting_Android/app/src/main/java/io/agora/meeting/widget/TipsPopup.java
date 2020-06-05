package io.agora.meeting.widget;

import android.content.Context;
import android.graphics.Rect;
import android.view.Gravity;
import android.view.View;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;

import io.agora.meeting.R;
import razerdp.basepopup.BasePopupWindow;

public class TipsPopup extends BasePopupWindow {
    private ImageView iv_arrow;

    public TipsPopup(Context context) {
        super(context);
    }

    public TipsPopup(Fragment fragment) {
        super(fragment);
    }

    @Override
    public View onCreateContentView() {
        View view = createPopupById(R.layout.layout_popup);
        iv_arrow = view.findViewById(R.id.iv_arrow);
        return view;
    }

    @Override
    public void onPopupLayout(@NonNull Rect popupRect, @NonNull Rect anchorRect) {
        int gravity = computeGravity(popupRect, anchorRect);
        boolean verticalCenter = false;
        switch (gravity & Gravity.VERTICAL_GRAVITY_MASK) {
            case Gravity.TOP:
                iv_arrow.setVisibility(View.VISIBLE);
                iv_arrow.setTranslationX((popupRect.width() - iv_arrow.getWidth()) >> 1);
                iv_arrow.setTranslationY(popupRect.height() - iv_arrow.getHeight());
                iv_arrow.setRotation(0f);
                break;
            case Gravity.BOTTOM:
                iv_arrow.setVisibility(View.VISIBLE);
                iv_arrow.setTranslationX((popupRect.width() - iv_arrow.getWidth()) >> 1);
                iv_arrow.setTranslationY(0);
                iv_arrow.setRotation(180f);
                break;
            case Gravity.CENTER_VERTICAL:
                verticalCenter = true;
                break;
        }
        switch (gravity & Gravity.HORIZONTAL_GRAVITY_MASK) {
            case Gravity.LEFT:
                iv_arrow.setVisibility(View.VISIBLE);
                iv_arrow.setX(popupRect.width() / 2 + anchorRect.centerX() - popupRect.centerX() - iv_arrow.getWidth());
//                iv_arrow.setTranslationX(anchorRect.centerX());
//                iv_arrow.setTranslationX(popupRect.width() - iv_arrow.getWidth());
//                iv_arrow.setTranslationY((popupRect.height() - iv_arrow.getHeight()) >> 1);
//                iv_arrow.setRotation(270f);
                break;
            case Gravity.RIGHT:
                iv_arrow.setVisibility(View.VISIBLE);
                iv_arrow.setTranslationX(0);
//                iv_arrow.setTranslationY((popupRect.height() - iv_arrow.getHeight()) >> 1);
//                iv_arrow.setRotation(90f);
                break;
            case Gravity.CENTER_HORIZONTAL:
                iv_arrow.setVisibility(verticalCenter ? View.INVISIBLE : View.VISIBLE);
                break;
        }
    }
}
