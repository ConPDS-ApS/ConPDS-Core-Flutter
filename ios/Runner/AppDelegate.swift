import UIKit
import Flutter
import ConPDS

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    var channelOCR: FlutterMethodChannel!
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        
        channelOCR = FlutterMethodChannel(name: "com.conpds.ocrenginedemo.java.ocrenginedemoapp/ocr",  binaryMessenger: controller.binaryMessenger)
        channelOCR.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if (call.method == "fromFile") {
                let ocrData = call.arguments as! [String]
                
                let apiKey = ocrData[0]
                let licenseKey = ocrData[1]
                let filePath = ocrData[2]
                
                self.ocrEngine(apiKey: apiKey, licenseKey: licenseKey, path: filePath)
                result("Success")
            } else {
                result(FlutterMethodNotImplemented)
            }
        })
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func ocrEngine(apiKey: String, licenseKey: String, path: String) {
        License.shared.getLicenseInfo(
            apiKey: apiKey,
            licenseApiKey: licenseKey)
        { (info, error) in
            if error != nil {
                return
            }
            let recognizer = RecognitionWrapper()
            let image    = UIImage(contentsOfFile: path)
            let json = try? recognizer.recognize(toJSON: image)
            self.channelOCR!.invokeMethod("sendData", arguments: json)
        }
    }
}
