package io.agora.meeting.ui.fragment;

import android.graphics.Rect;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.SearchView;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.RecyclerView;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.agora.meeting.core.model.StreamModel;
import io.agora.meeting.core.model.UserModel;
import io.agora.meeting.ui.R;
import io.agora.meeting.ui.adapter.MemberListAdapter;
import io.agora.meeting.ui.base.BaseFragment;
import io.agora.meeting.ui.databinding.FragmentMemberListBinding;
import io.agora.meeting.ui.util.UserOptionsUtil;
import io.agora.meeting.ui.viewmodel.RoomViewModel;
import io.agora.meeting.ui.viewmodel.UserViewModel;
import io.agora.meeting.ui.viewmodel.UsersViewModel;

import static android.app.Activity.DEFAULT_KEYS_SEARCH_LOCAL;

public class MemberListFragment extends BaseFragment<FragmentMemberListBinding> implements MemberListAdapter.OnItemClickListener {
    private RoomViewModel roomVM;
    private UsersViewModel usersVM;
    private UserViewModel localUserVM;

    private MemberListAdapter adapter;


    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requireActivity().setDefaultKeyMode(DEFAULT_KEYS_SEARCH_LOCAL);
        roomVM = new ViewModelProvider(requireActivity()).get(RoomViewModel.class);
        usersVM = roomVM.getUsersViewModel();
        localUserVM = roomVM.getLocalUserViewModel();
    }

    @Override
    protected FragmentMemberListBinding createBinding(@NonNull LayoutInflater inflater, @Nullable ViewGroup container) {
        return FragmentMemberListBinding.inflate(inflater, container, false);
    }

    @Override
    protected void init() {
        setupAppBar(binding.toolbar, false);
        setHasOptionsMenu(true);
        binding.list.addItemDecoration(new RecyclerView.ItemDecoration() {
            @Override
            public void getItemOffsets(@NonNull Rect outRect, @NonNull View view,
                                       @NonNull RecyclerView parent,
                                       @NonNull RecyclerView.State state) {
                ViewGroup.LayoutParams layoutParams = view.getLayoutParams();
                layoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT;
                view.setLayoutParams(layoutParams);
                super.getItemOffsets(outRect, view, parent, state);
            }
        });
        DividerItemDecoration dividerItemDecoration = new DividerItemDecoration(requireContext(), DividerItemDecoration.VERTICAL);
        dividerItemDecoration.setDrawable(getResources().getDrawable(R.drawable.ic_divider));
        binding.list.addItemDecoration(dividerItemDecoration);
        adapter = new MemberListAdapter();
        adapter.setOnItemClickListener(this);
        binding.list.setAdapter(adapter);
        binding.refreshLayout.setOnRefreshListener(() -> {
            List<UserModel> members = usersVM.userModels.getValue();
            if (members != null) {
                adapter.submitList(members);
                binding.setMemberNum(members.size());
            }
            binding.refreshLayout.setRefreshing(false);
        });
    }


    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        usersVM.userModels.observe(getViewLifecycleOwner(), members -> {
            binding.setMemberNum(members.size());
            adapter.submitList(members);
        });
    }


    @Override
    public void onCreateOptionsMenu(@NonNull Menu menu, @NonNull MenuInflater inflater) {
        inflater.inflate(R.menu.fragment_member_list, menu);
        initSearchMenu(menu);
        super.onCreateOptionsMenu(menu, inflater);
    }

    private void initSearchMenu(@NonNull Menu menu) {
        MenuItem item = menu.findItem(R.id.action_search_kl);
        SearchView searchView = (SearchView) item.getActionView();
        searchView.setQueryHint(getString(R.string.member_list_search_hint));
        searchView.setOnCloseListener(() -> {
            usersVM.setQuery(null, true);
            return true;
        });
        searchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String query) {
                return false;
            }

            @Override
            public boolean onQueryTextChange(String newText) {
                usersVM.setQuery(newText, true);
                return true;
            }
        });
    }


    @Override
    public void onItemClick(View view, int position, long id) {
        UserModel member = adapter.getItem(position);
        showActionSheet(view, member);
    }

    private void showActionSheet(View view, UserModel userModel) {
        StreamModel streamModel = userModel.getMainStreamModel();
        UserOptionsUtil.getUsersOptionIdsAsync(roomVM.getRoomModel(), localUserVM.getUserModel(), userModel, streamModel, new UserOptionsUtil.OnOptionIdsGetListener() {
            @Override
            public void runInBackground(List<Integer> optionIds) {
                if (optionIds.size() == 0) {
                    return;
                }
                Map<Integer, Integer> menuMap = new HashMap<>();
                menuMap.put(R.id.menu_mic, R.string.more_mute_audio);
                menuMap.put(R.id.menu_video, R.string.more_close_video);
                menuMap.put(R.id.menu_renounce_host, R.string.more_renounce_admin);
                menuMap.put(R.id.menu_become_host, R.string.more_become_admin);
                menuMap.put(R.id.menu_set_host, R.string.more_set_host);
                menuMap.put(R.id.menu_move_out, R.string.more_move_out);

                List<Integer> removeMenuIds = new ArrayList<>();
                for (Map.Entry<Integer, Integer> entry : menuMap.entrySet()) {
                    if (!optionIds.contains(entry.getValue())) {
                        removeMenuIds.add(entry.getKey());
                    }
                }

                view.post(() -> {
                    ActionSheetFragment actionSheet = ActionSheetFragment.getInstance(userModel.getUserName(), userModel.getUserId(), R.menu.member_control);
                    actionSheet.removeMenu(removeMenuIds);
                    actionSheet.setOnItemClickListener((view1, position, id) -> {
                        UserOptionsUtil.handleOnClickEvent(menuMap.get((int) id), localUserVM.getUserModel(), userModel, streamModel);
                    });
                    actionSheet.show(getChildFragmentManager(), null);
                });
            }
        });
    }
}
