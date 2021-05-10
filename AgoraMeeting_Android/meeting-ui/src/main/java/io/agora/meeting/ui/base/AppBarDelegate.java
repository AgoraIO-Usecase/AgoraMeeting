package io.agora.meeting.ui.base;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.Toolbar;

public interface AppBarDelegate {

    void setupAppBar(@NonNull Toolbar toolbar, boolean isLight);
}
