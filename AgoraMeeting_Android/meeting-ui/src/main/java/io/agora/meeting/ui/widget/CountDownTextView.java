package io.agora.meeting.ui.widget;

import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatTextView;

import java.util.Locale;

/**
 * Description:
 *
 *
 * @since 1/25/21
 */
public class CountDownTextView extends AppCompatTextView {

    private int leftSecond = 0;
    private String originText = "";

    private final Runnable countingRun = new Runnable() {
        @Override
        public void run() {
            if(TextUtils.isEmpty(originText)){
                originText = getText().toString();
            }
            if(leftSecond > 0 ){
                setText(String.format(Locale.US, "%s(%d)", originText, leftSecond));
                leftSecond --;
                postDelayed(this, 1000);
            }else{
                setText(originText);
                setEnabled(false);
            }
        }
    };

    public CountDownTextView(@NonNull Context context) {
        this(context, null);
    }

    public CountDownTextView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public CountDownTextView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        removeCallbacks(countingRun);
    }

    public void startCount(int second){
        if(second <= 0){
            return;
        }
        leftSecond = second;
        removeCallbacks(countingRun);
        post(countingRun);
    }

    public void stopCount(){
        removeCallbacks(countingRun);
        originText = null;
    }

}
