package io.agora.meeting.annotaion.message;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

import io.agora.meeting.annotaion.member.Role;

@IntDef({PeerCmd.ADMIN, PeerCmd.NORMAL})
@Retention(RetentionPolicy.SOURCE)
public @interface PeerCmd {
    /**
     * {@link Role#HOST} actions
     */
    int ADMIN = 1;
    /**
     * {@link Role#AUDIENCE} actions
     */
    int NORMAL = 2;
}
