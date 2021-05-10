package io.agora.meeting.ui.base;

import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;
import androidx.databinding.ViewDataBinding;
import androidx.fragment.app.Fragment;
import androidx.viewbinding.ViewBinding;

import com.bumptech.glide.Glide;

import io.agora.meeting.core.log.Logger;
import io.agora.meeting.ui.MeetingActivity;

public abstract class BaseFragment<Binding extends ViewBinding> extends Fragment implements AppBarDelegate {
    protected final String TAG = this.getClass().getSimpleName();

    protected Binding binding;
    private volatile boolean isSelected = false;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        // Inflate view and obtain an instance of the binding class.
        binding = createBinding(inflater, container);
        if (binding instanceof ViewDataBinding) {
            // Specify the current activity as the lifecycle owner.
            ((ViewDataBinding) binding).setLifecycleOwner(getViewLifecycleOwner());
        }
        return binding.getRoot();
    }

    @Override
    public void setMenuVisibility(boolean menuVisible) {
        super.setMenuVisibility(menuVisible);
        if(Boolean.compare(menuVisible, isSelected) != 0){
            isSelected = menuVisible;
            onSelectedChanged(isSelected);
        }
    }

    public boolean isSelected() {
        return isSelected;
    }

    protected abstract Binding createBinding(@NonNull LayoutInflater inflater, @Nullable ViewGroup container);

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        getView().addOnAttachStateChangeListener(new View.OnAttachStateChangeListener() {
            @Override
            public void onViewAttachedToWindow(View v) {
                onUserVisibleChanged(true);
            }

            @Override
            public void onViewDetachedFromWindow(View v) {
                onUserVisibleChanged(false);
            }
        });
        init();
    }

    protected abstract void init();

    @Override
    public void onDestroyView() {
        try {
            Glide.with(this).onDestroy();
        } catch (Exception e) {
            Logger.i(e.toString());
        }
        super.onDestroyView();
        binding = null;
    }

    @Override
    public void setupAppBar(@NonNull Toolbar toolbar, boolean isLight) {
        Context context = requireContext();
        if (context instanceof AppBarDelegate) {
            ((AppBarDelegate) context).setupAppBar(toolbar, isLight);
        }
    }

    protected void showLoadingDialog(){
        if(requireActivity() instanceof MeetingActivity){
            ((MeetingActivity) requireActivity()).showLoadingDialog();
        }
    }

    protected void dismissLoadingDialog(){
        if(requireActivity() instanceof MeetingActivity){
            ((MeetingActivity) requireActivity()).dismissLoadingDialog();
        }
    }

    protected void onUserVisibleChanged(boolean visible) {

    }

    protected void onSelectedChanged(boolean selected){

    }

}
