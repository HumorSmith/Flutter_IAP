import UIKit
import Flutter
import SwiftyStoreKit
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    
    SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
              for purchase in purchases {
                  switch purchase.transaction.transactionState {
                  case .purchased, .restored:
                      if purchase.needsFinishTransaction {
                          // Deliver content from server, then:
                          SwiftyStoreKit.finishTransaction(purchase.transaction)
                      }
                      // Unlock content
                  case .failed, .purchasing, .deferred:
                      break // do nothing
                  }
              }
          }
    
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    

}
