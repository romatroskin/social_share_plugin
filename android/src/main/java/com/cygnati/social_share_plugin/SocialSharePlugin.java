package com.cygnati.social_share_plugin;

import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.util.Log;

import androidx.annotation.NonNull;

import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.share.Sharer;
import com.facebook.share.model.ShareLinkContent;
import com.facebook.share.model.ShareMediaContent;
import com.facebook.share.model.SharePhoto;
import com.facebook.share.model.SharePhotoContent;
import com.facebook.share.widget.ShareDialog;

import java.io.File;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * SocialSharePlugin
 */
public class SocialSharePlugin implements MethodCallHandler, PluginRegistry.ActivityResultListener {
    private final static String INSTAGRAM_PACKAGE_NAME = "com.instagram.android";
    private final static String FACEBOOK_PACKAGE_NAME = "com.facebook.katana";

    private final Registrar registrar;
    private final MethodChannel channel;
    private final CallbackManager callbackManager;

    private SocialSharePlugin(final Registrar registrar, final MethodChannel channel) {
        this.channel = channel;
        this.registrar = registrar;
        this.callbackManager = CallbackManager.Factory.create();
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "social_share_plugin");
        final SocialSharePlugin plugin = new SocialSharePlugin(registrar, channel);
        registrar.addActivityResultListener(plugin);
        channel.setMethodCallHandler(plugin);
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        Log.d("SocialSharePlugin", "onActivityResult");
        return callbackManager.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        final PackageManager pm = registrar.activeContext().getPackageManager();
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("shareToFeedInstagram")) {
            try {
                pm.getPackageInfo(INSTAGRAM_PACKAGE_NAME, PackageManager.GET_ACTIVITIES);
                instagramShare(call.<String>argument("type"), call.<String>argument("path"));
            } catch (PackageManager.NameNotFoundException e) {
                openPlayStore(INSTAGRAM_PACKAGE_NAME);
            }

            result.success(null);
        } else if (call.method.equals("shareToFeedFacebook")) {
            try {
                pm.getPackageInfo(FACEBOOK_PACKAGE_NAME, PackageManager.GET_ACTIVITIES);
                facebookShare(call.<String>argument("caption"), call.<String>argument("path"));
            } catch (PackageManager.NameNotFoundException e) {
                openPlayStore(FACEBOOK_PACKAGE_NAME);
            }

            result.success(null);
        } else if (call.method.equals("shareToFeedFacebookLink")) {
            try {
                pm.getPackageInfo(FACEBOOK_PACKAGE_NAME, PackageManager.GET_ACTIVITIES);
                facebookShareLink(call.<String>argument("quote"), call.<String>argument("url"));
                result.success(true);
            } catch (PackageManager.NameNotFoundException e) {
                openPlayStore(FACEBOOK_PACKAGE_NAME);
                result.success(false);
            }
        } else {
            result.notImplemented();
        }
    }

    private void openPlayStore(String packageName) {
        final Context context = registrar.activeContext();
        try {
            final Uri playStoreUri = Uri.parse("market://details?id=" + packageName);
            final Intent intent = new Intent(Intent.ACTION_VIEW, playStoreUri);
            context.startActivity(intent);
        } catch (ActivityNotFoundException e) {
            final Uri playStoreUri = Uri.parse("https://play.google.com/store/apps/details?id=" + packageName);
            final Intent intent = new Intent(Intent.ACTION_VIEW, playStoreUri);
            context.startActivity(intent);
        }
    }

    private void instagramShare(String type, String imagePath) {
        final Context context = registrar.activeContext();
        final File image = new File(imagePath);
        final Uri uri = Uri.fromFile(image);
        final Intent share = new Intent(Intent.ACTION_SEND);
        share.setType(type);
        share.putExtra(Intent.EXTRA_STREAM, uri);
        share.setPackage(INSTAGRAM_PACKAGE_NAME);
        context.startActivity(Intent.createChooser(share, "Share to"));
    }

    private void facebookShare(String caption, String mediaPath) {
        final File media = new File(mediaPath);
        final Uri uri = Uri.fromFile(media);
        final SharePhoto photo = new SharePhoto.Builder().setImageUrl(uri).setCaption(caption).build();
        final SharePhotoContent content = new SharePhotoContent.Builder().addPhoto(photo).build();
        final ShareDialog shareDialog = new ShareDialog(registrar.activity());
        if (ShareDialog.canShow(SharePhotoContent.class)) {
            shareDialog.show(content);
        }
    }

    private void facebookShareLink(String quote, String url) {
        final Uri uri = Uri.parse(url);
        final ShareLinkContent content = new ShareLinkContent.Builder()
                .setContentUrl(uri)
                .setQuote(quote)
                .build();
        final ShareDialog shareDialog = new ShareDialog(registrar.activity());
        shareDialog.registerCallback(callbackManager, new FacebookCallback<Sharer.Result>() {
            @Override
            public void onSuccess(Sharer.Result result) {
                channel.invokeMethod("onSuccess", result.getPostId());
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
}
