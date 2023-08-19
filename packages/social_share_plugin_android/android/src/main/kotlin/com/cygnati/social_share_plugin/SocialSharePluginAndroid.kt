package com.cygnati.social_share_plugin

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.util.Log
import androidx.core.content.FileProvider
import com.facebook.CallbackManager
import com.facebook.FacebookCallback
import com.facebook.FacebookException
import com.facebook.share.Sharer
import com.facebook.share.model.ShareLinkContent
import com.facebook.share.model.SharePhoto
import com.facebook.share.model.SharePhotoContent
import com.facebook.share.widget.ShareDialog
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import java.io.File

/**
 * SocialSharePluginAndroid
 */
class SocialSharePluginAndroid : FlutterPlugin, ActivityAware, MethodCallHandler,
  ActivityResultListener {
  private var activity: Activity? = null
  private var channel: MethodChannel? = null
  private val callbackManager: CallbackManager = CallbackManager.Factory.create()
  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    channel = MethodChannel(binding.binaryMessenger, "social_share_plugin_android")
    channel!!.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
  }
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    binding.addActivityResultListener(this)
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
//    binding.removeActivityResultListener(this)
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    binding.addActivityResultListener(this)
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
//    binding.removeActivityResultListener(this)
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    if (requestCode == TWITTER_REQUEST_CODE) {
      if (resultCode == Activity.RESULT_OK) {
        Log.d("SocialSharePlugin", "Twitter share done.")
        channel!!.invokeMethod("onSuccess", null)
      } else if (resultCode == Activity.RESULT_CANCELED) {
        Log.d("SocialSharePlugin", "Twitter cancelled.")
        channel!!.invokeMethod("onCancel", null)
      }
      return true
    }
    if (requestCode == INSTAGRAM_REQUEST_CODE) {
      if (resultCode == Activity.RESULT_OK) {
        Log.d("SocialSharePlugin", "Instagram share done.")
        channel!!.invokeMethod("onSuccess", null)
      } else {
        Log.d("SocialSharePlugin", "Instagram share failed.")
        channel!!.invokeMethod("onCancel", null)
      }
      return true
    }
    return callbackManager.onActivityResult(requestCode, resultCode, data)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    val pm = activity!!.packageManager
    when (call.method) {
      "getPlatformName" -> result.success("Android")
      "shareToFeedInstagram" -> try {
        //// Recently i've noticed that instagram not discovered for any reason,
        //// looks like it works without checking anyway.
        pm.getPackageInfo(INSTAGRAM_PACKAGE_NAME, PackageManager.GET_ACTIVITIES)
        instagramShare(call.argument("type"), call.argument("path"))
        result.success(true)
      } catch (e: PackageManager.NameNotFoundException) {
        openPlayStore(INSTAGRAM_PACKAGE_NAME)
        result.success(false)
      }
      "shareToFeedFacebook" -> try {
        pm.getPackageInfo(FACEBOOK_PACKAGE_NAME, PackageManager.GET_ACTIVITIES)
        facebookShare(call.argument("caption"), call.argument("path"))
        result.success(true)
      } catch (e: PackageManager.NameNotFoundException) {
        openPlayStore(FACEBOOK_PACKAGE_NAME)
        result.success(false)
      }
      "shareToFeedFacebookLink" -> try {
        pm.getPackageInfo(FACEBOOK_PACKAGE_NAME, PackageManager.GET_ACTIVITIES)
        facebookShareLink(call.argument("quote"), call.argument("url"))
        result.success(true)
      } catch (e: PackageManager.NameNotFoundException) {
        openPlayStore(FACEBOOK_PACKAGE_NAME)
        result.success(false)
      }
      "shareToTwitterLink" -> try {
        pm.getPackageInfo(TWITTER_PACKAGE_NAME, PackageManager.GET_ACTIVITIES)
        twitterShareLink(call.argument("text"), call.argument("url"))
        result.success(true)
      } catch (e: PackageManager.NameNotFoundException) {
        openPlayStore(TWITTER_PACKAGE_NAME)
        result.success(false)
      }
      else -> result.notImplemented()
    }
  }

  private fun openPlayStore(packageName: String) {
    try {
      val playStoreUri = Uri.parse("market://details?id=$packageName")
      val intent = Intent(Intent.ACTION_VIEW, playStoreUri)
      activity!!.startActivity(intent)
    } catch (e: ActivityNotFoundException) {
      val playStoreUri = Uri.parse("https://play.google.com/store/apps/details?id=$packageName")
      val intent = Intent(Intent.ACTION_VIEW, playStoreUri)
      activity!!.startActivity(intent)
    }
  }

  private fun instagramShare(type: String?, imagePath: String?) {
    val image = File(imagePath!!)
    val uri = FileProvider.getUriForFile(
      activity!!, activity!!.packageName + ".social.share.fileprovider",
      image
    )
    val share = Intent(Intent.ACTION_SEND)
    share.type = type
    share.putExtra(Intent.EXTRA_STREAM, uri)
    share.setPackage(INSTAGRAM_PACKAGE_NAME)
    share.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
    val chooser = Intent.createChooser(share, "Share to")
    val resInfoList = activity!!.packageManager.queryIntentActivities(
      chooser,
      PackageManager.MATCH_DEFAULT_ONLY
    )
    for (resolveInfo in resInfoList) {
      val packageName = resolveInfo.activityInfo.packageName
      activity!!.grantUriPermission(packageName, uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
    }
    activity!!.startActivityForResult(chooser, INSTAGRAM_REQUEST_CODE)
  }

  private fun facebookShare(caption: String?, mediaPath: String?) {
    val media = File(mediaPath!!)
    val uri = FileProvider.getUriForFile(
      activity!!, activity!!.packageName + ".social.share.fileprovider",
      media
    )
    val photo: SharePhoto = SharePhoto.Builder().setImageUrl(uri).setCaption(caption).build()
    val content: SharePhotoContent = SharePhotoContent.Builder().addPhoto(photo).build()
    val shareDialog = ShareDialog(activity!!)
    shareDialog.registerCallback(callbackManager, object : FacebookCallback<Sharer.Result> {
      override fun onSuccess(result: Sharer.Result) {
        channel!!.invokeMethod("onSuccess", null)
        Log.d("SocialSharePlugin", "Sharing successfully done.")
      }

      override fun onCancel() {
        channel!!.invokeMethod("onCancel", null)
        Log.d("SocialSharePlugin", "Sharing cancelled.")
      }

      override fun onError(error: FacebookException) {
        channel!!.invokeMethod("onError", error.message)
        Log.d("SocialSharePlugin", "Sharing error occurred.")
      }
    })
    if (ShareDialog.canShow(SharePhotoContent::class.java)) {
      shareDialog.show(content)
    }
  }

  private fun facebookShareLink(quote: String?, url: String?) {
    val uri = Uri.parse(url)
    val content: ShareLinkContent = ShareLinkContent.Builder().setContentUrl(uri).setQuote(quote).build()
    val shareDialog = ShareDialog(activity!!)
    shareDialog.registerCallback(callbackManager, object : FacebookCallback<Sharer.Result> {
      override fun onSuccess(result: Sharer.Result) {
        channel!!.invokeMethod("onSuccess", null)
        Log.d("SocialSharePlugin", "Sharing successfully done.")
      }

      override fun onCancel() {
        channel!!.invokeMethod("onCancel", null)
        Log.d("SocialSharePlugin", "Sharing cancelled.")
      }

      override fun onError(error: FacebookException) {
        channel!!.invokeMethod("onError", error.message)
        Log.d("SocialSharePlugin", "Sharing error occurred.")
      }
    })
    if (ShareDialog.canShow(ShareLinkContent::class.java)) {
      shareDialog.show(content)
    }
  }

  private fun twitterShareLink(text: String?, url: String?) {
    val tweetUrl = String.format("https://twitter.com/intent/tweet?text=%s&url=%s", text, url)
    val uri = Uri.parse(tweetUrl)
    activity!!.startActivityForResult(Intent(Intent.ACTION_VIEW, uri), TWITTER_REQUEST_CODE)
  }

  companion object {
    private const val INSTAGRAM_PACKAGE_NAME = "com.instagram.android"
    private const val FACEBOOK_PACKAGE_NAME = "com.facebook.katana"
    private const val TWITTER_PACKAGE_NAME = "com.twitter.android"
    private const val TWITTER_REQUEST_CODE = 0xc0ce
    private const val INSTAGRAM_REQUEST_CODE = 0xc0c3
  }
}
