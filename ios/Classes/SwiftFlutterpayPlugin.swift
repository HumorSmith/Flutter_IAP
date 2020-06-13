import Flutter
import UIKit
import SwiftyStoreKit
public class SwiftFlutterpayPlugin: NSObject, FlutterPlugin {
  static var channel:FlutterMethodChannel?;
  public static func register(with registrar: FlutterPluginRegistrar) {
    channel = FlutterMethodChannel(name: "flutterpay", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterpayPlugin()
    
    registrar.addMethodCallDelegate(instance, channel: channel!)
  }


    var mProductionId:String = "";
    
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let methodName = call.method;
    switch methodName {
    case "canPay":
     
        break;
    case "setPayInfo":
      if let args = call.arguments as? Dictionary<String, Any>, let productId: String=args["productId"] as? String {
        mProductionId = productId;
        print("productId = "+mProductionId)
      }
        break;
    case "pay":
      SwiftyStoreKit.retrieveProductsInfo([mProductionId]) { result in
        if let product = result.retrievedProducts.first {
          let priceString = product.localizedPrice!
          print("Product: \(product.localizedDescription), price: \(priceString)")
   
            DispatchQueue.main.async {
                   self.pay();
              // your code here
            }
            
        }
        else if let invalidProductId = result.invalidProductIDs.first {
          print("Invalid product identifier: \(invalidProductId)")
        }
        else {
          print("Error: \(result.error)")
        }
      }
        break;
    default:
        break;
    }
    result("iOS " + UIDevice.current.systemVersion)
  }
    
    
  
    public func pay(){
        print("pay \(mProductionId)")
        SwiftyStoreKit.purchaseProduct(mProductionId, quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                
                
                // Get the receipt if it's available
                if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
                    FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {

                    do {
                        let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                        print(receiptData)

                        let receiptString = receiptData.base64EncodedString(options: [])
                        var parameters = Dictionary<String, String>();
                        parameters["recipeData"] = receiptString;
                        SwiftFlutterpayPlugin.channel!.invokeMethod("returnPayResult", arguments: parameters);
                        // Read receiptData
                    }
                    catch { print("Couldn't read receipt data with error: " + error.localizedDescription) }
                }
                
                
                
                
                
            case .error(let error):
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                default: print((error as NSError).localizedDescription)
                }
            }
        }
    }
    
    public func  canPay() -> Bool{
    
        return true;
    }
}
