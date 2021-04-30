package io.agora.meeting.core;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.DiffUtil;
import androidx.recyclerview.widget.ListUpdateCallback;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

import io.agora.meeting.core.annotaion.DataState;
import io.agora.meeting.core.annotaion.Keep;
import io.agora.meeting.core.log.Logger;
import io.agora.rte.AgoraRteScene;
import io.agora.rte.AgoraRteSceneConnectionState;
import io.agora.rte.AgoraRteStreamInfo;
import io.agora.rte.AgoraRteUserInfo;

/**
 * Description:
 *
 *
 * @since 3/30/21
 */
@Keep
public final class ConnectionHandler {
    private final static Executor sExecutor = Executors.newSingleThreadExecutor();
    private ReConnectListener reConnectListener;
    private List<AgoraRteUserInfo> userInfoList;
    private List<AgoraRteStreamInfo> streamInfoList;

    public void handleConnectionState(AgoraRteSceneConnectionState state, AgoraRteScene scene) {
        Logger.d("ConnectionHandler >> handleConnectionState state=" + state);
        if (state == AgoraRteSceneConnectionState.CONNECTED) {
            syncData(scene.getAllUsers(), scene.getAllStreams(), scene.getSceneProperties());
        } else if (state == AgoraRteSceneConnectionState.ABORTED) {
            if (reConnectListener != null) {
                reConnectListener.onError();
            }
        } else {
            userInfoList = scene.getAllUsers();
            streamInfoList = scene.getAllStreams();
        }
    }

    public void setReConnectListener(ReConnectListener reConnectListener) {
        this.reConnectListener = reConnectListener;
    }

    public void release() {
        reConnectListener = null;
        userInfoList = null;
        streamInfoList = null;
    }

    private void syncData(List<AgoraRteUserInfo> userInfoList,
                          List<AgoraRteStreamInfo> streamInfoList,
                          Map<String, Object> sceneProperties) {
        sExecutor.execute(() -> {

            if (ConnectionHandler.this.userInfoList == null || ConnectionHandler.this.streamInfoList == null) {
                return;
            }
            final List<AgoraRteUserInfo> oldUserInfoList = new ArrayList<>(ConnectionHandler.this.userInfoList);
            final List<AgoraRteStreamInfo> oldStreamInfoList = new ArrayList<>(ConnectionHandler.this.streamInfoList);
            final List<AgoraRteUserInfo> newUserInfoList = new ArrayList<>(userInfoList);
            final List<AgoraRteStreamInfo> newStreamInfoList = new ArrayList<>(streamInfoList);

            DiffUtil.DiffResult userListDiff = DiffUtil.calculateDiff(new DiffUtil.Callback() {
                @Override
                public int getOldListSize() {
                    return oldUserInfoList.size();
                }

                @Override
                public int getNewListSize() {
                    return newUserInfoList.size();
                }

                @Override
                public boolean areItemsTheSame(int oldItemPosition, int newItemPosition) {
                    return oldUserInfoList.get(oldItemPosition).equals(newUserInfoList.get(newItemPosition));
                }

                @Override
                public boolean areContentsTheSame(int oldItemPosition, int newItemPosition) {
                    AgoraRteUserInfo old = oldUserInfoList.get(oldItemPosition);
                    AgoraRteUserInfo nnew = newUserInfoList.get(newItemPosition);
                    return old.getRole().equals(nnew.getRole());
                }

                @Nullable
                @Override
                public Object getChangePayload(int oldItemPosition, int newItemPosition) {
                    return newUserInfoList.get(newItemPosition);
                }
            });
            userListDiff.dispatchUpdatesTo(new ListUpdateCallback() {
                @Override
                public void onInserted(int position, int count) {
                    if (reConnectListener != null && position < newUserInfoList.size()) {
                        reConnectListener.onUserChanged(newUserInfoList.get(position), DataState.ADD);
                    }
                }

                @Override
                public void onRemoved(int position, int count) {
                    if (reConnectListener != null && position < oldUserInfoList.size()) {
                        reConnectListener.onUserChanged(oldUserInfoList.get(position), DataState.REMOVE);
                    }
                }

                @Override
                public void onMoved(int fromPosition, int toPosition) {

                }

                @Override
                public void onChanged(int position, int count, @Nullable Object payload) {
                    if (reConnectListener != null) {
                        reConnectListener.onUserChanged((AgoraRteUserInfo) payload, DataState.UPDATE);
                    }
                }
            });

            DiffUtil.DiffResult streamDiff = DiffUtil.calculateDiff(new DiffUtil.Callback() {
                @Override
                public int getOldListSize() {
                    return oldStreamInfoList.size();
                }

                @Override
                public int getNewListSize() {
                    return newStreamInfoList.size();
                }

                @Override
                public boolean areItemsTheSame(int oldItemPosition, int newItemPosition) {
                    return oldStreamInfoList.get(oldItemPosition).equals(newStreamInfoList.get(newItemPosition));
                }

                @Override
                public boolean areContentsTheSame(int oldItemPosition, int newItemPosition) {
                    AgoraRteStreamInfo old = oldStreamInfoList.get(oldItemPosition);
                    AgoraRteStreamInfo nnew = newStreamInfoList.get(newItemPosition);
                    return Boolean.compare(old.getHasVideo(), nnew.getHasVideo()) == 0
                            && Boolean.compare(old.getHasAudio(), nnew.getHasAudio()) == 0;
                }

                @Nullable
                @Override
                public Object getChangePayload(int oldItemPosition, int newItemPosition) {
                    return newStreamInfoList.get(newItemPosition);
                }
            });
            streamDiff.dispatchUpdatesTo(new ListUpdateCallback() {
                @Override
                public void onInserted(int position, int count) {
                    if (reConnectListener != null && position < newStreamInfoList.size()) {
                        reConnectListener.onStreamChanged(newStreamInfoList.get(position), DataState.ADD);
                    }
                }

                @Override
                public void onRemoved(int position, int count) {
                    if (reConnectListener != null && position < oldStreamInfoList.size()) {
                        reConnectListener.onStreamChanged(oldStreamInfoList.get(position), DataState.REMOVE);
                    }
                }

                @Override
                public void onMoved(int fromPosition, int toPosition) {

                }

                @Override
                public void onChanged(int position, int count, @Nullable Object payload) {
                    if (reConnectListener != null) {
                        reConnectListener.onStreamChanged((AgoraRteStreamInfo) payload, DataState.UPDATE);
                    }
                }
            });

            if (reConnectListener != null) {
                reConnectListener.onRoomPropertiesChanged(sceneProperties);
                reConnectListener.onComplete();
            }
        });
    }


    @Keep
    public interface ReConnectListener {
        void onUserChanged(AgoraRteUserInfo userInfo, @DataState int state);

        void onStreamChanged(AgoraRteStreamInfo streamInfo, @DataState int state);

        void onRoomPropertiesChanged(Map<String, Object> sceneProperties);

        void onComplete();

        void onError();
    }
}
