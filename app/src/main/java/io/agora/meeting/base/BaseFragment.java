package io.agora.meeting.base;

import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;
import androidx.databinding.ViewDataBinding;
import androidx.fragment.app.Fragment;
import androidx.viewbinding.ViewBinding;

import io.agora.meeting.MainActivity;
import io.agora.meeting.R;

public abstract class BaseFragment<Binding extends ViewBinding> extends Fragment implements AppBarDelegate {
    protected Binding binding;

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

    protected abstract Binding createBinding(@NonNull LayoutInflater inflater, @Nullable ViewGroup container);

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        setupActionBar(this);
        init();
    }

    protected abstract void init();

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        hideKeyBoard();
        binding = null;
    }

    private void hideKeyBoard() {
        InputMethodManager manager = (InputMethodManager) requireContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        if (manager != null) {
            manager.hideSoftInputFromWindow(binding.getRoot().getWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);
        }
    }

    public static void setupActionBar(Fragment fragment) {
        if (fragment instanceof AppBarDelegate) {
            AppBarDelegate actionBarFragment = (AppBarDelegate) fragment;
            Toolbar toolbar = actionBarFragment.getToolbar();
            if (toolbar != null) {
                Context context = fragment.requireContext();
                if (context instanceof MainActivity) {
                    ((MainActivity) context).setupAppBar(toolbar, actionBarFragment.lightMode());
                }
            }
        }
    }

    @Override
    public Toolbar getToolbar() {
        return requireView().findViewById(R.id.toolbar);
    }

    @Override
    public boolean lightMode() {
        return false;
    }
}
