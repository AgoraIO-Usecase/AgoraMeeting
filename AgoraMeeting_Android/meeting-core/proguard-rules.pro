# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

-keeppackagenames

-keepattributes *Annotation*
-keep class io.agora.meeting.core.annotaion.Keep
-keep @io.agora.meeting.core.annotaion.Keep class * {*;}
-keepclasseswithmembers class * {
    @io.agora.meeting.core.annotaion.Keep <methods>;
}
-keepclasseswithmembers class * {
    @io.agora.meeting.core.annotaion.Keep <fields>;
}
-keepclasseswithmembers class * {
    @io.agora.meeting.core.annotaion.Keep <init>(...);
}

-keep class io.agora.meeting.core.MeetingEngine{*;}
-keep class io.agora.meeting.core.MeetingConfig{*;}

-keepclasseswithmembernames class * {
    native <methods>;
}

-keep class io.agora.rtc.** {*;}
-keep class io.agora.rtm.** {*;}
-keep class io.agora.rte.** {*;}
-keep class io.agora.common.**{*;}
#statistic
-keep class io.agora.scene.statistic.** {*;}