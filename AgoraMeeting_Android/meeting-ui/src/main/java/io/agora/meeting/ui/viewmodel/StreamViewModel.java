package io.agora.meeting.ui.viewmodel;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import io.agora.meeting.core.annotaion.AudioRoute;
import io.agora.meeting.core.http.network.HttpException;
import io.agora.meeting.core.log.Logger;
import io.agora.meeting.core.model.StreamModel;
import io.agora.meeting.ui.util.ToastUtil;

/**
 * Description:
 *
 *
 * @since 2/8/21
 */
public class StreamViewModel extends ViewModel {
    private static final String TAG = "StreamViewModel";

    public MutableLiveData<StreamModel> streamModel = new MutableLiveData<>();
    public MutableLiveData<Integer> audioRouter = new MutableLiveData<>();

    private final StreamModel.CallBack streamCallback = new StreamModel.CallBack() {
        @Override
        public void onError(Throwable error) {
            Logger.d("StreamViewModel global error code=" + ((error instanceof HttpException)?((HttpException)error).getCode():"null") + ", message=" + error.getMessage() );
            ToastUtil.showShort(error.getMessage());
        }

        @Override
        public void onStreamChanged(StreamModel streamModel) {
            notifyStreamChange(streamModel);
        }

        @Override
        public void onAudioVolumeChanged(StreamModel streamModel) {

        }

        @Override
        public void onAudioRouteChange(@AudioRoute int audioRoute) {
            audioRouter.postValue(audioRoute);
        }
    };

    @Override
    protected void onCleared() {
        super.onCleared();
        if (streamModel.getValue() != null) {
            streamModel.getValue().release();
        }
    }

    public void init(StreamModel streamModel) {
        if(this.streamModel.getValue() != null && this.streamModel.getValue() == streamModel){
            return;
        }
        this.streamModel.setValue(streamModel);
        try {
            streamModel.registerCallback(streamCallback);
        } catch (Exception e) {
            Logger.e(TAG, e.toString());
        }
    }

    private void notifyStreamChange(StreamModel streamModel){
        this.streamModel.postValue(streamModel);
    }

    public StreamModel getStreamModel() {
        return streamModel.getValue();
    }
}
