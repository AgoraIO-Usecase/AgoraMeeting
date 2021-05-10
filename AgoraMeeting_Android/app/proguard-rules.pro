
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-dontskipnonpubliclibraryclassmembers
-dontpreverify

-keepclasseswithmembernames class * {
    native <methods>;
}

#meeting-core
-keep class io.agora.meeting.core.**{*;}
#meeting-ui
-keep class io.agora.meeting.ui.**{*;}
