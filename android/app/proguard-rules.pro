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

# Keep Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep Chameleon Ultra specific classes
-keep class com.ddcash.enhanced_chameleon_ultra_gui.** { *; }

# Keep USB and serial communication classes
-keep class android.hardware.usb.** { *; }
-keep class com.ftdi.** { *; }
-keep class ch.** { *; }
-keep class com.prolific.** { *; }

# Keep NFC related classes
-keep class android.nfc.** { *; }
-keep class android.hardware.nfc.** { *; }

# Keep Bluetooth classes
-keep class android.bluetooth.** { *; }

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# Keep annotations
-keepattributes *Annotation*

# Keep generic signatures
-keepattributes Signature

# Keep exception information
-keepattributes Exceptions