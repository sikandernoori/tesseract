import Flutter
import UIKit
import SwiftyTesseract

public class SwiftTesseractPlugin: NSObject, FlutterPlugin {
    
    var bundle: Bundle!
    var swiftyTesseract: SwiftyTesseract!
    var dataSource: MyDataSource!
    var LAST_LANGUAGE: String!
    var LAST_WHITELIST: String!
    var LAST_BLACKLIST: String!
    var LAST_PRESERVE_INTERWORD_SPACES: Bool!
    
    // setup the data source class
    struct MyDataSource: LanguageModelDataSource {
        var location: String
        var pathToTrainedData: String { return location }
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "tesseract", binaryMessenger: registrar.messenger())
        let instance = SwiftTesseractPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if(call.method == "initswiftyTesseract")
        {
            guard let args = call.arguments else {
                result("iOS could not recognize flutter arguments in method: (sendParams)")
                result(false)
                return
            }
            
            let params: [String : Any] = args as! [String : Any]
            let language: String? = params["language"] as? String
            let tessData = params["tessData"] as? String
            let tesseractArgs: [String : Any]? = params["args"] as? [String : Any]
            let preserve_interword_spaces: Bool = tesseractArgs?["preserve_interword_spaces"] as? Bool ?? true
            
            let whiteList = tesseractArgs?["whiteList"] as? String
            let blackList = tesseractArgs?["blackList"] as? String

            if(dataSource == nil)
            {
                if(tessData != nil)
                {
                    dataSource = MyDataSource(location: tessData!)
                }
                else
                {
                    result(false)
                    return
                }
            }
            
            if(language != nil){
                
                swiftyTesseract = SwiftyTesseract.init(
                    language: .custom((language as String?)!),
                    dataSource: dataSource,
                    engineMode: EngineMode.lstmOnly)
            }
            else
            {
                swiftyTesseract = SwiftyTesseract.init(
                    language: .english,
                    dataSource: dataSource,
                    engineMode: EngineMode.lstmOnly)
            }
            
            if(preserve_interword_spaces != nil)
            {
                swiftyTesseract.preserveInterwordSpaces = preserve_interword_spaces
                LAST_PRESERVE_INTERWORD_SPACES = preserve_interword_spaces
            }
            else
            {
                swiftyTesseract.preserveInterwordSpaces = true
            }
            
            if(whiteList != nil)
            {
                swiftyTesseract.whiteList = whiteList
                LAST_WHITELIST = whiteList
            }
            if(blackList != nil)
            {
                swiftyTesseract.blackList = blackList
                LAST_BLACKLIST = blackList
            }
            result(true)
            return
        }
        else if (call.method == "performOCR"){
            guard let args = call.arguments else {
                result("iOS could not recognize flutter arguments in method: (sendParams)")
                return
            }

            // var finalResult: [String:Any]

            
            
            let params: [String : Any] = args as! [String : Any]
            let imgD: FlutterStandardTypedData? = params["imageData"] as? FlutterStandardTypedData
            
            let language: String? = params["language"] as? String
            
            let tesseractArgs: [String : Any]? = params["args"] as? [String : Any]
            let preserve_interword_spaces: Bool = tesseractArgs?["preserve_interword_spaces"] as? Bool ??  true
            
            let whiteList = tesseractArgs?["whiteList"] as? String
            let blackList = tesseractArgs?["blackList"] as? String
            let workItem = DispatchWorkItem{
                if(language != self.LAST_LANGUAGE)
            {
                    self.swiftyTesseract = SwiftyTesseract.init(
                    language: .custom((language as String?)!),
                        dataSource: self.dataSource,
                    engineMode: EngineMode.lstmOnly)
            }
                if(whiteList != self.LAST_WHITELIST)
            {
                    self.swiftyTesseract.whiteList = whiteList
                    self.LAST_WHITELIST = whiteList
            }
                if(blackList != self.LAST_BLACKLIST)
            {
                    self.swiftyTesseract.blackList = blackList
                    self.LAST_BLACKLIST = blackList
            }
                if(preserve_interword_spaces != self.LAST_PRESERVE_INTERWORD_SPACES)
            {
                    self.swiftyTesseract.preserveInterwordSpaces = preserve_interword_spaces
                    self.LAST_PRESERVE_INTERWORD_SPACES = preserve_interword_spaces
            }
            
            let imageBytes : Data
            imageBytes = imgD!.data
            
            guard let image = UIImage(data: imageBytes) else { return}
            
            
            
                let res: Result<String, Error> = self.swiftyTesseract.performOCR(on: image)
            
            
                guard let blockResult = self.swiftyTesseract.recognizedBlocks(for: ResultIteratorLevel.block) as Result<[RecognizedBlock], Error>?
            else
            {
                NSLog("Error")
                return
            }
            
            blockResult.map({recognizedBlock in
                
                let myDictionary = recognizedBlock.reduce([String: Any]()) { (dict, RecognizedBlock) -> [String: Any] in
                    var dict = dict
                    dict["text"] = RecognizedBlock.text
                    dict["confidence"] = RecognizedBlock.confidence
                    dict["boundingBoxOriginX"] = RecognizedBlock.boundingBox.origin.x
                    dict["boundingBoxOriginY"] = RecognizedBlock.boundingBox.origin.y
                    dict["boundingBoxWidth"] = RecognizedBlock.boundingBox.size.width
                    dict["boundingBoxHeight"] = RecognizedBlock.boundingBox.size.height
                    return dict
                }
                
                result(myDictionary)

            })
            }

            workItem.notify(queue: .main){
                NSLog("Notified")
                return
            }
            
            let queue = DispatchQueue.global(qos: .background)
            queue.async(execute: workItem)
//            swiftyTesseract.performOCR(on: image) { recognizedString in
//                guard let extractText = recognizedString else { return }
//                result(extractText)
//            }
        }
        else
        {
            result("iOS could not recognize flutter call for: " + call.method)
            return
        }
    }
}
