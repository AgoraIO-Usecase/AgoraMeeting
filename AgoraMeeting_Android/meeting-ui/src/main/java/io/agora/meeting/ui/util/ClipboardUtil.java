package io.agora.meeting.ui.util;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import io.agora.meeting.core.log.Logger;

/**
 *
 * 粘贴板工具
 *
 * author: xcz
 * since:  1/18/21
 **/
public class ClipboardUtil {

    /**
     * 复制到粘贴板
     */
    public static void copy2Clipboard(@NonNull Context context, String content){
        if(TextUtils.isEmpty(content)){
            return;
        }
        ClipboardManager manager = (ClipboardManager) context.getSystemService(Context.CLIPBOARD_SERVICE);
        manager.setPrimaryClip(ClipData.newPlainText(null, content));
    }

    /**
     * 从粘贴板读取指定格式的数据
     */
    public static String readFromClipboard(@NonNull Context context, String regex){
        ClipboardManager manager = (ClipboardManager) context.getSystemService(Context.CLIPBOARD_SERVICE);
        String ret = "";
        try {
            ClipData primaryClip = manager.getPrimaryClip();
            if(primaryClip != null){
                Pattern pattern = null;
                if(!TextUtils.isEmpty(regex)){
                    pattern = Pattern.compile(regex);
                }
                for (int i = 0; i < primaryClip.getItemCount(); i++) {
                    ClipData.Item item = primaryClip.getItemAt(i);
                    CharSequence text = item.getText();
                    if(pattern != null){
                        Matcher matcher = pattern.matcher(text);
                        if(matcher.find()){
                            ret = text.toString();
                            break;
                        }
                    }else if(!TextUtils.isEmpty(text)){
                        ret = text.toString();
                        break;
                    }
                }
                manager.setPrimaryClip(primaryClip);
            }
        } catch (Exception exception) {
            Logger.e(exception.toString());
        }
        return ret;
    }

}
