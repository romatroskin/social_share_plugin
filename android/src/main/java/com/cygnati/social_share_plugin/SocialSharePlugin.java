package com.cygnati.social_share_plugin;

import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;

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
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** SocialSharePlugin */
public class SocialSharePlugin implements MethodCallHandler {
  private final static String INSTAGRAM_PACKAGE_NAME = "com.instagram.android" ;
  private final static String FACEBOOK_PACKAGE_NAME = "com.facebook.katana";
  private final Registrar registrar;

  private SocialSharePlugin(Registrar registrar){
    this.registrar = registrar;
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "social_share_plugin");
    channel.setMethodCallHandler(new SocialSharePlugin(registrar));
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
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
    shareDialog.show(content);
  }
}
