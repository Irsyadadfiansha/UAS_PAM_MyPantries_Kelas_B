# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Gson TypeToken
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# Play Core library
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Deferred components
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
