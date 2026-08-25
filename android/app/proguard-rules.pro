# ---- Flutter / Dart ----
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# ---- Drift / SQLite ----
-keep class drift.** { *; }
-keep class ** extends drift.Database { *; }
-keep class ** extends drift.QueryExecutor { *; }
-keep class org.sqlite.** { *; }
-keep class org.greenrobot.eventbus.** { *; }
-keep class com.squareup.sqldelight.** { *; }

# ---- Provider ----
-keep class provider.** { *; }

# ---- Method / Event channels (native ↔ Flutter) ----
-keep class io.flutter.plugin.common.** { *; }
-keep class tz.mapato.mapato.** { *; }

# ---- Prevent stripping of the API key provider ----
-keep class tz.mapato.mapato.KeyProvider { *; }

# ---- Play Core (split APK / deferred components) — not used but referenced by Flutter engine ----
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
