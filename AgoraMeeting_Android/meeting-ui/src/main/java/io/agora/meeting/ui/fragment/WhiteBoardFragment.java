package io.agora.meeting.ui.fragment;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.lifecycle.ViewModelProvider;

import io.agora.meeting.core.model.StreamModel;
import io.agora.meeting.ui.R;
import io.agora.meeting.ui.adapter.StreamBinding;
import io.agora.meeting.ui.base.BaseFragment;
import io.agora.meeting.ui.databinding.FragmentWhiteboardBinding;
import io.agora.meeting.ui.viewmodel.RoomViewModel;
import io.agora.meeting.ui.viewmodel.StreamViewModel;
import io.agora.meeting.ui.viewmodel.UserViewModel;

/**
 * Description:
 *
 *
 * @since 2/2/21
 */
public class WhiteBoardFragment extends BaseFragment<FragmentWhiteboardBinding> {
    private UserViewModel userVM;
    private UserViewModel localUserVM;
    private StreamViewModel streamVM;

    @Override
    protected FragmentWhiteboardBinding createBinding(@NonNull LayoutInflater inflater, @Nullable ViewGroup container) {
        return FragmentWhiteboardBinding.inflate(inflater, container, false);
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        WhiteBoardFragmentArgs args = WhiteBoardFragmentArgs.fromBundle(requireArguments());
        String userId = args.getUserId();
        String streamId = args.getStreamId();
        RoomViewModel roomVM = new ViewModelProvider(requireActivity()).get(RoomViewModel.class);
        localUserVM = roomVM.getLocalUserViewModel();
        userVM = roomVM.getUserViewModel(userId);
        streamVM = userVM.getStreamViewModel(streamId);
    }

    @Override
    public void onCreateOptionsMenu(@NonNull Menu menu, @NonNull MenuInflater inflater) {
        inflater.inflate(R.menu.fragment_whiteboard, menu);
        super.onCreateOptionsMenu(menu, inflater);
        resetMenu(streamVM.streamModel.getValue());
    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        if (item.getItemId() == R.id.menu_apply_board) {
            localUserVM.getUserModel().applyBoardInteract();
            return true;
        } else{
            localUserVM.getUserModel().cancelBoardInteract();
            return true;
        }
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        streamVM.streamModel.observe(getViewLifecycleOwner(), streamModel -> {
            binding.setStream(streamModel);
            binding.executePendingBindings();
            StreamBinding.bindStream(binding.boardContainer, streamModel, true, false, false, false, false);
            resetMenu(streamModel);
        });
        userVM.userModel.observe(getViewLifecycleOwner(), userModel -> {
            if (!userModel.isBoardOwner()) {
                getActivity().onBackPressed();
            }
        });
    }

    private void resetMenu(StreamModel streamModel) {
        setMenuVisible(R.id.menu_close_board, localUserVM.getUserModel().isBoardOwner());
        setMenuVisible(R.id.menu_apply_board, !streamModel.canBoardInteract());
        setMenuVisible(R.id.menu_quit_board, !localUserVM.getUserModel().isBoardOwner() && streamModel.canBoardInteract());
    }

    private void setMenuVisible(int id, boolean visible) {
        MenuItem item = binding.toolbar.getMenu().findItem(id);
        if (item != null) {
            item.setVisible(visible);
        }
    }

    @Override
    protected void init() {
        setupAppBar(binding.toolbar, false);
        setHasOptionsMenu(true);
        binding.toolbar.setNavigationOnClickListener(v -> {
            ((AppCompatActivity)requireActivity()).onSupportNavigateUp();
        });
    }
}
