package io.agora.meeting.fragment;

import android.app.Dialog;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.graphics.Color;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;

import com.google.android.material.bottomsheet.BottomSheetDialogFragment;

import io.agora.base.ToastManager;
import io.agora.meeting.R;
import io.agora.meeting.databinding.FragmentInviteBinding;
import io.agora.meeting.viewmodel.MeetingViewModel;

public class InviteFragment extends BottomSheetDialogFragment {
    private FragmentInviteBinding binding;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        binding = FragmentInviteBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        binding.setViewModel(new ViewModelProvider(requireActivity()).get(MeetingViewModel.class));
        binding.setClickListener(v -> {
            switch (v.getId()) {
                case R.id.btn_copy:
                    ClipboardManager manager = (ClipboardManager) requireContext().getSystemService(Context.CLIPBOARD_SERVICE);
                    if (manager != null) {
                        String shareInfo = binding.tvRoomName.getText() +
                                "\n" + binding.tvPwd.getText() +
                                "\n" + binding.tvName.getText() +
                                "\n" + binding.tvWeb.getText() +
                                "\n" + binding.tvAndroid.getText() +
                                "\n" + binding.tvIos.getText();
                        manager.setPrimaryClip(ClipData.newPlainText(null, shareInfo));
                        ToastManager.showShort(getString(R.string.clipboard));
                    }
                    dismiss();
                    break;
                case R.id.btn_cancel:
                    dismiss();
                    break;
            }
        });
    }

    @NonNull
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        Dialog dialog = super.onCreateDialog(savedInstanceState);
        dialog.setOnShowListener(dialog1 -> {
            FrameLayout view = dialog.findViewById(R.id.design_bottom_sheet);
            view.setBackgroundColor(Color.TRANSPARENT);
            ViewGroup.LayoutParams layoutParams = view.getLayoutParams();
            layoutParams.width = binding.getRoot().getMeasuredWidth() - 100;
            layoutParams.height = ViewGroup.LayoutParams.WRAP_CONTENT;
            view.setLayoutParams(layoutParams);
        });
        return dialog;
    }
}
