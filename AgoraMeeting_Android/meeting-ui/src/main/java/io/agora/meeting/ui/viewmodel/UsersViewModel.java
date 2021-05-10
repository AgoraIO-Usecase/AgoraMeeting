package io.agora.meeting.ui.viewmodel;

import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MediatorLiveData;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModel;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

import io.agora.meeting.core.log.Logger;
import io.agora.meeting.core.model.RoomModel;
import io.agora.meeting.core.model.StreamModel;
import io.agora.meeting.core.model.UserModel;

/**
 * Description:
 *
 *
 * @since 2/17/21
 */
public class UsersViewModel extends ViewModel {
    private static final String TAG = "UsersViewModel";

    public final MediatorLiveData<List<UserModel>> userModels = new MediatorLiveData<>();
    private final static Executor sExecutor = Executors.newSingleThreadExecutor();

    private final List<UserModel> cacheUsers = new ArrayList<>();
    private String query;


    public void init(RoomViewModel roomViewModel){
        try {
            userModels.addSource(roomViewModel.roomModel, roomModel -> onRoomModelUpdate(roomViewModel, roomModel));
        } catch (Exception e) {
            Logger.d(TAG, e.toString());
        }
    }

    private void onRoomModelUpdate(RoomViewModel roomVM, RoomModel roomModel){
        List<UserModel> userList = roomModel.getUserModels();
        cacheUsers.clear();
        cacheUsers.addAll(userList);
        for (UserModel userModel : userList) {
            UserViewModel userViewModel = roomVM.getUserViewModel(userModel.getUserId());
            addSourceSafe(userViewModel.userModel, userModel1 -> onUserModelUpdate(userViewModel, userModel1));
        }
    }

    private void onUserModelUpdate(UserViewModel userVM, UserModel userModel){
        List<StreamModel> streamModels = userModel.getStreamModels();
        for (StreamModel streamModel : streamModels) {
            StreamViewModel streamViewModel = userVM.getStreamViewModel(streamModel.getStreamId());
            addSourceSafe(streamViewModel.streamModel, this::onStreamModelUpdate);
        }
        sortAndFilterUsers();
    }

    private void onStreamModelUpdate(StreamModel streamModel){
        sortAndFilterUsers();
    }

    private <S> void addSourceSafe(@NonNull LiveData<S> source, @NonNull Observer<? super S> onChanged){
        try {
            userModels.addSource(source, onChanged);
        } catch (Exception e) {
            Logger.e(TAG, e.toString());
            onChanged.onChanged(source.getValue());
        }
    }


    private void sortAndFilterUsers() {
        sExecutor.execute(() -> {
            List<UserModel> list = new ArrayList<>();

            UserModel me = null;
            List<UserModel> hosts = new ArrayList<>();
            List<UserModel> others = new ArrayList<>();
            final String _condition = query;

            List<UserModel> copy = new ArrayList<>(cacheUsers);
            for (UserModel m : copy) {
                if(TextUtils.isEmpty(_condition) || m.getUserName().contains(_condition)){
                    if(m.isLocal()){
                        me = m;
                    }else if(m.isHost()){
                        hosts.add(m);
                    }else{
                        others.add(m);
                    }
                }
            }
            if(me != null) list.add(me);
            list.addAll(hosts);
            list.addAll(others);

            userModels.postValue(list);
        });
    }

    public void setQuery(String query, boolean filter) {
        this.query = query;
        if(filter){
            sortAndFilterUsers();
        }
    }

}
