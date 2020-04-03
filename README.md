# social_share_plugin

[![Pub](https://img.shields.io/pub/v/social_share_plugin.svg?color=blue)](https://pub.dartlang.org/packages/social_share_plugin)

Social Share to Facebook and Instagram Flutter plugin.

## Getting Started

To get things up and running, you'll have to declare a pubspec dependency in your Flutter project.
Also some minimal Android & iOS specific configuration must be done, otherise your app will crash.

### On your Flutter project

See the [installation instructions on pub](https://pub.dartlang.org/packages/social_share_plugin#-installing-tab-).

### Android

In addition, you need to do the following:
- Get a [Facebook App ID](https://developers.facebook.com/apps) properly configured and linked to your Android app. See [Android Getting Started](https://developers.facebook.com/docs/android/getting-started#app_id), Add Facebook App ID.
- Generate an [Android Key Hash](https://developers.facebook.com/docs/android/getting-started#create_hash) and add it to your [developer profile](https://developers.facebook.com/settings/developer/contact/)
- Add a _Facebook Activity_ and include it in your _AndroidManifest.xml_

For details on these requirements, see [Android - Getting Started](https://developers.facebook.com/docs/android/getting-started).

After you've done that, find out what your _Facebook App ID_ is. You can find your Facebook App ID in your Facebook App's dashboard in the Facebook developer console.

Once you have the Facebook App ID figured out, you'll have to do two things.

First, copy-paste the following to your strings resource file. If you don't have one, just create it.

**\<your project root\>/android/app/src/main/res/values/strings.xml**

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Your App Name here.</string>

    <!-- Replace "000000000000" with your Facebook App ID here. -->
    <string name="facebook_app_id">000000000000</string>
</resources>
```

Then you'll just have to copy-paste the following to your _Android Manifest_ and replace 000000000000000 with your Facebook App ID and you also need to set up a _ContentProvider_ in your _AndroidManifest.xml_ where {APP_ID} is your app ID:

**\<your project root\>/android/app/src/main/AndroidManifest.xml**

```xml
<meta-data android:name="com.facebook.sdk.ApplicationId"
    android:value="@string/facebook_app_id"/>

<meta-data android:name="com.facebook.sdk.ApplicationName"
            android:value="@string/app_name"/>

<activity android:name="com.facebook.FacebookActivity"
    android:configChanges=
            "keyboard|keyboardHidden|screenLayout|screenSize|orientation"
    android:label="@string/app_name" />
    
<provider android:authorities="com.facebook.app.FacebookContentProvider{FACEBOOK_APP_ID}"
            android:name="com.facebook.FacebookContentProvider"
            android:exported="true"/>

<provider android:name="androidx.core.content.FileProvider"
            android:authorities="{APP_PACKAGE}.social.share.fileprovider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/provider_paths"/>
        </provider>
```

Done!

### iOS

Before you add sharing to your app you need to:
- Add the [Facebook SDK for iOS](https://developers.facebook.com/docs/ios) to your mobile development environment
- Configure and link your [Facebook app ID](https://developers.facebook.com/apps)
- Add your app ID, display name, and human-readable reason for photo access to your app's .plist file.

After you've done that, find out what your _Facebook App ID_ is. You can find your Facebook App ID in your Facebook App's dashboard in the Facebook developer console.

Once you have the Facebook App ID figured out, then you'll just have to copy-paste the following to your _Info.plist_ file, before the ending `</dict></plist>` tags.

**\<your project root\>/ios/Runner/Info.plist**

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <!--
              Replace "000000000000" with your Facebook App ID here.
              **NOTE**: The scheme needs to start with `fb` and then your ID.
            -->
            <string>fb000000000000</string>
        </array>
    </dict>
</array>

<key>FacebookAppID</key>

<!-- Replace "000000000000" with your Facebook App ID here. -->
<string>000000000000</string>
<key>FacebookDisplayName</key>

<!-- Replace "YOUR_APP_NAME" with your Facebook App name. -->
<string>YOUR_APP_NAME</string>

<key>LSApplicationQueriesSchemes</key>
<array>
    <string>instagram</string>
    <string>fbapi</string>
    <string>fb-messenger-share-api</string>
    <string>fbauth2</string>
    <string>fbshareextension</string>
    <string>twitter</string>
</array>
```

Done!

## How do I use it?

### Instagram
```dart
import 'package:social_share_plugin/social_share_plugin.dart';

File file = await ImagePicker.pickImage(source: ImageSource.gallery);
await SocialSharePlugin.shareToFeedInstagram(path: file.path);
```

### Facebook
```dart
import 'package:social_share_plugin/social_share_plugin.dart';

File file = await ImagePicker.pickImage(source: ImageSource.gallery);
await SocialSharePlugin.shareToFeedFacebook(path: file.path);

await SocialSharePlugin.shareToFeedFacebookLink(quote: 'quote', url: 'https://flutter.dev');
```

### Twitter
```dart
import 'package:social_share_plugin/social_share_plugin.dart';

await SocialSharePlugin.shareToTwitterLink(text: 'text', url: 'https://flutter.dev');
```

That's it.