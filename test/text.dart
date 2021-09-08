// import Flutter
// import UIKit
// import SwiftyTesseract

// public class SwiftFlutterTesseractPlugin: NSObject, FlutterPlugin {
    
// //    var swiftyTesseract = SwiftyTesseract(language: .english)
    
//     var bundle: Bundle!
//     var swiftyTesseract: SwiftyTesseract!
    
//     // setup the data source class
//     struct MyDataSource: LanguageModelDataSource {
//         var location: String
//         var pathToTrainedData: String { return location }
//     }
    
//     var documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
// //    let documentsFolder = try? FileManager.default.url(for: .documentDirectory,
// //                                                         in: .userDomainMask,
// //                                                         appropriateFor: nil,
// //                                                         create: false)
    
// //    let tessData = documentsFolder!.appendingPathComponent("tessdata")
    
//     var tessData = documentDirectory.appendPathComponent("tessdata")
    
//     let dataSource = MyDataSource(location: tessData.path)
    
    
//     func testDataSourceFromFiles() {
//       // Move data from bundle to documents directory /tessdata
//       guard let documentsFolder = try? FileManager.default.url(for: .documentDirectory,
//                                                            in: .userDomainMask,
//                                                            appropriateFor: nil,
//                                                            create: false) else { return }
//       // this directory will contain our traineddata and is what we will pass to the data source
//       let tessData = documentsFolder.appendingPathComponent("tessdata")

//       try? FileManager.default.createDirectory(at: tessData, withIntermediateDirectories: true, attributes: nil)
//       if let path = bundle.url(forResource: "eng", withExtension: "traineddata", subdirectory: "tessdata") {
//           try? FileManager.default.copyItem(at: path, to: tessData.appendingPathComponent("eng.traineddata"))
//       }

// //      // setup the data source class
// //      struct MyDataSource: LanguageModelDataSource {
// //          var location: String
// //          var pathToTrainedData: String { return location }
// //      }

//       let dataSource = MyDataSource(location: tessData.path)

//       // init the wrapper class using our custom data source.
//       let swt = SwiftyTesseract(language: .english, dataSource: dataSource)

//     }
    
// //
// //    var swiftyTesseract = SwiftyTesseract.init(
// //        language: .english,
// //        dataSource: Bundle.main,
// //        engineMode: EngineMode.lstmOnly)

//     public static func register(with registrar: FlutterPluginRegistrar) {
//         let channel = FlutterMethodChannel(name: "tesseract", binaryMessenger: registrar.messenger())
//         let instance = SwiftFlutterTesseractPlugin()
//         registrar.addMethodCallDelegate(instance, channel: channel)
//     }
    
//     func json(from object:Any) -> String? {
//         guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
//             return nil
//         }
//         return String(data: data, encoding: String.Encoding.utf8)
//     }
    
//     public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//         if(call.method == "initswiftyTesseract")
//         {
//             testDataSourceFromFiles()
            
//             guard let args = call.arguments else {
//                 result("iOS could not recognize flutter arguments in method: (sendParams)")
//                 result(false)
//                 return
//             }
            
//             let params: [String : Any] = args as! [String : Any]
//             let language: String? = params["language"] as? String
//             //  let tesseractArgs: [String : Any] = params["args"] as! [String : Any]
//             ////TODO: 
//             //tesseractArgs needs to be parsed
//             if(language != nil){
                
//                 swiftyTesseract = SwiftyTesseract.init(
//                     language: .custom((language as String?)!),
//                     dataSource: Bundle.main,
//                     engineMode: EngineMode.lstmOnly)
                
//             }
//             result(true)
//             return
//         }
//         else if (call.method == "extractTextLive"){
            
//             guard let args = call.arguments else {
//                 result("iOS could not recognize flutter arguments in method: (sendParams)")
//                 return
//             }
            
//             let params: [String : Any] = args as! [String : Any]
//             let imgD: FlutterStandardTypedData? = params["imageData"] as? FlutterStandardTypedData
            
//             let imageBytes : Data
//             imageBytes = imgD!.data
            
//             guard let image = UIImage(data: imageBytes) else { return}
            
//             swiftyTesseract.performOCR(on: image) { recognizedString in
//                 guard let extractText = recognizedString else { return }
//                 result(extractText)
//             }
//         }
//         else if (call.method == "extractTextWithConfidence"){
//             guard let args = call.arguments else {
//                 result("iOS could not recognize flutter arguments in method: (sendParams)")
//                 return
//             }
            
//             let params: [String : Any] = args as! [String : Any]
//             let imgD: FlutterStandardTypedData? = params["imageData"] as? FlutterStandardTypedData
            
//             let imageBytes : Data
//             imageBytes = imgD!.data
            
//             guard let image = UIImage(data: imageBytes) else { return}
//             swiftyTesseract.whiteList = ""
//             swiftyTesseract.blackList = ""
            
//             let res: Result<String, Error> = swiftyTesseract.performOCR(on: image)
            
            
//             guard let blockResult = swiftyTesseract.recognizedBlocks(for: ResultIteratorLevel.block) as Result<[RecognizedBlock], Error>?
//             else
//             {
//                 NSLog("Error")
//                 return
//             }
            
//             blockResult.map({recognizedBlock in
                
//                 let myDictionary = recognizedBlock.reduce([String: Any]()) { (dict, RecognizedBlock) -> [String: Any] in
//                     var dict = dict
//                     dict["text"] = RecognizedBlock.text
//                     dict["confidence"] = RecognizedBlock.confidence
//                     dict["boundingBoxOriginX"] = RecognizedBlock.boundingBox.origin.x
//                     dict["boundingBoxOriginY"] = RecognizedBlock.boundingBox.origin.y
//                     dict["boundingBoxWidth"] = RecognizedBlock.boundingBox.size.width
//                     dict["boundingBoxHeight"] = RecognizedBlock.boundingBox.size.height
//                     return dict
//                 }
                
//                 result(myDictionary)

//             })

//             return
// //            swiftyTesseract.performOCR(on: image) { recognizedString in
// //                guard let extractText = recognizedString else { return }
// //                result(extractText)
// //            }
//         }
//         else
//         {
//             result("iOS could not recognize flutter call for: " + call.method)
//             return
//         }
//     }
// }





















// import UIKit
// import Flutter
// import flutter_downloader

// // Defines a custom plugin registrant, to be used specifically together with FlutterIsolatePlugin
// @objc(IsolatePluginRegistrant) class IsolatePluginRegistrant: NSObject {
//     @objc static func register(withRegistry registry: FlutterPluginRegistry) {
//         // Register channels for Flutter Isolate
//         registerMethodChannelABC(bm: registry.registrar(forPlugin: "com.hunaindev.initswiftyTesseract").messenger())

//         // Register default plugins
//         GeneratedPluginRegistrant.register(with: registry)
//     }
// }

// @UIApplicationMain
// @objc class AppDelegate: FlutterAppDelegate {
//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//   ) -> Bool {

//         let controller = window.rootViewController as! FlutterViewController

//         // Register custom channels for Flutter
//         registerMethodChannelABC(bm: controller.binaryMessenger) // <-- the custom method channel

//         // Point FlutterIsolatePlugin to use our previously defined custom registrant.
//         // The string content must be equal to the plugin registrant class annotation 
//         // value: @objc(IsolatePluginRegistrant)
//         FlutterIsolatePlugin.isolatePluginRegistrantClassName = "IsolatePluginRegistrant" // <--


//     GeneratedPluginRegistrant.register(with: self)
//     FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)
//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//   }
// }

// private func registerPlugins(registry: FlutterPluginRegistry) { 
//     if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
//        FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
//     }
// }