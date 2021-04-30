package io.agora.meeting.ui.data;

import java.util.ArrayList;
import java.util.List;

import io.agora.meeting.core.model.StreamModel;
import io.agora.meeting.ui.annotation.Layout;

/**
 * author: xcz
 * since:  1/19/21
 **/
public final class RenderInfo {

    @Layout
    public int layout = Layout.TILED;

    public float row;
    public float column;

    public List<StreamModel> streams = new ArrayList<>();


    public int getItemId(int index){
        return 1 << (62 - layout) + index;
    }

}
