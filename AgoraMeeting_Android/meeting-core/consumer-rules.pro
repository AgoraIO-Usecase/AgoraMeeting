
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

-keepclasseswithmembernames class * {
    native <methods>;
}

-keep class io.agora.rtc.** {*;}
-keep class io.agora.rtm.** {*;}
-keep class io.agora.rte.** {*;}
-keep class io.agora.common.**{*;}
#statistic
-keep class io.agora.scene.statistic.** {*;}