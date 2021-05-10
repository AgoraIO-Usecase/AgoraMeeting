package io.agora.meeting.ui.viewmodel;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.StringRes;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModel;

import java.util.List;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

import io.agora.meeting.core.annotaion.ActionMsgType;
import io.agora.meeting.core.annotaion.ApproveAction;
import io.agora.meeting.core.annotaion.ApproveRequest;
import io.agora.meeting.core.annotaion.Device;
import io.agora.meeting.core.annotaion.ModuleState;
import io.agora.meeting.core.bean.ActionMessage;
import io.agora.meeting.core.bean.ChatMessage;
import io.agora.meeting.core.log.Logger;
import io.agora.meeting.core.utils.TimeSyncUtil;
import io.agora.meeting.ui.MeetingActivity;
import io.agora.meeting.ui.MeetingApplication;
import io.agora.meeting.ui.R;
import io.agora.meeting.ui.annotation.ActionMsgShowType;
import io.agora.meeting.ui.annotation.ChatState;
import io.agora.meeting.ui.data.ActionWrapMsg;
import io.agora.meeting.ui.data.ChatWrapMsg;
import io.agora.meeting.ui.data.ListLiveData;
import io.agora.meeting.ui.data.QueueLiveData;
import io.agora.meeting.ui.util.ToastUtil;

/**
 * Description:
 *
 *
 * @since 2/17/21
 */
public class MessageViewModel extends ViewModel {
    private static final String TAG = "MessageViewModelV2";
    private final static Executor sExecutor = Executors.newSingleThreadExecutor();

    private static final String TAG_MAX_PEOPLE_SHOW_MESSAGE = "MaxPeopleShowMessage";

    public final ListLiveData<ChatWrapMsg> chatMessages = new ListLiveData<>();
    public final ListLiveData<ActionWrapMsg> actionMessages = new ListLiveData<>();
    public final QueueLiveData<ActionWrapMsg> toastMessage = new QueueLiveData<>();

    private RoomViewModel roomVM;
    private final Observer<ChatMessage> chatMessageObserver = this::onReceiveRemoteChatMsg;
    private final Observer<ActionMessage> actionWrapMsgObserver = this::onReceiveRemoteActionMsg;

    private volatile int toastMaxPeople = 0;

    public void init(RoomViewModel roomVM) {
        this.roomVM = roomVM;
        try {
            roomVM.latestChatMessage.observeForever(chatMessageObserver);
            roomVM.latestActionMessage.observeForever(actionWrapMsgObserver);
        } catch (Exception e) {
            Logger.i(TAG, e.toString());
        }
    }

    @Override
    protected void onCleared() {
        if(roomVM != null){
            roomVM.latestChatMessage.removeObserver(chatMessageObserver);
            roomVM.latestActionMessage.removeObserver(actionWrapMsgObserver);
            roomVM = null;
        }
        super.onCleared();
    }

    private void onReceiveRemoteActionMsg(ActionMessage actionMessage) {
        sExecutor.execute(() -> {
            ActionWrapMsg msg = new ActionWrapMsg(
                    actionMessage,
                    ActionMsgShowType.TEXT,
                    getActionContent(actionMessage)
            );

            dealMsgWithActionBefore(actionMessage, msg);

            if(!TextUtils.isEmpty(msg.content)){
                showToast(msg);
                postActionWrapMsg(msg);
            }

            dealMsgWithActionAfter(actionMessage);
        });
    }

    private void dealMsgWithActionAfter(ActionMessage inMsg) {
        if (inMsg.type == ActionMsgType.USER_CHANGE) {
            maySendMaxPeopleShowMsg();
        }
    }

    private void dealMsgWithActionBefore(ActionMessage inMsg, ActionWrapMsg outMsg) {
        if (inMsg.type == ActionMsgType.USER_APPROVE) {
            ActionMessage.Approve approve = (ActionMessage.Approve) inMsg;
            if (approve.action == ApproveAction.APPLY) {
                outMsg.type = ActionMsgShowType.ACTION;
                outMsg.actionText = getString(R.string.cmm_accept);
                outMsg.actionCountDownEndTime = approve.duration * 1000 + TimeSyncUtil.getSyncCurrentTimeMillis();
                outMsg.actionClick = v -> {
                    outMsg.actionCountDownEndTime = 0;
                    outMsg.actionClick = null;
                    outMsg.actionText = getString(R.string.cmm_accepted);
                    v.setEnabled(false);
                    ((TextView)v).setText(outMsg.actionText);
                    if (roomVM != null) {
                        roomVM.getLocalUserViewModel().getUserModel().acceptPermRequest(approve.requestId, approve.userId, error -> {
                            ToastUtil.showShort(R.string.net_requests_expired);
                        });
                    }
                };
            }
        }else if(inMsg.type == ActionMsgType.ADMIN_CHANGE && !roomVM.getRoomModel().hasHost()){
            outMsg.type = ActionMsgShowType.ACTION;
            outMsg.actionText = getString(R.string.main_become_host);
            outMsg.actionClick = v -> {
                v.setEnabled(false);
                outMsg.actionClick = null;
                if (roomVM != null) {
                    roomVM.getLocalUserViewModel().getUserModel().applyToBeHost();
                }
            };
        }
    }

    private String getActionContent(ActionMessage actionMessage){
        if (actionMessage == null) {
            return "";
        }
        int type = actionMessage.type;
        String ret = "";
        boolean bln = true;
        try{
            bln = ActionMsgType.ADMIN_MUTE_ALL  == type  && assertContent(getString(R.string.notify_toast_mute_all_mic),  ((ActionMessage.AdminMuteAll) actionMessage).device == Device.MIC);
            bln = ActionMsgType.ADMIN_MUTE_ALL  == type  && assertContent(getString(R.string.notify_toast_mute_all_cam),  ((ActionMessage.AdminMuteAll) actionMessage).device == Device.CAMERA);
            bln = ActionMsgType.ACCESS_CHANGE   == type  && assertContent(getString(R.string.notify_toast_cam_permission_off) , ((ActionMessage.Access) actionMessage).device == Device.CAMERA, ((ActionMessage.Access) actionMessage).state == ModuleState.ENABLE);
            bln = ActionMsgType.ACCESS_CHANGE   == type  && assertContent(getString(R.string.notify_toast_cam_permission_on),  ((ActionMessage.Access) actionMessage).device == Device.CAMERA, ((ActionMessage.Access) actionMessage).state == ModuleState.DISABLE);
            bln = ActionMsgType.ACCESS_CHANGE   == type  && assertContent(getString(R.string.notify_toast_mic_permission_off),  ((ActionMessage.Access) actionMessage).device == Device.MIC, ((ActionMessage.Access) actionMessage).state == ModuleState.ENABLE);
            bln = ActionMsgType.ACCESS_CHANGE   == type  && assertContent(getString(R.string.notify_toast_mic_permission_on),  ((ActionMessage.Access) actionMessage).device == Device.MIC, ((ActionMessage.Access) actionMessage).state == ModuleState.DISABLE);
            bln = ActionMsgType.ADMIN_MUTE      == type  && assertContent(getString(R.string.notify_toast_admin_turn_off_cam),  ((ActionMessage.AdminMute) actionMessage).device == Device.CAMERA, ((ActionMessage.AdminMute) actionMessage).isLocal);
            bln = ActionMsgType.ADMIN_MUTE      == type  && assertContent(getString(R.string.notify_toast_admin_turn_off_mic),  ((ActionMessage.AdminMute) actionMessage).device == Device.MIC, ((ActionMessage.AdminMute) actionMessage).isLocal);
            bln = ActionMsgType.ADMIN_CHANGE    == type  && assertContent(getString(R.string.notify_toast_new_admin, actionMessage.userName), !((ActionMessage.AdminChange)actionMessage).isAbandon );
            bln = ActionMsgType.ADMIN_CHANGE    == type  && assertContent(getString(R.string.notify_toast_action_no_host, actionMessage.userName), ((ActionMessage.AdminChange)actionMessage).isAbandon && roomVM != null && !roomVM.getRoomModel().hasHost());
            bln = ActionMsgType.USER_CHANGE     == type  && assertContent(getString(R.string.notify_toast_enter_room, actionMessage.userName),  ((ActionMessage.UserChange)actionMessage).state == ModuleState.ENABLE);
            bln = ActionMsgType.USER_CHANGE     == type  && assertContent(getString(R.string.notify_toast_leave_room, actionMessage.userName), ((ActionMessage.UserChange)actionMessage).state == ModuleState.DISABLE);
            bln = ActionMsgType.SCREEN_CHANGE   == type  && assertContent(getString(R.string.notify_toast_screen_start, actionMessage.userName), ((ActionMessage.ScreenChange)actionMessage).state == ModuleState.ENABLE);
            bln = ActionMsgType.SCREEN_CHANGE   == type  && assertContent(getString(R.string.notify_toast_screen_end, actionMessage.userName), ((ActionMessage.ScreenChange)actionMessage).state == ModuleState.DISABLE);
            bln = ActionMsgType.BOARD_CHANGE    == type  && assertContent(getString(R.string.notify_toast_whiteboard_end, actionMessage.userName), ((ActionMessage.BoardChange)actionMessage).state == ModuleState.DISABLE);
            bln = ActionMsgType.BOARD_CHANGE    == type  && assertContent(getString(R.string.notify_toast_whiteboard_start, actionMessage.userName), ((ActionMessage.BoardChange)actionMessage).state == ModuleState.ENABLE);
            bln = ActionMsgType.BOARD_INTERACT  == type  && assertContent(getString(R.string.notify_toast_whiteboard_join, actionMessage.userName), ((ActionMessage.BoardInteract)actionMessage).state == ModuleState.ENABLE);

            bln = ActionMsgType.USER_APPROVE    == type  && assertContent(getString(R.string.notify_popup_apply_video_title, actionMessage.userName), ((ActionMessage.Approve)actionMessage).requestId.equals(ApproveRequest.CAMERA), ((ActionMessage.Approve)actionMessage).action == ApproveAction.APPLY);
            bln = ActionMsgType.USER_APPROVE    == type  && assertContent(getString(R.string.notify_popup_reject_video_apply_title, actionMessage.userName), ((ActionMessage.Approve)actionMessage).requestId.equals(ApproveRequest.CAMERA), ((ActionMessage.Approve)actionMessage).action == ApproveAction.REJECT);
            bln = ActionMsgType.USER_APPROVE    == type  && assertContent(getString(R.string.notify_popup_accept_video_apply_title, actionMessage.userName), ((ActionMessage.Approve)actionMessage).requestId.equals(ApproveRequest.CAMERA), ((ActionMessage.Approve)actionMessage).action == ApproveAction.ACCEPT);

            bln = ActionMsgType.USER_APPROVE    == type  && assertContent(getString(R.string.notify_popup_apply_audio_title, actionMessage.userName), ((ActionMessage.Approve)actionMessage).requestId.equals(ApproveRequest.MIC), ((ActionMessage.Approve)actionMessage).action == ApproveAction.APPLY);
            bln = ActionMsgType.USER_APPROVE    == type  && assertContent(getString(R.string.notify_popup_reject_audio_apply_title, actionMessage.userName), ((ActionMessage.Approve)actionMessage).requestId.equals(ApproveRequest.MIC), ((ActionMessage.Approve)actionMessage).action == ApproveAction.REJECT);
            bln = ActionMsgType.USER_APPROVE    == type  && assertContent(getString(R.string.notify_popup_accept_audio_apply_title, actionMessage.userName), ((ActionMessage.Approve)actionMessage).requestId.equals(ApproveRequest.MIC), ((ActionMessage.Approve)actionMessage).action == ApproveAction.ACCEPT);

        }catch (Exception exception){
            ret = exception.getMessage();
        }
        return ret;
    }

    public void maySendMaxPeopleShowMsg(){
        sExecutor.execute(() -> {
            if (roomVM.getUserSize() >= toastMaxPeople) {
                boolean shouldShowMsg = true;
                String content = MeetingApplication.getContext().getString(toastMaxPeople > 0 ? R.string.notify_toast_action_toast_over_max_num : R.string.notify_toast_action_toast_notify_mute_always, toastMaxPeople);
                for (int i = actionMessages.size() - 1; i >= 0; i--) {
                    ActionWrapMsg actionWrapMsg = actionMessages.get(i);
                    if (TAG_MAX_PEOPLE_SHOW_MESSAGE.equals(actionWrapMsg.tag)) {
                        if (actionWrapMsg.content.equals(content)) {
                            shouldShowMsg = false;
                        }
                        break;
                    }
                }
                if (shouldShowMsg) {
                    ActionWrapMsg msg = new ActionWrapMsg();
                    msg.actionClick = v -> ((MeetingActivity) v.getContext()).navigateToSettingPage(v);
                    msg.content = content;
                    msg.actionText = MeetingApplication.getContext().getString(R.string.cmm_edit);
                    msg.tag = TAG_MAX_PEOPLE_SHOW_MESSAGE;
                    msg.type = ActionMsgShowType.ACTION;
                    postActionWrapMsg(msg);
                    toastMessage.postValue(msg);
                }
            }
        });
    }

    public void sendActionShowMsg(String contentStr, String actionStr, View.OnClickListener click){
        ActionWrapMsg msg = new ActionWrapMsg();
        msg.actionClick = click;
        msg.content = contentStr;
        msg.actionText = actionStr;
        sendActionShowMsg(msg);
    }

    public void sendActionShowMsg(ActionWrapMsg msg){
        msg.type = ActionMsgShowType.ACTION;
        postActionWrapMsg(msg);
        showToast(msg);
    }

    public void sendLocalActionMsg(ActionMessage message){
        onReceiveRemoteActionMsg(message);
    }

    private void postActionWrapMsg(ActionWrapMsg msg) {
        if (msg.message == null) {
            msg.message = new ActionMessage(0) {};
        }
        setActionMsgTimeShow(msg);
        actionMessages.add(msg);
    }

    private void showToast(ActionWrapMsg actionMsgWrap){
        if (roomVM.getUserSize() >= toastMaxPeople
                && actionMsgWrap.message.type == ActionMsgType.USER_CHANGE) {
            return;
        }
        toastMessage.postValue(actionMsgWrap);
    }

    private void onReceiveRemoteChatMsg(ChatMessage chatMessage) {
        if (!chatMessage.fromUserId.equals(roomVM.getRoomModel().getLocalUserId())) {
            ChatWrapMsg chatWrapMsg = new ChatWrapMsg();
            chatWrapMsg.message = chatMessage;
            chatWrapMsg.isFromMyself = false;
            chatWrapMsg.hasRead = false;
            setChatMsgTimeShow(chatWrapMsg);
            chatMessages.add(chatWrapMsg);
        }
    }

    public void setChatMessagesRead() {
        chatMessages.changeAll(item -> {
            item.hasRead = true;
        });
    }

    public int sentLocalChatMsg(String msg){
        int index = chatMessages.size();
        ChatWrapMsg chatWrapMsg = new ChatWrapMsg();
        chatWrapMsg.message = new ChatMessage(TimeSyncUtil.getSyncCurrentTimeMillis(), 0, "", "", msg);
        chatWrapMsg.isFromMyself = true;
        chatWrapMsg.state = ChatState.SENDING;
        chatWrapMsg.hasRead = true;
        setChatMsgTimeShow(chatWrapMsg);
        chatMessages.add(chatWrapMsg);
        return index;
    }

    public void setLocalChatMsgState(int index, @ChatState int st){
        chatMessages.changeItem(index, item -> item.state = st);
    }

    private void setChatMsgTimeShow(ChatWrapMsg msg){
        int size = chatMessages.size();
        if(size <= 0){
            msg.showTime = true;
            return;
        }
        ChatWrapMsg chatWrapMsg = chatMessages.get(size - 1);
        long lastMsgTime = chatWrapMsg.message.timestamp;
        long duration = (long)Math.ceil((msg.message.timestamp - lastMsgTime) * 1.0f / 1000 / 60); // min
        if(duration >= 2){
            // 2min
            msg.showTime = true;
        }
    }

    private void setActionMsgTimeShow(ActionWrapMsg msg){
        int size = actionMessages.size();
        if(size <= 0){
            msg.showTime = true;
            return;
        }
        ActionWrapMsg actionWrapMsg = actionMessages.get(size - 1);
        long lastMsgTime = actionWrapMsg.message.timestamp;
        long duration = (long)Math.ceil((msg.message.timestamp - lastMsgTime) * 1.0f / 1000 / 60); // min
        if(duration >= 10){
            // 10min
            msg.showTime = true;
        }
    }

    public int getUnReadCount() {
        int count = 0;
        List<ChatWrapMsg> value = chatMessages.getValue();
        if (value == null) {
            return count;
        }
        int size = value.size();
        for (int i = size - 1; i >= 0; i--) {
            ChatWrapMsg chatMessage = value.get(i);
            if (!chatMessage.hasRead) {
                count++;
            } else {
                break;
            }
        }
        return count;
    }

    private boolean assertContent(String content, boolean... conditions){
        if(conditions != null){
            for (boolean condition : conditions) {
                if(!condition){
                    return false;
                }
            }
        }
        throw new RuntimeException(content);
    }

    private String getString(@StringRes int resId, Object... formatArgs){
        Context context = MeetingApplication.getContext();
        if(context == null){
            return "";
        }
        return context.getString(resId, formatArgs);
    }

    public void setToastMaxPeople(int toastMaxPeople) {
        this.toastMaxPeople = toastMaxPeople;
    }

}
