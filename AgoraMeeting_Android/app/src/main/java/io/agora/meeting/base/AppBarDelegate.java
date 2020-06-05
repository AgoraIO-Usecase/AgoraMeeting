package io.agora.meeting.base;

import androidx.appcompat.widget.Toolbar;

public interface AppBarDelegate {
    Toolbar getToolbar();

    boolean lightMode();
}
