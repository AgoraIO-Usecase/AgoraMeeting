package io.agora.meeting.ui.viewmodel;

import androidx.annotation.NonNull;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;
import androidx.lifecycle.ViewModelProvider;
import androidx.lifecycle.ViewModelStore;
import androidx.lifecycle.ViewModelStoreOwner;

import io.agora.meeting.core.log.Logger;
import io.agora.meeting.core.model.StreamModel;
import io.agora.meeting.core.model.UserModel;
import io.agora.meeting.ui.util.ToastUtil;

/**
 * Description:
 *
 *
 * @since 2/7/21
 */
public class UserViewModel extends ViewModel implements ViewModelStoreOwner {
    private final static String TAG = "UserViewModelV2";

    public MutableLiveData<UserModel> userModel = new MutableLiveData<>();

    private final ViewModelStore streamViewModelStore;
    private final ViewModelProvider streamModelProvider;

    private final UserModel.CallBack userCallback = new UserModel.CallBack() {
        @Override
        public void onError(Throwable error) {
            ToastUtil.showShort(error.getMessage());
        }

        @Override
        public void onUserInfoUpdate(UserModel userModel) {
            UserViewModel.this.userModel.postValue(userModel);
        }

        @Override
        public void onStreamAdd(StreamModel streamModel) {
            UserViewModel.this.userModel.postValue(userModel.getValue());
        }

        @Override
        public void onStreamRemove(StreamModel streamModel) {
            UserViewModel.this.userModel.postValue(userModel.getValue());
        }
    };

    public UserViewModel(){
        streamViewModelStore = new ViewModelStore();
        streamModelProvider = new ViewModelProvider(this);
    }

    public void init(UserModel userModel){
        if(this.userModel.getValue() != null && this.userModel.getValue() == userModel){
            return;
        }
        this.userModel.setValue(userModel);
        try {
            userModel.registerCallback(userCallback);
        } catch (Exception e) {
            Logger.e(TAG, e.toString());
        }
    }

    @Override
    protected void onCleared() {
        streamViewModelStore.clear();
        super.onCleared();
    }

    public UserModel getUserModel() {
        return userModel.getValue();
    }

    public StreamViewModel getStreamViewModel(String streamId){
        StreamViewModel streamViewModel = streamModelProvider.get(streamId, StreamViewModel.class);
        streamViewModel.init(getUserModel().getStreamModel(streamId));
        return streamViewModel;
    }


    @NonNull
    @Override
    public ViewModelStore getViewModelStore() {
        return streamViewModelStore;
    }

    public StreamViewModel getMainStreamViewModel() {
        UserModel userModel = this.userModel.getValue();
        if(userModel == null){
            return null;
        }
        StreamModel mainStreamModel = userModel.getMainStreamModel();
        if(mainStreamModel == null){
            return null;
        }
        return getStreamViewModel(mainStreamModel.getStreamId());
    }
}
