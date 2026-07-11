# Flutter's own engine/plugin embedding classes are kept via the Flutter
# Gradle plugin's bundled consumer rules — this file only covers the extra
# plugins in this app that are known to need explicit keeps under R8.

# Firebase (Core, Messaging) — reflection-based service discovery.
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# WorkManager — background fire-check task runs across process restarts;
# ListenableWorker subclasses are looked up by (string) class name.
-keep class androidx.work.** { *; }
-keep class * extends androidx.work.ListenableWorker { *; }
-dontwarn androidx.work.**

# flutter_local_notifications — receivers/services referenced from the
# manifest by name and (de)serializes notification data via Gson.
-keep class com.dexterous.** { *; }
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Geolocator / permission_handler plugin embeddings.
-keep class com.baseflow.** { *; }
-dontwarn com.baseflow.**
