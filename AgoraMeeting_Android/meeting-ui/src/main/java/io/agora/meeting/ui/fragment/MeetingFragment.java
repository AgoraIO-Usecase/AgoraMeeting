package io.agora.meeting.ui.fragment;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.FrameLayout;

import androidx.activity.OnBackPressedCallback;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.viewpager2.widget.ViewPager2;

import com.google.android.material.bottomnavigation.BottomNavigationItemView;
import com.google.android.material.tabs.TabLayoutMediator;
import com.yanzhenjie.permission.AndPermission;
import com.yanzhenjie.permission.runtime.Permission;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Locale;

import io.agora.meeting.core.annotaion.ActionMsgType;
import io.agora.meeting.core.annotaion.ApproveAction;
import io.agora.meeting.core.annotaion.ApproveRequest;
import io.agora.meeting.core.annotaion.AudioRoute;
import io.agora.meeting.core.annotaion.Device;
import io.agora.meeting.core.bean.ActionMessage;
import io.agora.meeting.core.bean.RoomProperties;
import io.agora.meeting.core.log.Logger;
import io.agora.meeting.core.model.RoomModel;
import io.agora.meeting.core.model.UserModel;
import io.agora.meeting.ui.MeetingActivity;
import io.agora.meeting.ui.R;
import io.agora.meeting.ui.adapter.FloatNotifyAdapter;
import io.agora.meeting.ui.adapter.VideoFragmentAdapter;
import io.agora.meeting.ui.annotation.Layout;
import io.agora.meeting.ui.base.BaseFragment;
import io.agora.meeting.ui.data.ActionWrapMsg;
import io.agora.meeting.ui.data.PreferenceLiveData;
import io.agora.meeting.ui.databinding.FragmentMeetingBinding;
import io.agora.meeting.ui.util.TimeUtil;
import io.agora.meeting.ui.viewmodel.MessageViewModel;
import io.agora.meeting.ui.viewmodel.PreferenceViewModel;
import io.agora.meeting.ui.viewmodel.RoomViewModel;
import io.agora.meeting.ui.viewmodel.StreamViewModel;
import io.agora.meeting.ui.viewmodel.StreamsVideoModel;
import io.agora.meeting.ui.viewmodel.UserViewModel;
import io.agora.meeting.ui.widget.CountDownMenuView;
import q.rorbin.badgeview.QBadgeView;

public class MeetingFragment extends BaseFragment<FragmentMeetingBinding> {
    private BottomNavigationItemView mic, video, chat;
    private QBadgeView qBadgeView;
    private CountDownMenuView micCdView, videoCdView;
    private VideoFragmentAdapter videoFragAdapter;
    private FloatNotifyAdapter floatNotifyAdapter;

    private RoomViewModel roomVM;
    private UserViewModel localUserVM;
    private StreamViewModel localMainStreamVM;
    private StreamsVideoModel streamsVM;
    private MessageViewModel messageVM;
    private PreferenceViewModel preferenceVM;

    private final Runnable updateTimeRun = this::updateTime;

    private OnBackPressedCallback callback = new OnBackPressedCallback(true) {
        @Override
        public void handleOnBackPressed() {
            mayShowExitDialog();
        }
    };
    private AlertDialog mUserDialog;
    private ActionSheetFragment mActionSheetDialog;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);

        qBadgeView = new QBadgeView(getContext());
        micCdView = new CountDownMenuView(getContext());
        videoCdView = new CountDownMenuView(getContext());

        ViewModelProvider viewModelProvider = new ViewModelProvider(requireActivity());
        roomVM = viewModelProvider.get(RoomViewModel.class);
        if (roomVM.getRoomModel() == null) {
            Logger.e("MeetingFragment >> room has been destroyed");
            ((MeetingActivity) requireActivity()).navigateToLoginPage(null);
            return;
        }
        streamsVM = roomVM.getStreamsViewModel();
        String localUserId = roomVM.roomModel.getValue().getLocalUserId();
        localUserVM = roomVM.getUserViewModel(localUserId);
        if (localUserVM.getUserModel() == null) {
            Logger.e("Enter Room >> local user not found, localUserId=" + localUserId + ",existUserIds=" + roomVM.getExistUserIds());
            roomVM.leave();
            ((MeetingActivity) requireActivity()).navigateToLoginPage(null);
            return;
        }

        localMainStreamVM = localUserVM.getMainStreamViewModel();
        if(localMainStreamVM == null || localMainStreamVM.getStreamModel() == null){
            Logger.e("Enter Room >> local user main stream not found, localUserId=" + localUserId + ",existUserIds=" + roomVM.getExistUserIds());
            roomVM.leave();
            ((MeetingActivity) requireActivity()).navigateToLoginPage(null);
            return;
        }

        messageVM = roomVM.getMessageViewModel();
        preferenceVM = viewModelProvider.get(PreferenceViewModel.class);
        subscribeOnActivity();
    }

    @Override
    protected FragmentMeetingBinding createBinding(@NonNull LayoutInflater inflater, @Nullable ViewGroup container) {
        return FragmentMeetingBinding.inflate(inflater, container, false);
    }

    @Override
    protected void init() {
        // 标题配置
        setupAppBar(binding.toolbar, true);
        binding.toolbar.setTitle("");
        binding.titleLayout.setOnClickListener(v -> {
            InviteFragment.simpleCopy(requireContext(), roomVM);
        });
        binding.exit.setOnClickListener(v -> {
            callback.handleOnBackPressed();
        });
        binding.audioSwitch.setOnClickListener(v -> {
            localMainStreamVM.streamModel.getValue().switchLocalMic();
        });
        binding.cameraSwitch.setOnClickListener(v -> {
            if(localMainStreamVM.streamModel.getValue().hasVideo()){
                localMainStreamVM.streamModel.getValue().switchLocalCamera();
                preferenceVM.switchCameraFront();
            }
        });

        // 视频视图配置
        videoFragAdapter = new VideoFragmentAdapter(this);
        binding.vpVideo.setOffscreenPageLimit(3);
        binding.vpVideo.setAdapter(videoFragAdapter);
        new TabLayoutMediator(binding.tab, binding.vpVideo, (tab, position) -> {
        }).attach();
        binding.tabText.setOnClickListener(v -> {
            Object lastClickTime = v.getTag();
            long currentTime = System.currentTimeMillis();
            if (lastClickTime != null && currentTime - (long) lastClickTime < 500) {
                binding.vpVideo.setCurrentItem(0, false);
            }
            binding.tabText.setTag(currentTime);
        });
        binding.vpVideo.registerOnPageChangeCallback(new ViewPager2.OnPageChangeCallback() {
            @Override
            public void onPageSelected(int position) {
                super.onPageSelected(position);
                binding.tabText.setText(String.format(Locale.US, "%d/%d", position + 1, videoFragAdapter.getItemCount()));
            }
        });

        // 底部栏按钮配置
        mic = binding.navView.findViewById(R.id.menu_mic);
        micCdView.setupTarget(mic);
        video = binding.navView.findViewById(R.id.menu_video);
        videoCdView.setupTarget(video);
        chat = binding.navView.findViewById(R.id.menu_chat);
        binding.navView.setOnNavigationItemSelectedListener(this::onBottomMenuClicked);


        // 浮动通知区域配置
        if (floatNotifyAdapter == null) {
            floatNotifyAdapter = new FloatNotifyAdapter();
        }
        LinearLayoutManager layout = new LinearLayoutManager(requireContext(), LinearLayoutManager.VERTICAL, false);
        layout.setStackFromEnd(true);
        binding.rvNotify.setLayoutManager(layout);
        binding.rvNotify.setAdapter(floatNotifyAdapter);
        updateFloatNotifyBottom();

        startTimerCounter(false);
    }

    private boolean onBottomMenuClicked(MenuItem item) {
        int itemId = item.getItemId();
        if (itemId == R.id.menu_mic) {
            onBottomMicClick();
        } else if (itemId == R.id.menu_video) {
            onBottomCameraClick();
        } else if (itemId == R.id.menu_member) {
            ((MeetingActivity) requireActivity()).navigateToMemberListPage(requireView());
        } else if (itemId == R.id.menu_chat) {
            ((MeetingActivity) requireActivity()).navigateToMessagePage(requireView());
        } else if (itemId == R.id.menu_more) {
            showActionSheet();
        }
        return true;
    }

    private void updateVpIndicator() {
        int itemCount = streamsVM.renders.getValue().size();
        boolean tabVisible = itemCount > 1 && itemCount < 5;
        boolean tabTextVisible = itemCount >= 5;
        binding.tab.setVisibility(tabVisible ? View.VISIBLE : View.GONE);
        binding.tabText.setVisibility(tabTextVisible ? View.VISIBLE : View.GONE);
        if (tabTextVisible) {
            binding.tabText.setText(String.format(Locale.US, "%d/%d", binding.vpVideo.getCurrentItem() + 1, itemCount));
        }
    }

    private void onBottomCameraClick() {
        boolean enable = !video.isActivated();
        UserModel userModel = localUserVM.getUserModel();
        if(userModel == null){
            return;
        }
        if (!userModel.isHost() && !roomVM.hasCameraAccess() && roomVM.getRoomModel().hasHost() && enable) {
            mUserDialog = new AlertDialog.Builder(requireContext())
                    .setMessage(R.string.notify_popup_request_to_turn_cam_on)
                    .setPositiveButton(R.string.cmm_apply, (dialog, which) -> {
                        checkCameraPermission(()->{
                            localMainStreamVM.streamModel.getValue().setVideoEnable(true);
                            if (!userModel.isHost()) {
                                RoomProperties roomProperties = roomVM.roomProperties.getValue();
                                if (roomProperties != null && !roomProperties.userPermission.cameraAccess) {
                                    int second = roomProperties.processes.cameraAccess.timeout;
                                    videoCdView.start(second, null);
                                }
                            }else{
                                disableBtnClick(video, 1000);
                                disableBtnClick(mic, 1000);
                            }
                        });
                    })
                    .setNegativeButton(R.string.cmm_cancel, (dialog, which) -> dialog.dismiss())
                    .show();
        } else {
            if(enable){
                checkCameraPermission(()->{
                    disableBtnClick(video, 1000);
                    disableBtnClick(mic, 1000);
                    localMainStreamVM.streamModel.getValue().setVideoEnable(true);
                });
            }else{
                disableBtnClick(video, 1000);
                disableBtnClick(mic, 1000);
                localMainStreamVM.streamModel.getValue().setVideoEnable(false);
            }
        }
    }

    private void disableBtnClick(View btn, long delay){
        btn.setClickable(false);
        Object tag = btn.getTag();
        Runnable reEnableRun;
        if(tag instanceof Runnable){
            reEnableRun = (Runnable) tag;
        }else{
            reEnableRun = () -> btn.setClickable(true);
            btn.setTag(reEnableRun);
        }
        btn.removeCallbacks(reEnableRun);
        btn.postDelayed(reEnableRun, delay);
    }

    private void onBottomMicClick() {
        boolean enable = !mic.isActivated();
        UserModel userModel = localUserVM.getUserModel();
        if(userModel == null){
            return;
        }
        if (!userModel.isHost() && !roomVM.hasMicAccess() && roomVM.getRoomModel().hasHost() && enable) {
            mUserDialog = new AlertDialog.Builder(requireContext())
                    .setMessage(R.string.notify_popup_request_to_turn_mic_on)
                    .setPositiveButton(R.string.cmm_apply, (dialog, which) -> {
                        checkMicPermission(()->{
                            localMainStreamVM.streamModel.getValue().setAudioEnable(true);
                            if (!userModel.isHost()) {
                                RoomProperties roomProperties = roomVM.roomProperties.getValue();
                                if (roomProperties != null && !roomProperties.userPermission.micAccess) {
                                    micCdView.start(roomProperties.processes.micAccess.timeout, null);
                                }
                            }else{
                                disableBtnClick(mic, 1000);
                                disableBtnClick(video, 1000);
                            }
                        });
                    })
                    .setNegativeButton(R.string.cmm_cancel, (dialog, which) -> dialog.dismiss())
                    .show();
        } else {
            if(enable){
                checkMicPermission(()->{
                    disableBtnClick(mic, 1000);
                    disableBtnClick(video, 1000);
                    localMainStreamVM.streamModel.getValue().setAudioEnable(enable);
                });
            }else{
                disableBtnClick(mic, 1000);
                disableBtnClick(video, 1000);
                localMainStreamVM.streamModel.getValue().setAudioEnable(enable);
            }
        }
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        if (roomVM.getRoomModel() == null) {
            return;
        }
        subscribeOnFragment();
        binding.setViewModel(roomVM);
        requireActivity().getWindow().getDecorView().setKeepScreenOn(true);
    }

    @Override
    public void onDestroyView() {
        mic = video = chat = null;
        floatNotifyAdapter = null;
        stopTimerCounter();
        super.onDestroyView();
    }

    /**
     * 通知最大人数限制
     */
    private void initToastMaxNum() {
        PreferenceLiveData.IntPreferenceLiveData toastMaxNum = preferenceVM.getToastMaxNum();
        int toastMaxNumValue = toastMaxNum.getValue();
        messageVM.setToastMaxPeople(toastMaxNumValue);
        messageVM.maySendMaxPeopleShowMsg();

        toastMaxNum.observe(requireActivity(), notifyMaxNum -> {
            messageVM.setToastMaxPeople(notifyMaxNum);
        });
    }

    /**
     * 无主播时通知
     */
    private void initHostNotify() {
        UserModel userModel = localUserVM.getUserModel();
        RoomModel roomModel = roomVM.getRoomModel();
        if(userModel == null || roomModel == null){
            return;
        }

        if (!roomModel.hasHost()) {
            ActionWrapMsg message = new ActionWrapMsg();
            message.content = requireActivity().getString(R.string.notify_toast_action_no_host);
            message.actionText = requireActivity().getString(R.string.main_become_host);
            message.actionClick = v -> {
                v.setEnabled(false);
                message.actionClick = null;
                userModel.applyToBeHost();
            };
            messageVM.sendActionShowMsg(message);
        }
        if(userModel.isHost()){
            messageVM.sendLocalActionMsg(new ActionMessage.AdminChange(userModel.getUserId(),
                    userModel.getUserName()));
        }
    }


    private void updateFloatNotifyBottom() {
        if(streamsVM == null){
            return;
        }
        boolean isSpeakerLayout = streamsVM.getCurrentLayoutType() == Layout.SPEAKER;
        FrameLayout.LayoutParams layoutParams = (FrameLayout.LayoutParams) binding.rvNotify.getLayoutParams();
        layoutParams.bottomMargin = getResources().getDimensionPixelOffset(isSpeakerLayout && streamsVM.renders.getValue().get(0).streams.size() > 1?
                R.dimen.meeting_float_notify_bottom_margin_max : R.dimen.meeting_float_notify_bottom_margin_min);
        binding.rvNotify.setLayoutParams(layoutParams);
    }

    private void subscribeOnActivity() {
        initToastMaxNum();
        initHostNotify();
    }

    private void subscribeOnFragment() {
        requireActivity().getOnBackPressedDispatcher().addCallback(getViewLifecycleOwner(), callback);
        initRenderLayout();
        initChat();


        roomVM.failure.observe(getViewLifecycleOwner(), throwable -> {
            video.setClickable(true);
            mic.setClickable(true);
            if (throwable instanceof RoomViewModel.MeetingEndException
                    || throwable instanceof RoomViewModel.LocaleUserExitException) {
                dismissUserDialog();
                stopTimerCounter();
            }
        });

        localMainStreamVM.streamModel.observe(getViewLifecycleOwner(), streamModel -> {
            mic.setActivated(streamModel.hasAudio());
            video.setActivated(streamModel.hasVideo());
            mic.setClickable(true);
            video.setClickable(true);
        });

        roomVM.latestActionMessage.observe(getViewLifecycleOwner(), notify -> {
            if (notify != null && notify.type == ActionMsgType.USER_APPROVE) {
                ActionMessage.Approve payload = (ActionMessage.Approve) notify;
                if (payload.action != ApproveAction.APPLY) {
                    // 当有申请结果时，取消倒计时
                    if (payload.requestId.equals(ApproveRequest.CAMERA)) {
                        videoCdView.stop();
                    } else {
                        micCdView.stop();
                    }
                }
            }
        });
        messageVM.toastMessage.observe(getViewLifecycleOwner(), notify -> {
            if (!notify.hasRead) {
                floatNotifyAdapter.addItem(notify);
                // TipsUtil.processApply(requireActivity(), notify.message, localUserVM.getUserModel());
            }
        });
        localMainStreamVM.audioRouter.observe(getViewLifecycleOwner(), audioRoute -> {

            switch (audioRoute) {
                case AudioRoute.HEADSET:
                    binding.audioSwitch.setImageResource(R.drawable.ic_headset);
                    break;
                case AudioRoute.EARPIECE:
                    binding.audioSwitch.setImageResource(R.drawable.ic_speaker_off);
                    break;
                case AudioRoute.SPEAKER:
                    binding.audioSwitch.setImageResource(R.drawable.ic_speaker_on);
                    break;
                default:
                    binding.audioSwitch.setImageResource(R.drawable.ic_speaker_on);
            }
        });
    }

    private void initRenderLayout() {
        streamsVM.renders.observe(getViewLifecycleOwner(), renderInfos -> {
            videoFragAdapter.setListAsync(renderInfos);
            updateVpIndicator();
        });
        roomVM.getStreamsViewModel().layoutType.observe(getViewLifecycleOwner(), layoutType -> {
            videoFragAdapter.flushData();
            updateFloatNotifyBottom();
        });
    }

    private void initChat() {
        messageVM.chatMessages.observe(getViewLifecycleOwner(), chatMessages -> {
            qBadgeView.bindTarget(chat);
            int unReadCount = messageVM.getUnReadCount();
            if (unReadCount > 0) {
                qBadgeView.setBadgeNumber(unReadCount);
            } else {
                qBadgeView.hide(false);
            }
        });
    }

    private void startTimerCounter(boolean delay) {
        if (binding == null) {
            return;
        }
        stopTimerCounter();
        binding.getRoot().postDelayed(updateTimeRun, delay ? 1000 : 0);
    }

    private void stopTimerCounter() {
        if (binding == null) {
            return;
        }
        binding.getRoot().removeCallbacks(updateTimeRun);
    }

    private void updateTime() {
        if (roomVM.getRoomModel() == null || binding == null) {
            return;
        }
        long diff = TimeUtil.getSyncCurrentTimeMillis() - roomVM.getRoomModel().getStartTimestamp();
        binding.topSubtitle.setText(TimeUtil.stringForTimeHMS(diff, "%02d:%02d:%02d"));
        startTimerCounter(true);
    }

    private void showActionSheet() {
        dismissUserDialog();
        if(roomVM.getRoomModel() == null){
            return;
        }
        boolean boardSharing = roomVM.getRoomModel().isBoardSharing();
        boolean screenSharing = roomVM.getRoomModel().isScreenSharing();

        boolean boardOwner = localUserVM.getUserModel().isBoardOwner();
        final int boardMenuTitle = R.string.more_open_board;

        boolean screenOwner = localUserVM.getUserModel().isScreenOwner();
        final int screenMenuTitle = !screenSharing ? R.string.more_open_screen :
                        screenOwner ? R.string.more_close_screen : R.string.more_open_screen;

        mActionSheetDialog = ActionSheetFragment.getInstance(R.menu.sheet_meeting_more);
        mActionSheetDialog.resetMenuTitle(new HashMap<Integer, Integer>() {{
            put(R.id.menu_board, boardMenuTitle);
            put(R.id.menu_screen, screenMenuTitle);
        }});
        mActionSheetDialog.removeMenu(new ArrayList<Integer>() {{
            // TODO not implement
            add(R.id.menu_record);

            if (!localUserVM.getUserModel().isHost()) {
                add(R.id.menu_mute_all_mic);
                add(R.id.menu_mute_all_camera);
            }
            if (boardMenuTitle == View.NO_ID) {
                add(R.id.menu_board);
            }
            if (screenMenuTitle == View.NO_ID) {
                add(R.id.menu_screen);
            }
        }});
        mActionSheetDialog.setOnItemClickListener((view, position, id) -> {
            if (id == R.id.menu_invite) {
                InviteFragment.simpleCopy(requireContext(), roomVM);
            } else if (id == R.id.menu_mute_all_mic || id == R.id.menu_mute_all_camera) {
                CheckBox checkBox = new CheckBox(requireContext());
                checkBox.setText(id == R.id.menu_mute_all_mic ? R.string.notify_popup_permission_needed_to_turn_mic_on : R.string.notify_popup_permission_needed_to_turn_camera_on);
                dismissLoadingDialog();
                mUserDialog = new AlertDialog.Builder(requireContext())
                        .setView(checkBox)
                        .setMessage(id == R.id.menu_mute_all_mic ? R.string.more_mute_all_mic : R.string.more_mute_all_camera)
                        .setPositiveButton(R.string.cmm_continue, (dialog, which) -> {
                            dialog.dismiss();
                            localUserVM.getUserModel().muteAll(id == R.id.menu_mute_all_mic ? Device.MIC : Device.CAMERA);
                            if (checkBox.isChecked()) {
                                localUserVM.getUserModel().changeUserPermission(id == R.id.menu_mute_all_mic ? Device.MIC : Device.CAMERA, false);
                            }
                        })
                        .setNegativeButton(R.string.cmm_cancel, (dialog, which) -> dialog.dismiss())
                        .show();
            } else if (id == R.id.menu_record) {
                // TODO not implement
            } else if (id == R.id.menu_board) {
                if (boardMenuTitle == R.string.more_close_board) {
                    localUserVM.getUserModel().stopBoardShare();
                } else {
                    localUserVM.getUserModel().startBoardShare();
                }
            } else if (id == R.id.menu_setting) {
                ((MeetingActivity) requireActivity()).navigateToSettingPage(requireView());
            } else if (id == R.id.menu_screen) {
                if (screenMenuTitle == R.string.more_close_screen) {
                    localUserVM.getUserModel().stopScreenShare();
                } else {
                    dismissLoadingDialog();
                    mUserDialog = new AlertDialog.Builder(requireContext())
                            .setMessage(R.string.notify_popup_start_screen_share_tip)
                            .setPositiveButton(R.string.notify_popup_start_sharing, (dialog, which) -> localUserVM.getUserModel().startScreenShare())
                            .setNegativeButton(R.string.cmm_cancel, (dialog, which) -> dialog.dismiss())
                            .show();
                }
            }
        });
        mActionSheetDialog.show(getChildFragmentManager(), null);
    }

    private void mayShowExitDialog() {
        dismissUserDialog();
        RoomModel roomModel = roomVM.getRoomModel();
        UserModel localUserModel = localUserVM.getUserModel();
        if(roomModel == null || localUserModel == null){
            return;
        }
        if (roomModel.isScreenSharing() && localUserModel.isScreenOwner()) {
            mUserDialog = new AlertDialog.Builder(requireContext())
                    .setMessage(R.string.notify_popup_leave_with_screenshare_on)
                    .setNegativeButton(R.string.cmm_no, (dialog, which) -> dialog.dismiss())
                    .setPositiveButton(R.string.cmm_yes, (dialog, which) -> {
                        localUserModel.stopScreenShare();
                    })
                    .show();
            return;
        }
        if (roomModel.isBoardSharing() && localUserModel.isBoardOwner()) {
            mUserDialog = new AlertDialog.Builder(requireContext())
                    .setMessage(R.string.notify_popup_leave_with_whiteboard_on)
                    .setNegativeButton(R.string.cmm_no, (dialog, which) -> dialog.dismiss())
                    .setPositiveButton(R.string.cmm_yes, (dialog, which) -> {
                        localUserModel.stopBoardShare();
                    })
                    .show();
            return;
        }
        showExitDialog();
    }

    private void showExitDialog() {
        dismissUserDialog();

        mActionSheetDialog = ActionSheetFragment.getInstance(R.menu.sheet_meeting_exit);

        mActionSheetDialog.setOnItemClickListener((view, position, id) -> {
            RoomModel roomModel = roomVM.getRoomModel();
            if(roomModel == null){
                return;
            }
            String roomId = roomModel.roomId;
            String userId = roomModel.getLocalUserId();
            if(id == R.id.menu_close_meeting){
                roomVM.close();
                stopTimerCounter();
                ((MeetingActivity) requireActivity()).showRateDialog(roomId, userId, null);
            }else if(id == R.id.menu_exist_meeting){
                roomVM.leave();
                stopTimerCounter();
                ((MeetingActivity) requireActivity()).showRateDialog(roomId, userId, null);
            }
        });
        if (!localUserVM.getUserModel().isHost()) {
            mActionSheetDialog.removeMenu(Arrays.asList(R.id.menu_close_meeting));
        }
        mActionSheetDialog.show(getChildFragmentManager(), null);
    }

    private void dismissUserDialog() {
        if (mUserDialog != null) {
            mUserDialog.dismiss();
            mUserDialog = null;
        }
        if(mActionSheetDialog != null){
            mActionSheetDialog.dismiss();
            mActionSheetDialog = null;
        }
    }

    private long lastCameraMsgSendTime = 0;
    private void checkCameraPermission(Runnable grantedRun) {
        if (AndPermission.hasPermissions(this, Permission.CAMERA)) {
            if (grantedRun != null) {
                grantedRun.run();
            }
            return;
        }
        AndPermission.with(this)
                .runtime()
                .permission(Permission.CAMERA)
                .onGranted(data -> {
                    if (grantedRun != null) {
                        grantedRun.run();
                    }
                })
                .onDenied(data -> {
                    if(System.currentTimeMillis() - lastCameraMsgSendTime > 10000){
                        lastCameraMsgSendTime = System.currentTimeMillis();
                        messageVM.sendActionShowMsg(
                                getString(R.string.notify_toast_action_cam_denied),
                                getString(R.string.cmm_edit),
                                v -> gotoAppDetailIntent(requireActivity()));
                    }
                })
                .start();
    }

    private long lastMicMsgSendTime = 0;
    private void checkMicPermission(Runnable grantedRun) {
        if (AndPermission.hasPermissions(this, Permission.RECORD_AUDIO)) {
            if (grantedRun != null) {
                grantedRun.run();
            }
            return;
        }
        AndPermission.with(this)
                .runtime()
                .permission(Permission.RECORD_AUDIO)
                .onGranted(data -> {
                    if (grantedRun != null) {
                        grantedRun.run();
                    }
                })
                .onDenied(data -> {
                    if(System.currentTimeMillis() - lastMicMsgSendTime > 10000){
                        lastMicMsgSendTime = System.currentTimeMillis();
                        messageVM.sendActionShowMsg(
                                getString(R.string.notify_toast_action_mic_denied),
                                getString(R.string.cmm_edit),
                                v -> gotoAppDetailIntent(requireActivity()));
                    }
                })
                .start();
    }

    /**
     * 跳转到应用详情界面
     */
    private static void gotoAppDetailIntent(Activity activity) {
        Intent intent = new Intent();
        intent.setAction(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
        intent.setData(Uri.parse("package:" + activity.getPackageName()));
        activity.startActivity(intent);
    }

}
