package io.agora.meeting.ui.widget;

import android.content.Context;
import android.content.ContextWrapper;
import android.content.res.TypedArray;
import android.graphics.drawable.Drawable;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageButton;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.databinding.BindingAdapter;
import androidx.databinding.InverseBindingAdapter;
import androidx.databinding.InverseBindingListener;
import androidx.databinding.adapters.ListenerUtil;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

import io.agora.meeting.ui.R;
import io.agora.meeting.ui.util.StringUtil;
import io.agora.meeting.ui.util.ToastUtil;

/**
 * author: xcz
 * since:  1/18/21
 **/
public class AutoEditText extends FrameLayout {

    private EditText mEt;
    private ImageButton mBtnClose;
    private ImageButton mBtnIcon;

    private String mText;
    private String mHint;
    private int mInputType;
    private int mMaxLength;
    private int mMinLength;
    private String mTipOver;
    private String mTipShort;
    private String mTipEmpty;
    private Drawable mRightIconRes;
    private String mRightIconClickName;
    private boolean mBanEmoji;

    public AutoEditText(@NonNull Context context) {
        this(context, null);
    }

    public AutoEditText(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public AutoEditText(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initParams(context, attrs, defStyleAttr);
        initView();
    }

    private void initParams(Context context, AttributeSet attrs, int defStyleAttr) {
        final TypedArray a = context.obtainStyledAttributes(
                attrs, R.styleable.AutoEditText, defStyleAttr, defStyleAttr);

        mText = a.getString(R.styleable.AutoEditText_android_text);
        mHint = a.getString(R.styleable.AutoEditText_android_hint);
        mInputType = a.getInt(R.styleable.AutoEditText_android_inputType, EditorInfo.TYPE_NULL);
        mMaxLength = a.getInteger(R.styleable.AutoEditText_maxLength, 999);
        mMinLength = a.getInteger(R.styleable.AutoEditText_minLength, 0);
        mTipOver = a.getString(R.styleable.AutoEditText_tipOver);
        mTipShort = a.getString(R.styleable.AutoEditText_tipShort);
        mTipEmpty = a.getString(R.styleable.AutoEditText_tipEmpty);
        mRightIconRes = a.getDrawable(R.styleable.AutoEditText_rightIconSrc);
        mRightIconClickName = a.getString(R.styleable.AutoEditText_rightIconClick);
        mBanEmoji = a.getBoolean(R.styleable.AutoEditText_banEmoji, false);
        a.recycle();
    }

    private void initView() {
        LayoutInflater.from(getContext()).inflate(R.layout.widget_auto_edittext, this);
        mEt = findViewById(android.R.id.edit);
        mBtnClose = findViewById(R.id.btn_close);
        mBtnIcon = findViewById(R.id.btn_icon);

        // 输入框初始化
        mEt.setText(mText);
        mEt.setHint(mHint);
        mEt.setInputType(mInputType);
        StringUtil.filterEtLength(mEt, mMaxLength, () -> {
            // 超过字数限制
            if (!TextUtils.isEmpty(mTipOver)) {
                ToastUtil.showShort(mTipOver);
            }
        });
        if (mBanEmoji) {
            StringUtil.filterEtEmoji(mEt);
        }
        mEt.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                mBtnClose.setVisibility(TextUtils.isEmpty(s.toString()) ? View.GONE : View.VISIBLE);
            }
        });

        // 删除按钮
        mBtnClose.setVisibility(TextUtils.isEmpty(mEt.getText().toString()) ? View.GONE : View.VISIBLE);
        mBtnClose.setOnClickListener(v -> {
            mEt.setText("");
        });

        // 右图标
        if (mRightIconRes != null) {
            mBtnIcon.setVisibility(View.VISIBLE);
            mBtnIcon.setImageDrawable(mRightIconRes);
            if (!TextUtils.isEmpty(mRightIconClickName)) {
                mBtnIcon.setOnClickListener(new DeclaredOnClickListener(this, mRightIconClickName));
            }
        }
    }

    public void setText(CharSequence text) {
        mEt.setText(text);
        if(!TextUtils.isEmpty(text)){
            mEt.setSelection(text.length());
        }
    }

    public String getText() {
        return mEt.getText().toString();
    }

    public void setRightIconClickListener(View.OnClickListener clickListener) {
        mBtnIcon.setOnClickListener(clickListener);
    }

    /**
     * 校验数据
     */
    public boolean check() {
        String str = mEt.getText().toString();
        if (TextUtils.isEmpty(str)) {
            ToastUtil.showShort(mTipEmpty);
            return false;
        }
        if (str.length() < mMinLength) {
            ToastUtil.showShort(mTipShort);
            return false;
        }
        return true;
    }


    @BindingAdapter("android:text")
    public static void _setText(AutoEditText view, String text) {
        final CharSequence oldText = view.getText();
        if (!StringUtil.haveContentsChanged(text, oldText)) {
            return; // No content changes, so don't set anything.
        }
        view.mEt.setText(text);
    }

    @InverseBindingAdapter(attribute = "android:text", event = "android:textAttrChanged")
    public static String _getText(AutoEditText view) {
        return view.getText();
    }

    @BindingAdapter("android:textAttrChanged")
    public static void _setTextListener(AutoEditText view, final InverseBindingListener textAttrChanged) {
        TextWatcher newValue = new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (textAttrChanged != null) {
                    textAttrChanged.onChange();
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        };
        TextWatcher oldValue = ListenerUtil.trackListener(view, newValue, R.id.textWatcher);
        if (oldValue != null) {
            view.mEt.removeTextChangedListener(oldValue);
        }
        view.mEt.addTextChangedListener(newValue);
    }

    @BindingAdapter("rightIconClick")
    public static void _setRightIconClickListener(AutoEditText view, View.OnClickListener onClickListener) {
        if (view != null) {
            view.mBtnIcon.setOnClickListener(onClickListener);
        }
    }


    /**
     * An implementation of OnClickListener that attempts to lazily load a
     * named click handling method from a parent or ancestor context.
     */
    private static class DeclaredOnClickListener implements OnClickListener {
        private final View mHostView;
        private final String mMethodName;

        private Method mResolvedMethod;
        private Context mResolvedContext;

        public DeclaredOnClickListener(View hostView, String methodName) {
            mHostView = hostView;
            mMethodName = methodName;
        }

        @Override
        public void onClick(View v) {
            if (mResolvedMethod == null) {
                resolveMethod(mHostView.getContext(), mMethodName);
            }

            try {
                mResolvedMethod.invoke(mResolvedContext, v);
            } catch (IllegalAccessException e) {
                throw new IllegalStateException(
                        "Could not execute non-public method for android:onClick", e);
            } catch (InvocationTargetException e) {
                throw new IllegalStateException(
                        "Could not execute method for android:onClick", e);
            }
        }

        private void resolveMethod(Context context, String name) {
            while (context != null) {
                try {
                    if (!context.isRestricted()) {
                        final Method method = context.getClass().getMethod(mMethodName, View.class);
                        if (method != null) {
                            mResolvedMethod = method;
                            mResolvedContext = context;
                            return;
                        }
                    }
                } catch (NoSuchMethodException e) {
                    // Failed to find method, keep searching up the hierarchy.
                }

                if (context instanceof ContextWrapper) {
                    context = ((ContextWrapper) context).getBaseContext();
                } else {
                    // Can't search up the hierarchy, null out and fail.
                    context = null;
                }
            }

            final int id = mHostView.getId();
            final String idText = id == NO_ID ? "" : " with id '"
                    + mHostView.getContext().getResources().getResourceEntryName(id) + "'";
            throw new IllegalStateException("Could not find method " + mMethodName
                    + "(View) in a parent or ancestor Context for android:onClick "
                    + "attribute defined on view " + mHostView.getClass() + idText);
        }
    }

}
