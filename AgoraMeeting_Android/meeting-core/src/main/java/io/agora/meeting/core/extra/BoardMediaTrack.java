package io.agora.meeting.core.extra;

import android.content.Context;
import android.view.ViewGroup;

import com.herewhite.sdk.RoomParams;
import com.herewhite.sdk.WhiteSdk;
import com.herewhite.sdk.WhiteSdkConfiguration;
import com.herewhite.sdk.domain.DeviceType;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

import io.agora.meeting.core.annotaion.Keep;
import io.agora.rte.AgoraRteAudioSourceType;
import io.agora.rte.AgoraRteError;
import io.agora.rte.AgoraRteMediaTrack;
import io.agora.rte.AgoraRteVideoSourceType;
import io.agora.whiteboard.netless.manager.BoardManager;
import io.agora.whiteboard.netless.widget.WhiteBoardView;

/**
 * Description:
 *
 *
 * @since 2/23/21
 */
@Keep
public final class BoardMediaTrack implements AgoraRteMediaTrack {
    private BoardManager boardManager;
    private WhiteSdk boardSdk;
    private WhiteBoardView boardView;
    private Context context;
    private String boardId;
    private String boardToken;
    private boolean writable;

    public BoardMediaTrack(Context context, String boardId, String boardToken, boolean writable){
        this.context = context;
        this.boardId = boardId;
        this.boardToken = boardToken;
        this.writable = writable;
    }

    private void init() {
        boardView = new WhiteBoardView(context);
        boardView.addOnLayoutChangeListener((v, left, top, right, bottom, oldLeft, oldTop, oldRight, oldBottom) -> {
            if (boardManager != null) {
                boardManager.refreshViewSize();
            }
        });
        boardManager = new BoardManager();
        WhiteSdkConfiguration configuration = new WhiteSdkConfiguration(DeviceType.touch, 10, 0.01);
        boardSdk = new WhiteSdk(boardView, context, configuration);
        RoomParams roomParams = new RoomParams(boardId, boardToken);
        roomParams.setWritable(writable);
        boardManager.init(boardSdk, roomParams);
    }


    public void setWritable(boolean writable) {
        this.writable = writable;
        if (boardManager != null) {
            boardManager.setWritable(writable);
        }
    }

    public boolean isWritable() {
        return writable;
    }

    public void setAppliance(String appliance){
        if (boardManager != null) {
            boardManager.setAppliance(appliance);
        }
    }

    public void cleanBoard(){
        if (boardManager != null) {
            boardManager.cleanScene(false);
        }
    }

    public void setStrokeColor(int[] color){
        if (boardManager != null) {
            boardManager.setStrokeColor(color);
        }
    }

    public int[] getBoardStrokeColor() {
        if(boardManager == null){
            return null;
        }
        int[] strokeColor = boardManager.getStrokeColor();
        if(strokeColor == null){
            strokeColor = new int[]{0, 0, 255};
        }
        return strokeColor;
    }

    public WhiteBoardView getBoardView(boolean detachFromParent) {
        if (detachFromParent) {
            if (boardView.getParent() instanceof ViewGroup) {
                ((ViewGroup) boardView.getParent()).removeView(boardView);
                boardView.setOnClickListener(null);
            }
        }
        return boardView;
    }

    @Nullable
    @Override
    public AgoraRteError start() {
        init();
        return null;
    }

    @Nullable
    @Override
    public AgoraRteError stop() {
        if (boardSdk != null) {
            boardSdk.releaseRoom();
        }
        if (boardView != null) {
            if (boardView.getParent() instanceof ViewGroup) {
                ((ViewGroup) boardView.getParent()).removeView(boardView);
            }
            boardView = null;
        }
        context = null;
        return null;
    }

    @NotNull
    @Override
    public AgoraRteVideoSourceType getVideoSourceType() {
        return AgoraRteVideoSourceType.none;
    }

    @NotNull
    @Override
    public AgoraRteAudioSourceType getAudioSourceType() {
        return AgoraRteAudioSourceType.none;
    }

    @NotNull
    @Override
    public String getTrackId() {
        return this.toString();
    }
}
