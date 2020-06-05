package io.agora.meeting.fragment;

import android.app.Dialog;
import android.graphics.Color;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.IdRes;
import androidx.annotation.MenuRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.PopupMenu;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.bottomsheet.BottomSheetDialogFragment;

import java.util.List;
import java.util.Map;

import io.agora.meeting.R;
import io.agora.meeting.base.OnItemClickListener;
import io.agora.meeting.databinding.LayoutActionSheetBinding;
import io.agora.meeting.databinding.LayoutActionSheetListItemBinding;

public class ActionSheetFragment extends BottomSheetDialogFragment {
    private LayoutActionSheetBinding binding;
    private Menu menu;
    private Map<Integer, Integer> menuTitle;
    private List<Integer> menuIds;
    private ActionSheetAdapter adapter;
    private OnItemClickListener listener;

    public static ActionSheetFragment getInstance(@MenuRes int menuRes) {
        ActionSheetFragment fragment = new ActionSheetFragment();
        fragment.setArguments(new ActionSheetFragmentArgs.Builder(menuRes).build().toBundle());
        return fragment;
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        this.listener = listener;
    }

    public void resetMenuTitle(@NonNull Map<Integer, Integer> map) {
        menuTitle = map;
    }

    public void removeMenu(@NonNull List<Integer> list) {
        menuIds = list;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        ActionSheetFragmentArgs args = ActionSheetFragmentArgs.fromBundle(requireArguments());
        PopupMenu popupMenu = new PopupMenu(requireContext(), null);
        popupMenu.inflate(args.getMenuRes());
        menu = popupMenu.getMenu();

        if (menuIds != null) {
            for (int id : menuIds) {
                menu.removeItem(id);
            }
        }

        if (menuTitle != null) {
            for (Map.Entry<Integer, Integer> entry : menuTitle.entrySet()) {
                MenuItem menuItem = menu.findItem(entry.getKey());
                if (menuItem != null) {
                    menuItem.setTitle(entry.getValue());
                }
            }
        }

        if (menu.size() == 0) {
            dismiss();
        }
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        binding = LayoutActionSheetBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        binding.list.addItemDecoration(new DividerItemDecoration(requireContext(), DividerItemDecoration.VERTICAL));

        adapter = new ActionSheetAdapter();
        binding.list.setAdapter(adapter);

        binding.setClickListener(v -> dismiss());
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

    public MenuItem getItem(int position) {
        return menu.getItem(position);
    }

    public MenuItem findItem(@IdRes int idRes) {
        return menu.findItem(idRes);
    }

    private class ViewHolder extends RecyclerView.ViewHolder {
        private LayoutActionSheetListItemBinding binding;

        public ViewHolder(@NonNull LayoutActionSheetListItemBinding binding) {
            super(binding.getRoot());
            this.binding = binding;
            this.binding.setClickListener(v -> {
                if (listener != null) {
                    listener.onItemClick(v, getAdapterPosition(), getItemId());
                }
                dismiss();
            });
        }

        void bind(MenuItem item) {
            binding.setTitle(item.getTitle().toString());
        }
    }

    private class ActionSheetAdapter extends RecyclerView.Adapter<ViewHolder> {
        public ActionSheetAdapter() {
            setHasStableIds(true);
        }

        @NonNull
        @Override
        public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new ViewHolder(
                    LayoutActionSheetListItemBinding.inflate(
                            LayoutInflater.from(parent.getContext()),
                            parent, false
                    )
            );
        }

        @Override
        public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
            holder.bind(getItem(position));
        }

        public MenuItem getItem(int position) {
            return menu.getItem(position);
        }

        @Override
        public int getItemCount() {
            return menu.size();
        }

        @Override
        public long getItemId(int position) {
            return getItem(position).getItemId();
        }
    }
}
