import FBSDKCoreKit
import FBSDKShareKit
import Flutter
import UIKit

public class SwiftSocialSharePlugin: NSObject, FlutterPlugin, SharingDelegate {
    public func sharer(_ sharer: Sharing, didCompleteWithResults results: [String: Any]) {
        _channel.invokeMethod("onSuccess", arguments: nil)
        guard let result = _result else {
            return
        }
        result(true)
    }

    public func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        _channel.invokeMethod("onError", arguments: nil)
        guard let result = _result else {
            return
        }
        result(false)
    }

    public func sharerDidCancel(_ sharer: Sharing) {
        _channel.invokeMethod("onCancel", arguments: nil)
        guard let result = _result else {
            return
        }
        result(false)
    }

    var _result: FlutterResult?
    var _channel: FlutterMethodChannel
    var _dic: UIDocumentInteractionController?

    init(fromChannel channel: FlutterMethodChannel) {
        _channel = channel
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "social_share_plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftSocialSharePlugin(fromChannel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any] = [:]) -> Bool {
        let launchOptionsForFacebook = launchOptions as? [UIApplication.LaunchOptionsKey: Any]
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions:
            launchOptionsForFacebook
        )
        return true
    }

    public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return ApplicationDelegate.shared.application(application, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }

    public func application(_ application: UIApplication, open url: URL, sourceApplication: String, annotation: Any) -> Bool {
        return ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "shareToFeedInstagram":
            guard let args = call.arguments else {
                result(false)
                break
            }
            if let myArgs = args as? [String: Any],
               let path = myArgs["path"] as? String
            {
                let instagramURL = URL(string: "instagram://app")
                if let instagramURL = instagramURL {
                    if UIApplication.shared.canOpenURL(instagramURL) {
                        instagramShare(path)
//                        result(nil)
                    } else {
                        let instagramLink = "itms-apps://itunes.apple.com/us/app/apple-store/id389801252"
                        if #available(iOS 10.0, *) {
                            if let url = URL(string: instagramLink) {
                                UIApplication.shared.open(url, options: [:]) { _ in
                                }
                            }
                        } else {
                            if let url = URL(string: instagramLink) {
                                UIApplication.shared.openURL(url)
                            }
                        }
                        result(false)
                    }
                }
            } else {
                result(false)
            }
        case "shareToFeedFacebook":
            guard let args = call.arguments else {
                result(false)
                break
            }
            if let myArgs = args as? [String: Any],
               let path = myArgs["path"] as? String
            {
                let fbURL = URL(string: "fbapi://")
                if let fbURL = fbURL {
                    if UIApplication.shared.canOpenURL(fbURL) {
                        facebookShare(path)
//                        result(nil)
                    } else {
                        let fbLink = "itms-apps://itunes.apple.com/us/app/apple-store/id284882215"
                        if #available(iOS 10.0, *) {
                            if let url = URL(string: fbLink) {
                                UIApplication.shared.open(url, options: [:]) { _ in
                                }
                            }
                        } else {
                            if let url = URL(string: fbLink) {
                                UIApplication.shared.openURL(url)
                            }
                        }
                        result(false)
                    }
                }
            } else {
                result(false)
            }
        case "shareToFeedFacebookLink":
            guard let args = call.arguments else {
                result(false)
                break
            }
            if let myArgs = args as? [String: Any],
               let quote = myArgs["quote"] as? String,
               let url = myArgs["url"] as? String
            {
                let fbURL = URL(string: "fbapi://")
                if let fbURL = fbURL {
                    if UIApplication.shared.canOpenURL(fbURL) {
                        facebookShareLink(quote, url: url)
//                        result(nil)
                    } else {
                        let fbLink = "itms-apps://itunes.apple.com/us/app/apple-store/id284882215"
                        if #available(iOS 10.0, *) {
                            if let url = URL(string: fbLink) {
                                UIApplication.shared.open(url, options: [:]) { _ in
                                }
                            }
                        } else {
                            if let url = URL(string: fbLink) {
                                UIApplication.shared.openURL(url)
                            }
                        }
                        result(false)
                    }
                }
            } else {
                result(false)
            }
        case "shareToTwitterLink":
            guard let args = call.arguments else {
                result(false)
                break
            }
            if let myArgs = args as? [String: Any],
               let text = myArgs["text"] as? String,
               let url = myArgs["url"] as? String
            {
                if let twitterURL = URL(string: "twitter://") {
                    if UIApplication.shared.canOpenURL(twitterURL) {
                        twitterShare(text, url: url)
//                        result(nil)
                    } else {
                        let twitterLink = "itms-apps://itunes.apple.com/us/app/apple-store/id333903271"
                        if #available(iOS 10.0, *) {
                            if let url = URL(string: twitterLink) {
                                UIApplication.shared.open(url, options: [:]) { _ in
                                }
                            }
                        } else {
                            if let url = URL(string: twitterLink) {
                                UIApplication.shared.openURL(url)
                            }
                        }
                        result(false)
                    }
                }
            } else {
                result(false)
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func instagramShare(_ imagePath: String?) {
        let controller = UIApplication.shared.delegate?.window??.rootViewController
        do {
            try FileManager.default.moveItem(atPath: imagePath ?? "", toPath: "\(imagePath ?? "").igo")
        } catch {}
        let path = URL(string: "file://\(imagePath ?? "").igo")
        if let path = path {
            _dic = UIDocumentInteractionController(url: path)
            _dic?.uti = "com.instagram.exclusivegram"
            if let view = controller?.view {
                if !(_dic?.presentOpenInMenu(from: CGRect.zero, in: view, animated: true) ?? false) {
                    print("Error sharing to instagram")
                }
            }
        }
    }

    func facebookShare(_ imagePath: String?) {
        // NSURL* path = [[NSURL alloc] initWithString:call.arguments[@"path"]];
        if let image = UIImage(contentsOfFile: imagePath ?? "") {
            let photo = SharePhoto(image: image, isUserGenerated: true)
            let content = SharePhotoContent()
            content.photos = [photo]
            let controller = UIApplication.shared.delegate?.window??.rootViewController
            ShareDialog.show(viewController: controller, content: content, delegate: self)
        }
    }

    func facebookShareLink(_ quote: String,
                           url: String)
    {
        let content = ShareLinkContent()
        content.contentURL = URL(string: url)
        content.quote = quote
        let controller = UIApplication.shared.delegate?.window??.rootViewController
        ShareDialog.show(viewController: controller, content: content, delegate: self)
    }

    func twitterShare(_ text: String,
                      url: String)
    {
        let shareString = "https://twitter.com/intent/tweet?text=\(text)&url=\(url)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        if let shareUrl = URL(string: shareString) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(shareUrl, options: [:]) { success in
                    if success {
                        self._channel.invokeMethod("onSuccess", arguments: nil)
                        guard let result = self._result else {
                            return
                        }
                        result(true)
                    } else {
                        self._channel.invokeMethod("onCancel", arguments: nil)
                        guard let result = self._result else {
                            return
                        }
                        result(false)
                    }
                }
            } else {
                UIApplication.shared.openURL(shareUrl)
                _channel.invokeMethod("onSuccess", arguments: nil)
                guard let result = _result else {
                    return
                }
                result(true)
            }
        }
    }
}
