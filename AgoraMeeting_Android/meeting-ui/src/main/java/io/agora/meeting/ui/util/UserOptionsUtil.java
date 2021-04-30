package io.agora.meeting.ui.util;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

import io.agora.meeting.core.log.Logger;
import io.agora.meeting.core.model.RoomModel;
import io.agora.meeting.core.model.StreamModel;
import io.agora.meeting.core.model.UserModel;
import io.agora.meeting.ui.R;

/**
 * Description:
 * 点击自己/用户更多选项工具类
 *
 *
 * @since 4/4/21
 */
public class UserOptionsUtil {
    private static final Executor sExecutor = Executors.newSingleThreadExecutor();

    public static void getUsersOptionIdsAsync(RoomModel roomModel,
                                              UserModel localUserModel,
                                              UserModel targetUserModel,
                                              StreamModel targetStreamModel,
                                              OnOptionIdsGetListener listener) {
        sExecutor.execute(() -> {
            List<Integer> usersOptionIds = getUsersOptionIds(roomModel, localUserModel, targetUserModel, targetStreamModel);
            if(listener != null){
                listener.runInBackground(usersOptionIds);
            }
        });
    }

    public static List<Integer> getUsersOptionIds(RoomModel roomModel,
                                                  UserModel localUserModel,
                                                  UserModel targetUserModel,
                                                  StreamModel targetStreamModel) {
        if(roomModel == null || localUserModel == null || targetUserModel == null || targetStreamModel == null){
            return new ArrayList<>();
        }
        long startTime = System.currentTimeMillis();

        List<Integer> optionIdList = new ArrayList<>();
        boolean targetIsLocal = targetUserModel.isLocal();
        boolean localIsHost = localUserModel.isHost();
        boolean targetIsHost = targetUserModel.isHost();

        // 静音/取消静音
        if (!targetIsLocal && localIsHost) {
            if (targetStreamModel.hasAudio()) {
                optionIdList.add(R.string.more_mute_audio);
            }
        }


        // 打开视频/关闭视频
        if (!targetIsLocal && localIsHost) {
            if (targetStreamModel.hasVideo()) {
                optionIdList.add(R.string.more_close_video);
            }
        }

        // 申请成为主持人/放弃主持人/设为主持人
        if (targetIsLocal) {
            if (targetIsHost) {
                // 放弃主持人
                optionIdList.add(R.string.more_renounce_admin);
            } else if (!roomModel.hasHost()) {
                // 申请成为主持人
                optionIdList.add(R.string.more_become_admin);
            }
        } else if (localIsHost && !targetIsHost) {
            // 设为主持人
            optionIdList.add(R.string.more_set_host);

        }

        // 移出房间
        if (!targetIsLocal && localIsHost) {
            optionIdList.add(R.string.more_move_out);
        }

        Logger.d("UserOptionsList optionIds=" + optionIdList + ", time(ms)=" + (System.currentTimeMillis() - startTime));

        return optionIdList;
    }


    public static void handleOnClickEvent(Integer optionId,
                                          UserModel localUserModel,
                                          UserModel targetUserModel,
                                          StreamModel targetStreamModel) {
        if (optionId == R.string.more_mute_audio) {
            targetStreamModel.setAudioEnable(false);
        } else if (optionId == R.string.more_close_video) {
            targetStreamModel.setVideoEnable(false);
        } else if (optionId == R.string.more_renounce_admin) {
            targetUserModel.giveUpHost();
        } else if (optionId == R.string.more_become_admin) {
            targetUserModel.applyToBeHost();
        } else if (optionId == R.string.more_set_host) {
            localUserModel.setAsHost(targetUserModel.getUserId());
        } else if (optionId == R.string.more_move_out) {
            targetUserModel.kickOut();
        }
    }

    public interface OnOptionIdsGetListener {
        void runInBackground(List<Integer> optionIds);
    }
}
