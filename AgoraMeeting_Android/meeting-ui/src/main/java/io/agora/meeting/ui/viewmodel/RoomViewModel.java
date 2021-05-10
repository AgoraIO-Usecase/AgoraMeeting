package io.agora.meeting.ui.viewmodel;

import androidx.annotation.NonNull;
import androidx.lifecycle.ViewModel;
import androidx.lifecycle.ViewModelProvider;
import androidx.lifecycle.ViewModelStore;
import androidx.lifecycle.ViewModelStoreOwner;

import java.util.ArrayList;
import java.util.List;

import io.agora.meeting.core.bean.ActionMessage;
import io.agora.meeting.core.bean.ChatMessage;
import io.agora.meeting.core.bean.RoomProperties;
import io.agora.meeting.core.log.Logger;
import io.agora.meeting.core.model.RoomModel;
import io.agora.meeting.core.model.UserModel;
import io.agora.meeting.core.utils.CryptoUtil;
import io.agora.meeting.ui.MeetingApplication;
import io.agora.meeting.ui.data.CleanableLiveData;
import io.agora.meeting.ui.data.ConfigInfo;
import io.agora.meeting.ui.util.UUIDUtil;

/**
 * Description:
 *
 *
 * @since 2/7/21
 */
public class RoomViewModel extends ViewModel implements ViewModelStoreOwner {
    public final ConfigInfo configInfo = new ConfigInfo();
    public final CleanableLiveData<Throwable> failure = new CleanableLiveData<>();
    public final CleanableLiveData<ChatMessage> latestChatMessage = new CleanableLiveData<>();
    public final CleanableLiveData<ActionMessage> latestActionMessage = new CleanableLiveData<>();

    public final CleanableLiveData<RoomModel> roomModel = new CleanableLiveData<>();
    public final CleanableLiveData<RoomProperties> roomProperties = new CleanableLiveData<>();

    private final ViewModelStore mViewModelStore;
    private final ViewModelProvider mModelProvider;

    public RoomViewModel() {
        mViewModelStore = new ViewModelStore();
        mModelProvider = new ViewModelProvider(this);

        resetLiveData();
    }

    private void resetLiveData(){
        releaseRoomModel();
        roomModel.clean();
        roomProperties.clean();
        failure.clean();
        latestActionMessage.clean();
        latestChatMessage.clean();
    }

    @Override
    protected void onCleared() {
        releaseRoomModel();
        mViewModelStore.clear();
        super.onCleared();
    }

    private void releaseRoomModel() {
        if (roomModel != null && roomModel.getValue() != null) {
            roomModel.getValue().release();
        }
    }

    public void enter(String roomName, String userName, String roomPwd, boolean openMic, boolean openCamera,
                      int durationS, int maxPeople) {
        configInfo.roomName = roomName;
        configInfo.roomPwd = roomPwd;
        configInfo.userName = userName;
        configInfo.durationS = durationS;
        configInfo.maxPeople = maxPeople;
        configInfo.openMic = openMic;
        configInfo.openCamera = openCamera;

        resetLiveData();
        String userId = UUIDUtil.getUUID();
        Logger.d("Enter Room >> userId=" + userId);
        RoomModel roomM = MeetingApplication.getMeetingEngine().joinOrCreateRoom(
                roomName, CryptoUtil.md5(roomName), roomPwd,
                userName, userId,
                openMic, openCamera,
                durationS, maxPeople
        );
        roomM.registerCallback(new RoomModel.Callback() {
            @Override
            public void onError(Throwable throwable) {
                failure.postValue(throwable);
            }

            @Override
            public void onRoomClosed() {
                failure.postValue(new MeetingEndException());
            }

            @Override
            public void onKickedOut() {
                failure.postValue(new LocaleUserExitException());
            }

            @Override
            public void onJoinSuccess(List<UserModel> roomUsers) {
                Logger.d("Enter Room >> RoomViewModel onJoinSuccess local userId=" + roomM.getLocalUserId());
                roomModel.setValue(roomM);
            }

            @Override
            public void onUserModelAdd(UserModel userModel) {
                notifyChange();
            }

            @Override
            public void onUserModelRemove(UserModel userModel) {
                notifyChange();
            }

            @Override
            public void onRoomPropertiesChanged(RoomProperties properties) {
                RoomViewModel.this.roomProperties.postValue(properties);
            }

            @Override
            public void onChatMessageReceived(ChatMessage chatMsg) {
                latestChatMessage.postValue(chatMsg);
            }

            @Override
            public void onActionMessageReceived(ActionMessage actionMsg) {
                latestActionMessage.postValue(actionMsg);
            }
        });
    }

    public void notifyChange(){
        RoomModel value = roomModel.getValue();
        if(value != null){
            roomModel.postValue(value);
        }
    }

    public void leave() {
        if (roomModel.getValue() != null) {
            roomModel.getValue().leave();
            reset();
        }
    }

    public void close() {
        if (roomModel.getValue() != null) {
            roomModel.getValue().close();
            reset();
        }
    }

    public void reset(){
        mViewModelStore.clear();
        resetLiveData();
    }

    public RoomModel getRoomModel(){
        return roomModel.getValue();
    }

    public String getRoomName() {
        if (roomModel.getValue() != null) {
            return roomModel.getValue().roomName;
        }
        return "";
    }

    public String getRoomPwd() {
        if (roomProperties.getValue() != null) {
            return roomProperties.getValue().roomInfo.roomPassword;
        }
        return "";
    }

    public boolean isMeetingProcessing(){
        return roomModel != null && roomModel.getValue() != null && !roomModel.getValue().isReleased();
    }


    public UserViewModel getUserViewModel(String userId) {
        UserViewModel userVM = mModelProvider.get(userId, UserViewModel.class);
        userVM.init(roomModel.getValue().getUserModelByUserId(userId));
        return userVM;
    }

    public UserViewModel getLocalUserViewModel(){
        RoomModel value = roomModel.getValue();
        if(value == null){
            return null;
        }
        return getUserViewModel(value.getLocalUserId());
    }


    @NonNull
    @Override
    public ViewModelStore getViewModelStore() {
        return mViewModelStore;
    }

    public StreamsVideoModel getStreamsViewModel() {
        StreamsVideoModel streamsVideoModel = mModelProvider.get(StreamsVideoModel.class);
        streamsVideoModel.init(this);
        return streamsVideoModel;
    }

    public UsersViewModel getUsersViewModel() {
        UsersViewModel usersViewModel = mModelProvider.get(UsersViewModel.class);
        usersViewModel.init(this);
        return usersViewModel;
    }

    public MessageViewModel getMessageViewModel(){
        MessageViewModel vm = mModelProvider.get(MessageViewModel.class);
        vm.init(this);
        return vm;
    }

    public int getUserSize() {
        if(roomModel.getValue() != null){
            return roomModel.getValue().getUserModels().size();
        }
        return 0;
    }

    public boolean hasCameraAccess() {
        RoomProperties value = roomProperties.getValue();
        if(value != null && value.userPermission != null){
            return value.userPermission.cameraAccess;
        }
        return true;
    }

    public boolean hasMicAccess() {
        RoomProperties value = roomProperties.getValue();
        if(value != null && value.userPermission != null){
            return value.userPermission.micAccess;
        }
        return true;
    }

    public List<String> getExistUserIds() {
        List<String> ids = new ArrayList<>();
        if (roomModel.getValue() != null) {
            for (UserModel userModel : roomModel.getValue().getUserModels()) {
                ids.add(userModel.getUserId());
            }
        }
        return ids;
    }


    public static class LocaleUserExitException extends Throwable{}
    public static class MeetingEndException extends Throwable{}
}
