package io.agora.meeting.ui.adapter;

import android.view.LayoutInflater;
import android.view.Surface;
import android.view.SurfaceView;
import android.view.TextureView;
import android.view.View;
import android.view.ViewGroup;

import io.agora.meeting.core.annotaion.RenderMode;
import io.agora.meeting.core.annotaion.StreamType;
import io.agora.meeting.core.log.Logger;
import io.agora.meeting.core.model.StreamModel;
import io.agora.meeting.ui.R;
import io.agora.meeting.ui.data.StreamModelTags;
import io.agora.meeting.ui.widget.WhiteBoardWrapView;
import io.agora.meeting.ui.widget.gesture.GestureLayer;
import io.agora.meeting.ui.widget.gesture.touch.adapter.GestureVideoTouchAdapterImpl;

/**
 * Description:
 *
 *
 * @since 2/9/21
 */
public class StreamBinding {
    private static final int TEXTURE_VIEW_ID = View.generateViewId();
    private static final int SURFACE_VIEW_ID = View.generateViewId();

    public static boolean isVisibleToUser(StreamModel streamModel) {
        if (streamModel == null) {
            return false;
        }
        Object tag = streamModel.getTag(StreamModelTags.TAG_KEY_IS_VISIBLE_TO_USER);
        if (tag instanceof Boolean) {
            return (boolean) tag;
        }
        return true;
    }

    public static void setVisibleToUser(StreamModel streamModel, boolean visible) {
        if (streamModel == null) {
            return;
        }
        streamModel.setTag(StreamModelTags.TAG_KEY_IS_VISIBLE_TO_USER, visible);
    }

    public static void bindStream(ViewGroup container, StreamModel streamModel, boolean showBoardTools, boolean overlay, boolean scale, boolean renderOnVisible, boolean highStream) {
        if(streamModel.isReleased()){
            return;
        }
        int streamType = streamModel.getStreamType();
        if (streamType == StreamType.BOARD) {
            bindBoardStream(container, streamModel, showBoardTools);
        } else if (streamType == StreamType.SCREEN
                && streamModel.getOwner().isLocal()
                && streamModel.getOwner().isScreenOwner()) {
            bindLocalScreenStream(container);
        } else if (scale) {
            bindScaleMediaStream(container, streamModel, highStream);
        } else {
            bindMediaStream2(container, streamModel, overlay, renderOnVisible, highStream);
        }
    }

    private static void bindLocalScreenStream(ViewGroup container) {
        container.setTag(null);
        View child = container.getChildAt(0);
        if (child == null || child.getId() != R.id.local_screen_layout) {
            container.removeAllViews();
            LayoutInflater.from(container.getContext()).inflate(R.layout.layout_local_screen, container);
        }
    }

    public static void bindBoardStream(ViewGroup container, StreamModel streamModel, boolean showTools) {
        container.setTag(null);
        WhiteBoardWrapView wrapView = null;
        View child = container.getChildAt(0);
        if (child instanceof WhiteBoardWrapView) {
            wrapView = (WhiteBoardWrapView) child;
            if (!wrapView.hasBoardView()) {
                wrapView.startup(streamModel.getBoardView(false), streamModel.getBoardStrokeColor());
            }
        } else {
            wrapView = new WhiteBoardWrapView(container.getContext());
            wrapView.setOnSelectListener(new WhiteBoardWrapView.OnSelectListener() {
                @Override
                public void onStrokeColorSelected(int[] color) {
                    streamModel.changeBoardStrokeColor(color);
                }

                @Override
                public void onCleanSelected() {
                    streamModel.cleanBoard();
                }

                @Override
                public void onApplianceSelected(String appliance) {
                    streamModel.setBoardAppliance(appliance);
                }
            });

            container.removeAllViews();
            container.addView(wrapView, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);

            wrapView.startup(streamModel.getBoardView(false), streamModel.getBoardStrokeColor());
        }
        streamModel.setBoardWritable(showTools);
        wrapView.setToolsVisible(showTools && streamModel.canBoardInteract());
    }

    private static void bindScaleMediaStream(ViewGroup container, StreamModel streamModel, boolean highStream) {
        if (streamModel.hasVideo()) {
            String streamId = streamModel.getStreamId();

            GestureLayer gestureLayer = null;
            TextureView textureView = container.findViewById(TEXTURE_VIEW_ID);
            if (textureView != null) {
                if (textureView.isAvailable()) {
                    Object textureViewTag = textureView.getTag();
                    if (streamId.equals(textureViewTag)) {
                        streamModel.subscriptVideo(textureView, RenderMode.HIDDEN, highStream);
                        return;
                    }
                }
            }
            textureView = streamModel.createTextureView(container.getContext());
            if (textureView == null) {
                container.removeAllViews();
                return;
            }
            textureView.setId(TEXTURE_VIEW_ID);
            textureView.setTag(streamId);
            gestureLayer = new GestureLayer(container.getContext(), new GestureVideoTouchAdapterImpl(textureView) {
                @Override
                public boolean isFullScreen() {
                    return true;
                }
            });

            // add textureView to gestureLayer
            gestureLayer.getContainer().addView(textureView, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);

            // add gestureLayer to container
            container.removeAllViews();
            container.addView(gestureLayer.getContainer(), ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);

            streamModel.subscriptVideo(textureView, RenderMode.HIDDEN, highStream);
        } else {
            container.removeAllViews();
        }
    }

    private static void bindMediaStream2(ViewGroup container, StreamModel streamModel, boolean overlay, boolean renderOnVisible, boolean highStream) {
        container.setTag(null);
        if (streamModel.hasVideo()) {
            String streamId = streamModel.getStreamId();
            TextureView textureView = container.findViewById(TEXTURE_VIEW_ID);
            if (textureView != null) {
                if (textureView.isAvailable()) {
                    Object tag = textureView.getTag();
                    if (streamId.equals(tag)) {
                        // return if the SurfaceView has bound this uid
                        Logger.d("bindVideo >> SurfaceView resume -- streamId: " + streamId);
                        maySubscriptVideo(streamModel, renderOnVisible, textureView, highStream);
                        return;
                    }
                }
            }
            textureView = streamModel.createTextureView(container.getContext());
            if (textureView == null) {
                Logger.d("bindVideo >> SurfaceView recreate failed -- streamId: " + streamId);
                container.removeAllViews();
                return;
            }
            Logger.d("bindVideo >> SurfaceView recreate success -- streamId: " + streamId);
            textureView.setTag(streamId); // bind uid
            textureView.setId(TEXTURE_VIEW_ID);
            container.removeAllViews();
            container.addView(textureView, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);

            maySubscriptVideo(streamModel, renderOnVisible, textureView, highStream);
        } else {
            container.removeAllViews();
        }
    }

    private static void bindMediaStream(ViewGroup container, StreamModel streamModel, boolean overlay, boolean renderOnVisible) {
        container.setTag(null);
        if (streamModel.hasVideo()) {
            String streamId = streamModel.getStreamId();
            SurfaceView surfaceView = container.findViewById(SURFACE_VIEW_ID);
            if (surfaceView != null) {
                Surface surface = surfaceView.getHolder().getSurface();
                if (surface != null && surface.isValid()) {
                    Object tag = surfaceView.getTag();
                    if (streamId.equals(tag)) {
                        // return if the SurfaceView has bound this uid
                        Logger.d("bindVideo >> SurfaceView resume -- streamId: " + streamId);
                        maySubscriptVideo(streamModel, renderOnVisible, surfaceView, true);
                        return;
                    }
                }
            }
            surfaceView = streamModel.createSurfaceView(container.getContext());
            if (surfaceView == null) {
                Logger.d("bindVideo >> SurfaceView recreate failed -- streamId: " + streamId);
                container.removeAllViews();
                return;
            }
            Logger.d("bindVideo >> SurfaceView recreate success -- streamId: " + streamId);
            surfaceView.setZOrderMediaOverlay(overlay);
            surfaceView.setTag(streamId); // bind uid
            surfaceView.setId(SURFACE_VIEW_ID);
            container.removeAllViews();
            container.addView(surfaceView, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);

            maySubscriptVideo(streamModel, renderOnVisible, surfaceView, true);
        } else {
            container.removeAllViews();
        }
    }

    private static void maySubscriptVideo(StreamModel streamModel, boolean renderOnVisible, View surfaceView, boolean highStream) {
        if (renderOnVisible) {
            if (isVisibleToUser(streamModel)) {
                streamModel.subscriptVideo(surfaceView, RenderMode.HIDDEN, highStream);
            } else {
                streamModel.unSubscriptVideo();
            }
        } else {
            streamModel.subscriptVideo(surfaceView, RenderMode.HIDDEN, highStream);
        }
    }

}
