# Social Share Flutter Plugin

[![Puff Puff Dev][logo_white]][puff_puff_link_dark]
[![Puff Puff Dev][logo_black]][puff_puff_link_light]

Developed with 💙 by [<img src="https://raw.githubusercontent.com/PuffPuffDev/puff_puff_brand/main/logos/dp_black.svg#gh-light-mode-only&sanitize=true" style="filter: invert(45%) sepia(21%) saturate(3595%) hue-rotate(193deg) brightness(100%) contrast(94%); height: 20px; position: absolute; margin-left: 5px">][puffpuff_link]
<!-- ![logo][dp_white] -->

[![Pub](https://img.shields.io/pub/v/social_share_plugin.svg?color=blue)](https://pub.dartlang.org/packages/social_share_plugin)
![coverage][coverage_badge]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

 Social Share to Facebook and Instagram and Twitter.

## Getting Started

To get things up and running, you'll have to declare a pubspec dependency in your Flutter project.
Also some minimal Android & iOS specific configuration must be done, otherise your app will crash.

### Open or Create your Flutte Project

See the [installation instructions on pub](https://pub.dartlang.org/packages/social_share_plugin#-installing-tab-).

## Android

 In addition, you need to do the following:

- Get a [Facebook App ID](https://developers.facebook.com/apps) properly configured and linked to your Android app. See [Android Getting Started](https://developers.facebook.com/docs/android/getting-started#app_id), Add Facebook App ID.
- Generate an [Android Key Hash](https://developers.facebook.com/docs/android/getting-started#create_hash) and add it to your [developer profile](https://developers.facebook.com/settings/developer/contact/)
- Add a *`FacebookActivity`* and include it in your *`AndroidManifest.xml`*

 For details on these requirements, see [Android - Getting Started](https://developers.facebook.com/docs/android/getting-started).

 After you've done that, find out what your `Facebook App ID` is. You can find your Facebook App ID in your Facebook App's dashboard in the Facebook developer console.

 Once you've got the `Facebook App ID`, you'll have to do couple of preparation moves.

 Add permission to allow package manager query if app is installed, should be added to the manifest root tag

```xml
<uses-permission android:name="android.permission.GET_PACKAGE_SIZE"/>
```

 Add queries as childs of manifest root tag also

 ```xml
<queries>
    <package android:name="com.twitter.android" />
    <package android:name="com.facebook.katana" />
    <package android:name="com.instagram.android" />
</queries>
```

I prefer to pass this ID to manifest throght gradle manifestPlaceholders. You can choose any way you like, just to be sure put the ID in correct places, like in example below. Put all these inside the application tag and your `Facebook App ID` instead of `${facebookAppId}` variable

```xml
<meta-data android:name="com.facebook.sdk.ApplicationId" android:value="${facebookAppId}"/>

<meta-data android:name="com.facebook.sdk.ApplicationName" android:value="${applicationName}"/>

<activity android:name="com.facebook.FacebookActivity" android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation" android:label="${applicationName}" />

<provider android:authorities="com.facebook.app.FacebookContentProvider${facebookAppId}" android:name="com.facebook.FacebookContentProvider" android:exported="true"/>

<provider android:name="androidx.core.content.FileProvider" android:authorities="${applicationId}.social.share.fileprovider" android:grantUriPermissions="true" android:exported="false">
    <meta-data android:name="android.support.FILE_PROVIDER_PATHS" android:resource="@xml/provider_paths"/>
</provider>
 ```

Need to add these variables to string resources as well, i've added them from gradle with resValue.

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Example</string>
    <!-- Replace "000000000000" with your Facebook App ID here. Same to the secret -->
    <string name="facebook_app_id">000000000000</string>
    <string name="facebook_client_token">00000000000000000000000000000000</string>
</resources>
```

And the last one is our provider paths:

> ***\<your project root\>/android/app/src/main/res/xml/provider_paths.xml***

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    
    <cache-path
        name="cache_files"
        path="/"/>
</paths>
```

## iOS

 Before you add sharing to your app you need to:

- Add the [Facebook SDK for iOS](https://developers.facebook.com/docs/ios) to your mobile development environment
- Configure and link your [Facebook app ID](https://developers.facebook.com/apps)
- Add your app ID, display name, and human-readable reason for photo access to your app's .plist file.

 After you've done that, find out what your `Facebook App ID` is. You can find it out in your Facebook App's dashboard in the Facebook developer console.

 Once you've got the ID, then you'll just have to copy-paste the following to your `Info.plist` file, before the ending `</dict></plist>` tags.

 > ***\<your project root\>/ios/Runner/Info.plist***

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

Congratulations! We've just finished setup!!

## How do I use it?

### Instagram

 ```dart
 import 'package:social_share_plugin/social_share_plugin.dart';
 File file = await imagePicker.pickImage(source: ImageSource.gallery);
 await shareToFeedInstagram(path: file.path);
 ```

### Facebook

 ```dart
 import 'package:social_share_plugin/social_share_plugin.dart';
 final file = await imagePicker.pickImage(source: ImageSource.gallery);
 await shareToFeedFacebook(path: file.path);
 await shareToFeedFacebookLink(quote: 'quote', url: 'https://flutter.dev');
 ```

### Twitter

 ```dart
 import 'package:social_share_plugin/social_share_plugin.dart';
 await shareToTwitterLink(text: 'text', url: 'https://flutter.dev');
 ```

That's it, **thank you** for paying attention!

*Generated by the [Very Good CLI][very_good_cli_link] 🤖*

[coverage_badge]: packages/social_share_plugin/coverage_badge.svg
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[logo_black]: https://raw.githubusercontent.com/PuffPuffDev/puff_puff_brand/main/logos/logo_black.png#gh-light-mode-only
[logo_white]: https://raw.githubusercontent.com/PuffPuffDev/puff_puff_brand/main/logos/logo_white.png#gh-dark-mode-only
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://github.com/VeryGoodOpenSource/very_good_cli
[puffpuff_link]: https://puffpuff.dev/?utm_source=github&utm_medium=banner&utm_campaign=core
[puff_puff_link_dark]: https://puffpuff.dev/?utm_source=github&utm_medium=banner&utm_campaign=core#gh-dark-mode-only
[puff_puff_link_light]: https://puffpuff.dev/?utm_source=github&utm_medium=banner&utm_campaign=core#gh-light-mode-only
