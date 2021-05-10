package io.agora.meeting.ui.util;

import android.content.Context;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.text.InputFilter;
import android.text.Spanned;
import android.widget.EditText;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;

import java.util.Arrays;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * author: xcz
 * since:  1/18/21
 **/
public class StringUtil {

    // 默认
    public static final Locale LOCALE_DEFAULT = null;
    // 中文
    public static final Locale LOCALE_ZH = new Locale("zh");
    // 英文
    public static final Locale LOCALE_EN = new Locale("en");

    /**
     * 获取相应语言的资源数据
     */
    public static Resources getLocalResource(@NonNull Context context, @Nullable Locale locale) {
        Configuration config = new Configuration();
        config.setLocale(locale);
        Context configurationContext = context.createConfigurationContext(config);
        configurationContext.getResources();
        return configurationContext.getResources();
    }

    /**
     * 解析出第一个%s位置的值
     */
    public static String parseString(@NonNull Resources resources,
                                     @StringRes int stringId,
                                     String text) {
        String regex = resources.getString(stringId, "(.*?)\\n");
        Matcher matcher = Pattern.compile(regex).matcher(text + "\\n");
        if (matcher.find() && matcher.groupCount() >= 1) {
            return matcher.group(1);
        }
        return "";
    }

    /**
     * 过滤表情输入
     */
    public static void filterEtEmoji(EditText editText){
        InputFilter emojiFilter= new InputFilter() {
            final Pattern emoji = Pattern.compile(
                    "[^\\u0000-\\uFFFF]"
                    + "|[\ud83c\udc00-\ud83c\udfff]|[\ud83d\udc00-\ud83d\udfff]|[\ud83e\udd00-\ud83e\uddff]"
                    // 参考 https://en.wikipedia.org/wiki/Emoji
                    + "|[\uF000-\uFADF]"
                    + "|[\u2B1B-\u2B1C]|[\u2B05-\u2B07]|[\u2934-\u2935]"
                    + "|[\u2795-\u2797]|[\u2763-\u2764]|[\u2753-\u2755]|[\u2733-\u2734]"
                    + "|[\u2708-\u270D]|[\u26F0-\u26F5]|[\u26F7-\u26FA]|[\u26E9-\u26EA]"
                    + "|[\u26D3-\u26D4]|[\u26C4-\u26C5]|[\u26CE-\u26CF]|[\u26B0-\u26B1]"
                    + "|[\u26A0-\u26A1]|[\u26AA-\u26AB]|[\u2692-\u2697]|[\u269B-\u269C]"
                    + "|[\u267E-\u267F]|[\u2665-\u2666]|[\u2650-\u2653]|[\u2648-\u264F]"
                    + "|[\u2638-\u263A]|[\u2622-\u2623]|[\u262E-\u262F]|[\u2614-\u2615]"
                    + "|[\u2600-\u2604]|[\u25FB-\u25FE]|[\u25AA-\u25AB]|[\u23F0-\u23F3]"
                    + "|[\u23F8-\u23FA]|[\u23E9-\u23EF]|[\u2194-\u2199]"
                    + "|[\u3297]|[\u3299]|[\u3030]|[\u2B50]|[\u2B55]|[\u27B0]|[\u27A1]"
                    + "|[\u2757]|[\u2744]|[\u2747]|[\u274C]|[\u274E]|[\u2721]|[\u2728]"
                    + "|[\u2712]|[\u2714]|[\u2716]|[\u2702]|[\u2705]|[\u270F]|[\u26FD]"
                    + "|[\u26D1]|[\u26C8]|[\u26A7]|[\u2699]|[\u267B]|[\u2660]|[\u2663]"
                    + "|[\u2668]|[\u265F]|[\u2640]|[\u2642]|[\u2620]|[\u2626]|[\u262A]"
                    + "|[\u2611]|[\u2618]|[\u261D]|[\u260E]|[\u25C0]|[\u25B6]|[\u24C2]"
                    + "|[\u23EF]|[\u2328]|[\u2139]|[\u2122]|[\u2049]|[\u203C]|[\u00A9]"
                    + "|[\u00AE]"
            );

            @Override
            public CharSequence filter(CharSequence source, int start, int end, Spanned dest, int dstart, int dend) {
                Matcher emojiMatcher = emoji.matcher(source);
                //Logger.d("filterEtEmoji source="+source);
                if (emojiMatcher.find()) {
                    return "";
                }
                return null;
            }
        };
        int length = editText.getFilters().length;
        InputFilter[] filters = Arrays.copyOf(editText.getFilters(), length + 1);
        filters[length] = emojiFilter;
        editText.setFilters(filters);
    }

    public static void filterEtLength(EditText editText, int maxLength, Runnable overRun){
        InputFilter lengthFilter = (source, start, end, dest, dstart, dend) -> {
            int keep = maxLength - (dest.length() - (dend - dstart));
            if (keep <= 0) {
                if(overRun != null) overRun.run();
                return "";
            } else if (keep >= end - start) {
                return null; // keep original
            } else {
                keep += start;
                if (Character.isHighSurrogate(source.charAt(keep - 1))) {
                    --keep;
                    if (keep == start) {
                        return "";
                    }
                }
                return source.subSequence(start, keep);
            }
        };
        int length = editText.getFilters().length;
        InputFilter[] filters = Arrays.copyOf(editText.getFilters(), length + 1);
        filters[length] = lengthFilter;
        editText.setFilters(filters);
    }

    public static boolean haveContentsChanged(CharSequence str1, CharSequence str2) {
        if ((str1 == null) != (str2 == null)) {
            return true;
        } else if (str1 == null) {
            return false;
        }
        final int length = str1.length();
        if (length != str2.length()) {
            return true;
        }
        for (int i = 0; i < length; i++) {
            if (str1.charAt(i) != str2.charAt(i)) {
                return true;
            }
        }
        return false;
    }


    /**
     * 版本号比较
     *
     */
    public static int compareVersion(String version1, String version2) {
        if (version1.equals(version2)) {
            return 0;
        }
        String[] version1Array = version1.split("\\.");
        String[] version2Array = version2.split("\\.");
        int index = 0;
        // 获取最小长度值
        int minLen = Math.min(version1Array.length, version2Array.length);
        int diff = 0;
        // 循环判断每位的大小
        while (index < minLen
                && (diff = Integer.parseInt(version1Array[index])
                - Integer.parseInt(version2Array[index])) == 0) {
            index++;
        }
        if (diff == 0) {
            // 如果位数不一致，比较多余位数
            for (int i = index; i < version1Array.length; i++) {
                if (Integer.parseInt(version1Array[i]) > 0) {
                    return 1;
                }
            }

            for (int i = index; i < version2Array.length; i++) {
                if (Integer.parseInt(version2Array[i]) > 0) {
                    return -1;
                }
            }
            return 0;
        } else {
            return diff > 0 ? 1 : -1;
        }
    }

}
