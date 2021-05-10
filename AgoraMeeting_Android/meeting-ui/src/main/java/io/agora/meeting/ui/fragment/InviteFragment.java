package io.agora.meeting.ui.fragment;

import android.app.Dialog;
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

import io.agora.meeting.ui.R;
import io.agora.meeting.ui.databinding.FragmentInviteBinding;
import io.agora.meeting.ui.util.ClipboardUtil;
import io.agora.meeting.ui.util.ShareUtils;
import io.agora.meeting.ui.util.ToastUtil;
import io.agora.meeting.ui.viewmodel.RoomViewModel;

public class InviteFragment extends BottomSheetDialogFragment {
    private FragmentInviteBinding binding;

    public static void simpleCopy(Context context, RoomViewModel viewModel){
        ClipboardUtil.copy2Clipboard(context, ShareUtils.getMeetingShareInfo(context,
                viewModel.getRoomModel(),
                viewModel.getLocalUserViewModel().getUserModel()));
        ToastUtil.showShort(context.getResources().getString(R.string.invite_meeting_info_copy_success));
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        binding = FragmentInviteBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        RoomViewModel viewModel = new ViewModelProvider(requireActivity()).get(RoomViewModel.class);
        binding.setViewModel(viewModel);
        binding.setClickListener(v -> {
            if (v.getId() == R.id.btn_copy) {
                ClipboardUtil.copy2Clipboard(requireContext(), ShareUtils.getMeetingShareInfo(requireContext(),
                        viewModel.getRoomModel(),
                        viewModel.getLocalUserViewModel().getUserModel()));
                ToastUtil.showShort(getString(R.string.invite_clipboard));
                dismiss();
            } else {
                dismiss();
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
