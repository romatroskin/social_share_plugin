package com.cygnati.social_share_plugin;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.content.FileProvider;

import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.share.Sharer;
import com.facebook.share.model.ShareLinkContent;
import com.facebook.share.model.SharePhoto;
import com.facebook.share.model.SharePhotoContent;
import com.facebook.share.widget.ShareDialog;

import java.io.File;
import java.util.List;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import static android.app.Activity.RESULT_CANCELED;
import static android.app.Activity.RESULT_OK;

/**
 * SocialSharePlugin
 */
public class SocialSharePlugin
        implements FlutterPlugin, ActivityAware, MethodCallHandler, PluginRegistry.ActivityResultListener {
    private final static String INSTAGRAM_PACKAGE_NAME = "com.instagram.android";
    private final static String FACEBOOK_PACKAGE_NAME = "com.facebook.katana";
    private final static String TWITTER_PACKAGE_NAME = "com.twitter.android";

    private final static int TWITTER_REQUEST_CODE = 0xc0ce;
    private final static int INSTAGRAM_REQUEST_CODE = 0xc0c3;

    private Activity activity;
    private MethodChannel channel;
    private final CallbackManager callbackManager;

    public SocialSharePlugin() {
        this.callbackManager = CallbackManager.Factory.create();
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        this.channel = new MethodChannel(binding.getBinaryMessenger(), "social_share_plugin");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        binding.addActivityResultListener(this);
        this.activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        binding.removeActivityResultListener(this);
        binding.addActivityResultListener(this);
    }

    @Override
    public void onDetachedFromActivity() {
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "social_share_plugin");
        final SocialSharePlugin plugin = new SocialSharePlugin();
        plugin.channel = channel;
        plugin.activity = registrar.activity();
        channel.setMethodCallHandler(plugin);
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == TWITTER_REQUEST_CODE) {
            if (resultCode == RESULT_OK) {
                Log.d("SocialSharePlugin", "Twitter share done.");
                channel.invokeMethod("onSuccess", null);
            } else if (resultCode == RESULT_CANCELED) {
                Log.d("SocialSharePlugin", "Twitter cancelled.");
                channel.invokeMethod("onCancel", null);

            }

            return true;
        }

        if (requestCode == INSTAGRAM_REQUEST_CODE) {
            if (resultCode == RESULT_OK) {
                Log.d("SocialSharePlugin", "Instagram share done.");
                channel.invokeMethod("onSuccess", null);
            } else {
                Log.d("SocialSharePlugin", "Instagram share failed.");
                channel.invokeMethod("onCancel", null);
            }

            return true;
        }

        return callbackManager.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        final PackageManager pm = activity.getPackageManager();
        switch (call.method) {
            case "getPlatformVersion":
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;
            case "shareToFeedInstagram":
                try {
                    pm.getPackageInfo(INSTAGRAM_PACKAGE_NAME, PackageManager.GET_ACTIVITIES);
                    instagramShare(call.<String>argument("type"), call.<String>argument("path"));
                    result.success(true);
                } catch (PackageManager.NameNotFoundException e) {
                    openPlayStore(INSTAGRAM_PACKAGE_NAME);
                    result.success(false);
                }
                break;
            case "shareToFeedFacebook":
                try {
                    pm.getPackageInfo(FACEBOOK_PACKAGE_NAME, PackageManager.GET_ACTIVITIES);
                    facebookShare(call.<String>argument("caption"), call.<String>argument("path"));
                    result.success(true);
                } catch (PackageManager.NameNotFoundException e) {
                    openPlayStore(FACEBOOK_PACKAGE_NAME);
                    result.success(false);
                }
                break;
            case "shareToFeedFacebookLink":
                try {
                    pm.getPackageInfo(FACEBOOK_PACKAGE_NAME, PackageManager.GET_ACTIVITIES);
                    facebookShareLink(call.<String>argument("quote"), call.<String>argument("url"));
                    result.success(true);
                } catch (PackageManager.NameNotFoundException e) {
                    openPlayStore(FACEBOOK_PACKAGE_NAME);
                    result.success(false);
                }
                break;
            case "shareToTwitterLink":
                try {
                    pm.getPackageInfo(TWITTER_PACKAGE_NAME, PackageManager.GET_ACTIVITIES);
                    twitterShareLink(call.<String>argument("text"), call.<String>argument("url"));
                    result.success(true);
                } catch (PackageManager.NameNotFoundException e) {
                    openPlayStore(TWITTER_PACKAGE_NAME);
                    result.success(false);
                }
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void openPlayStore(String packageName) {
        try {
            final Uri playStoreUri = Uri.parse("market://details?id=" + packageName);
            final Intent intent = new Intent(Intent.ACTION_VIEW, playStoreUri);
            activity.startActivity(intent);
        } catch (ActivityNotFoundException e) {
            final Uri playStoreUri = Uri.parse("https://play.google.com/store/apps/details?id=" + packageName);
            final Intent intent = new Intent(Intent.ACTION_VIEW, playStoreUri);
            activity.startActivity(intent);
        }
    }

    private void instagramShare(String type, String imagePath) {
        final File image = new File(imagePath);
        final Uri uri = FileProvider.getUriForFile(activity, activity.getPackageName() + ".social.share.fileprovider",
                image);
        final Intent share = new Intent(Intent.ACTION_SEND);
        share.setType(type);
        share.putExtra(Intent.EXTRA_STREAM, uri);
        share.setPackage(INSTAGRAM_PACKAGE_NAME);
        share.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);

        final Intent chooser = Intent.createChooser(share, "Share to");
        final List<ResolveInfo> resInfoList = activity.getPackageManager().queryIntentActivities(chooser,
                PackageManager.MATCH_DEFAULT_ONLY);

        for (ResolveInfo resolveInfo : resInfoList) {
            final String packageName = resolveInfo.activityInfo.packageName;
            activity.grantUriPermission(packageName, uri, Intent.FLAG_GRANT_READ_URI_PERMISSION);
        }

        activity.startActivityForResult(chooser, INSTAGRAM_REQUEST_CODE);
    }

    private void facebookShare(String caption, String mediaPath) {
        final File media = new File(mediaPath);
        final Uri uri = FileProvider.getUriForFile(activity, activity.getPackageName() + ".social.share.fileprovider",
                media);
        final SharePhoto photo = new SharePhoto.Builder().setImageUrl(uri).setCaption(caption).build();
        final SharePhotoContent content = new SharePhotoContent.Builder().addPhoto(photo).build();
        final ShareDialog shareDialog = new ShareDialog(activity);
        shareDialog.registerCallback(callbackManager, new FacebookCallback<Sharer.Result>() {
            @Override
            public void onSuccess(Sharer.Result result) {
                channel.invokeMethod("onSuccess", null);
                Log.d("SocialSharePlugin", "Sharing successfully done.");
            }

            @Override
            public void onCancel() {
                channel.invokeMethod("onCancel", null);
                Log.d("SocialSharePlugin", "Sharing cancelled.");
            }

            @Override
            public void onError(FacebookException error) {
                channel.invokeMethod("onError", error.getMessage());
                Log.d("SocialSharePlugin", "Sharing error occurred.");
            }
        });

        if (ShareDialog.canShow(SharePhotoContent.class)) {
            shareDialog.show(content);
        }
    }

    private void facebookShareLink(String quote, String url) {
        final Uri uri = Uri.parse(url);
        final ShareLinkContent content = new ShareLinkContent.Builder().setContentUrl(uri).setQuote(quote).build();
        final ShareDialog shareDialog = new ShareDialog(activity);
        shareDialog.registerCallback(callbackManager, new FacebookCallback<Sharer.Result>() {
            @Override
            public void onSuccess(Sharer.Result result) {
                channel.invokeMethod("onSuccess", null);
                Log.d("SocialSharePlugin", "Sharing successfully done.");
            }

            @Override
            public void onCancel() {
                channel.invokeMethod("onCancel", null);
                Log.d("SocialSharePlugin", "Sharing cancelled.");
            }

            @Override
            public void onError(FacebookException error) {
                channel.invokeMethod("onError", error.getMessage());
                Log.d("SocialSharePlugin", "Sharing error occurred.");
            }
        });

        if (ShareDialog.canShow(ShareLinkContent.class)) {
            shareDialog.show(content);
        }
    }

    private void twitterShareLink(String text, String url) {
        final String tweetUrl = String.format("https://twitter.com/intent/tweet?text=%s&url=%s", text, url);
        final Uri uri = Uri.parse(tweetUrl);
        activity.startActivityForResult(new Intent(Intent.ACTION_VIEW, uri), TWITTER_REQUEST_CODE);
    }
}
