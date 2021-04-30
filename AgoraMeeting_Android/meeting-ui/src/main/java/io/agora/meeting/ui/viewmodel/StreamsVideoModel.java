package io.agora.meeting.ui.viewmodel;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MediatorLiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModel;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

import io.agora.meeting.core.annotaion.StreamType;
import io.agora.meeting.core.log.Logger;
import io.agora.meeting.core.model.RoomModel;
import io.agora.meeting.core.model.StreamModel;
import io.agora.meeting.core.model.UserModel;
import io.agora.meeting.ui.annotation.Layout;
import io.agora.meeting.ui.data.RenderInfo;
import io.agora.meeting.ui.data.StreamModelTags;

public class StreamsVideoModel extends ViewModel {
    private final static String TAG_LOG = "StreamsVideoModel";
    private final static int DELAY_SHOW_AUDIO_LAYOUT = 6000;

    private final static Executor sExecutor = Executors.newSingleThreadExecutor();
    public final MediatorLiveData<List<RenderInfo>> renders = new MediatorLiveData<>();
    public final MutableLiveData<Integer> layoutType = new MutableLiveData<>();

    private final List<StreamModel> streamModelList = new ArrayList<>();
    private final Handler mHandler = new Handler(Looper.getMainLooper());
    private final Runnable toAudioLayoutRun = () -> updateRendersByTypeAsync(Layout.AUDIO);

    private int userLayoutType = Layout.TILED;

    public void init(RoomViewModel viewModel) {
        try {
            renders.addSource(viewModel.roomModel, roomModel -> onRoomModelUpdate(viewModel, roomModel));
        } catch (Exception e) {
            Logger.d(TAG_LOG, e.toString());
        }
    }

    @Override
    protected void onCleared() {
        super.onCleared();
        mHandler.removeCallbacks(toAudioLayoutRun);
    }

    private void onRoomModelUpdate(RoomViewModel roomVM, RoomModel roomModel) {
        if (roomVM.roomModel.getValue() == null) {
            return;
        }
        List<UserModel> userModels = roomModel.getUserModels();
        Iterator<UserModel> iterator = userModels.iterator();
        boolean sourceAddSuccess = false;
        while (iterator.hasNext()) {
            UserModel next = iterator.next();
            if (next != null) {
                UserViewModel userViewModel = roomVM.getUserViewModel(next.getUserId());
                sourceAddSuccess = addSourceSafe(userViewModel.userModel, userModel1 -> onUserModelUpdate(userViewModel, userModel1, userModels));
            }
        }
        if(!sourceAddSuccess){
            resetRendersAsync(userModels);
        }
    }

    private void onUserModelUpdate(UserViewModel userVM, UserModel userModel, List<UserModel> userModels) {
        if(userModel == null){
            return;
        }
        List<StreamModel> streamModels = userModel.getStreamModels();
        Iterator<StreamModel> iterator = streamModels.iterator();
        boolean sourceAddSuccess = false;
        while (iterator.hasNext()) {
            StreamModel next = iterator.next();
            if (next != null) {
                StreamViewModel streamViewModel = userVM.getStreamViewModel(next.getStreamId());
                sourceAddSuccess = addSourceSafe(streamViewModel.streamModel, streamModel1 -> onStreamModelUpdate(streamModel1, userModels));
            }
        }
        if(!sourceAddSuccess){
            resetRendersAsync(userModels);
        }
    }

    private void onStreamModelUpdate(StreamModel streamModel, List<UserModel> userModels) {
        resetRendersAsync(userModels);
    }


    private <S> boolean addSourceSafe(@NonNull LiveData<S> source, @NonNull Observer<? super S> onChanged) {
        try {
            renders.addSource(source, onChanged);
            return true;
        } catch (Exception e) {
            Logger.i(TAG_LOG, e.toString());
            return false;
        }
    }

    private void resetRendersAsync(List<UserModel> userModels) {
        sExecutor.execute(() -> resetRenders(userModels));
    }

    private void resetRenders(List<UserModel> userModels) {
        if (userModels == null || userModels.size() == 0) {
            return;
        }
        boolean hasVideo = false, hasShareScreen = false, hasShareBoard = false;
        int mindex = 0;

        List<StreamModel> updateStreams = new ArrayList<>();
        List<UserModel> _userModels = new ArrayList<>(userModels);
        for (UserModel userModel : _userModels) {
            for (StreamModel stream : userModel.getStreamModels()) {
                boolean top = false;
                int index = mindex++;
                if (stream.hasVideo()) {
                    hasVideo = true;
                }
                if (stream.getStreamType() == StreamType.SCREEN) {
                    hasShareScreen = true;
                    top = true;
                    index = -2;
                }
                if (stream.getStreamType() == StreamType.BOARD) {
                    hasShareBoard = true;
                    top = true;
                    index = -2;
                }
                if (userModel.isLocal() && index >= 0) {
                    top = true;
                    index = -1;
                }
                if (userModel.isHost() && index >= 0) {
                    top = true;
                    index = 0;
                }
                setMemberExtra(stream, index, top, !streamModelList.contains(stream) && (hasShareBoard || hasShareScreen));
                updateStreams.add(stream);
            }
            mindex++;
        }
        streamModelList.clear();
        streamModelList.addAll(updateStreams);

        updateRenders(hasVideo, hasShareScreen, hasShareBoard);
    }

    private void updateRenders(boolean hasVideo, boolean hasShareScreen, boolean hasShareBoard) {
        int layoutType = Layout.TILED;
        if (!hasVideo) {
            layoutType = Layout.AUDIO;
        }
        if (hasShareScreen || hasShareBoard) {
            layoutType = Layout.SPEAKER;
        }

        Logger.d("RenderVideoModel", "updateRenders layoutType:" + layoutType);
        if (layoutType == Layout.AUDIO
                && getCurrentLayoutType() != Layout.AUDIO
                && getCurrentLayoutType() != Layout.SPEAKER
        ) {
            updateRendersByType(Layout.TILED);
            mHandler.postDelayed(toAudioLayoutRun, DELAY_SHOW_AUDIO_LAYOUT);
        } else if (layoutType == Layout.TILED) {
            updateRendersByType(userLayoutType);
        } else {
            updateRendersByType(layoutType);
        }
    }

    private void updateRendersByTypeAsync(@Layout int type) {
        sExecutor.execute(() -> updateRendersByType(type));
    }

    private void updateRendersByType(@Layout int type) {
        mHandler.removeCallbacks(toAudioLayoutRun);
        boolean needEvent = type != getCurrentLayoutType();
        if (type == Layout.TILED) {
            updateRendersLoop(true, this::genTiledRenderInfo);
        } else if (type == Layout.AUDIO) {
            updateRendersLoop(false, this::genAudioRenderInfo);
        } else if (type == Layout.SPEAKER) {
            updateRendersLoop(false, this::genSpeakerRenderInfo);
        }
        if (needEvent) {
            layoutType.postValue(type);
        }
    }

    public void speaker2Tiled() {
        if (getCurrentLayoutType() == Layout.TILED) return;
        updateRendersByTypeAsync(userLayoutType = Layout.TILED);
    }

    public void tiled2Speaker(@Nullable StreamModel stream) {
        if (stream == null) return;
        if (getCurrentLayoutType() != Layout.SPEAKER) userLayoutType = Layout.SPEAKER;
        stream.<StreamModelExtra>getTag(StreamModelTags.TAG_KEY_EXTRA).index = -1;
        updateRendersByTypeAsync(Layout.SPEAKER);
    }

    private RenderInfo genSpeakerRenderInfo(int index) {
        // 演讲者视图的最大人数，第一个全屏显示
        final int perCount = Integer.MAX_VALUE;
        final int start = index * perCount;
        if (start >= streamModelList.size()) {
            return null;
        }

        // 确保第一个是 视频/屏幕共享/白板
        int firstIndex = -1;
        for (int i = 0; i < streamModelList.size(); i++) {
            StreamModel member = streamModelList.get(i);
            if (member.hasVideo()) {
                firstIndex = i;
                break;
            }
        }
        if (firstIndex > 0) {
            StreamModel remove = streamModelList.remove(firstIndex);
            streamModelList.add(0, remove);
        }

        RenderInfo renderInfo = new RenderInfo();
        renderInfo.layout = Layout.SPEAKER;
        renderInfo.column = 3.5f;
        renderInfo.streams.addAll(streamModelList);

        Logger.d("Meeting Speaker Layout", "genSpeakerRenderInfo members:" + renderInfo.streams.toString());

        return renderInfo;
    }

    private RenderInfo genAudioRenderInfo(int index) {
        // 平铺视图每个界面显示用户数
        final int perCount = 12;
        final int start = index * perCount;
        if (start >= streamModelList.size()) {
            return null;
        }
        RenderInfo renderInfo = new RenderInfo();
        renderInfo.layout = Layout.AUDIO;
        renderInfo.column = 3;
        renderInfo.row = perCount / renderInfo.column;
        for (int i = 0; i < perCount; i++) {
            int ii = start + i;
            if (ii < streamModelList.size()) {
                renderInfo.streams.add(streamModelList.get(ii));
            }
        }
        return renderInfo;
    }

    public void setTiledTop(StreamModel stream, boolean isTop) {
        if (stream == null) return;
        if (getCurrentLayoutType() != Layout.TILED) return;
        String extraId = stream.getStreamId();
        StreamModelExtra userModelExtra = stream.<StreamModelExtra>getTag(StreamModelTags.TAG_KEY_EXTRA);
        Logger.d("Meeting Tiled Layout", "setTiledTop extraId:" + extraId + ",memberExtra:" + userModelExtra.toString());
        userModelExtra.isTop = isTop;
        userModelExtra.index = isTop ? -1 : Integer.MAX_VALUE;
        updateRendersByTypeAsync(Layout.TILED);
    }

    private RenderInfo genTiledRenderInfo(int index) {
        // 平铺视图每个界面显示用户数
        final int perCount = 4;
        final int start = index * perCount;
        if (start >= streamModelList.size()) {
            return null;
        }
        RenderInfo renderInfo = new RenderInfo();
        renderInfo.layout = Layout.TILED;
        renderInfo.column = 2;
        renderInfo.row = perCount / renderInfo.column;
        for (int i = 0; i < perCount; i++) {
            int ii = start + i;
            if (ii < streamModelList.size()) {
                renderInfo.streams.add(streamModelList.get(ii));
            }
        }
        Logger.d("Meeting Tiled Layout", "genTiledRenderInfo member list: " + renderInfo.streams.toString());
        return renderInfo;
    }

    private void sortMembers(boolean sortTop) {
        Collections.sort(streamModelList, (o1, o2) -> {
            StreamModelExtra e1 = o1.getTag(StreamModelTags.TAG_KEY_EXTRA);
            StreamModelExtra e2 = o2.getTag(StreamModelTags.TAG_KEY_EXTRA);
            if (sortTop) {
                if (e1.isTop && e2.isTop) {
                    return e1.index - e2.index;
                }
                if (e1.isTop) {
                    return -1;
                } else if (e2.isTop) {
                    return 1;
                }
            }
            return e1.index - e2.index;
        });

        for (int i = 0; i < streamModelList.size(); i++) {
            StreamModel streamModel = streamModelList.get(i);
            StreamModelExtra extra = streamModel.getTag(StreamModelTags.TAG_KEY_EXTRA);
            extra.index = i;
        }
    }

    private void updateRendersLoop(boolean sortTop, RenderInfoGen renderInfoGen) {
        sortMembers(sortTop);
        List<RenderInfo> renderInfos = new ArrayList<>();
        int index = 0;
        for (; ; ) {
            RenderInfo renderInfo = renderInfoGen.genRenderInfo(index);
            if (renderInfo == null) {
                break;
            }
            renderInfos.add(renderInfo);
            index++;
        }
        renders.postValue(renderInfos);
    }

    @Layout
    public int getCurrentLayoutType() {
        List<RenderInfo> value = renders.getValue();
        if (value == null || value.size() == 0) return Layout.TILED;
        return value.get(0).layout;
    }


    private static void setMemberExtra(StreamModel stream, int index, boolean isTop, boolean overwrite) {
        StreamModelExtra extra = stream.getTag(StreamModelTags.TAG_KEY_EXTRA);
        if (extra == null) {
            stream.setTag(StreamModelTags.TAG_KEY_EXTRA, new StreamModelExtra(index, isTop));
        } else if (overwrite) {
            extra.index = index;
            extra.isTop = isTop;
        }
    }

    public static boolean isTop(StreamModel stream) {
        StreamModelExtra extra = stream.getTag(StreamModelTags.TAG_KEY_EXTRA);
        if (extra != null) {
            return extra.isTop;
        }
        return false;
    }

    public static void setMeIsHost(StreamModel stream, boolean meIsHost) {
        stream.setTag(StreamModelTags.TAG_KEY_ME_IS_HOST, meIsHost);
    }

    public static boolean getMeIsHost(StreamModel stream) {
        Object tag = stream.getTag(StreamModelTags.TAG_KEY_ME_IS_HOST);
        if (tag != null) {
            return (boolean) tag;
        }
        return false;
    }

    private interface RenderInfoGen {
        RenderInfo genRenderInfo(int index);
    }

    public static class StreamModelExtra {
        public int index;
        public boolean isTop;

        private StreamModelExtra(int index, boolean isTop) {
            this.index = index;
            this.isTop = isTop;
        }

        @Override
        public String toString() {
            return "MemberExtra{" +
                    "index=" + index +
                    ", isTop=" + isTop +
                    '}';
        }
    }
}
