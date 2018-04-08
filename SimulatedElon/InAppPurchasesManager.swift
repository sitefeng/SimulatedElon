//
//  InAppPurchasesManager.swift
//  SimulatedElon
//
//  Created by Si Te Feng on 3/26/18.
//  Copyright © 2018 Si Te Feng. All rights reserved.
//

import UIKit
import StoreKit
import Alamofire

let UserDefaultsPremiumPlanTypeKey = "SEUserDefaultsPremiumPlanTypeKey"

let InAppPurchasesManagerRestorePurchasesSuccessNotification = NSNotification.Name("InAppPurchasesManagerRestorePurchasesSuccessNotification")
let InAppPurchasesManagerRestorePurchasesFailureNotification = NSNotification.Name("InAppPurchasesManagerRestorePurchasesFailureNotification")

enum PremiumPlanType: String {
    case EnhancedSimulation = "EnhancedSimulation"
    case LifetimeSimulation = "LifetimeSimulation"
}

protocol InAppPurchasesManagerDelegate: class {
    func inAppPurchasesManager(manager: InAppPurchasesManager, didEnablePlanOfType type:PremiumPlanType)
    func inAppPurchasesManagerTransactionDidFail(manager: InAppPurchasesManager)
}


class InAppPurchasesManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver, SKRequestDelegate {
    
    static private var sharedManager: InAppPurchasesManager?
    
    private(set) var isPremium: Bool = false
    private(set) var isTrial: Bool = false
    
    weak var delegate: InAppPurchasesManagerDelegate?
    
    private let productIds = ["simulatedelon1", "lifetimeSimulation"]
    
    private(set) var yearlyPlan: SKProduct?
    private(set) var lifetimePlan: SKProduct?
    
    override init() {
        super.init()
    }
    
    class func shared() -> InAppPurchasesManager {
        if let manager = self.sharedManager {
            return manager
        } else {
            let manager = InAppPurchasesManager()
            self.sharedManager = manager
            return manager
        }
    }
    
    func getProducts() {
        let productRequest = SKProductsRequest(productIdentifiers: Set(productIds))
        productRequest.delegate = self
        productRequest.start()
        
        SKPaymentQueue.default().add(self)
    }
    
    func purchaseYearly() {
        guard let yearlyPlan = yearlyPlan, SKPaymentQueue.canMakePayments() else { return }
        let yearlyPayment = SKMutablePayment(product: yearlyPlan)
        yearlyPayment.quantity = 1
        
        SKPaymentQueue.default().add(yearlyPayment)
    }
    
    func purchaseLifetime() {
        guard let lifetimePlan = lifetimePlan, SKPaymentQueue.canMakePayments() else { return }
        let lifetimePayment = SKMutablePayment(product: lifetimePlan)
        lifetimePayment.quantity = 1
        SKPaymentQueue.default().add(lifetimePayment)
    }
    
    // MARK: Helper functions
    private func premiumEnableSuccessful(plan: PremiumPlanType) {
        self.delegate?.inAppPurchasesManager(manager: self, didEnablePlanOfType: plan)
        
        UserDefaults.standard.set(plan.rawValue, forKey: UserDefaultsPremiumPlanTypeKey)
    }
    
    // MARK: SKProductRequestDelegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        for product in response.products {
            print("PRODUCTT: \(product.localizedDescription)")
            if product.productIdentifier == productIds[0] {
                yearlyPlan = product
            }
            if product.productIdentifier == productIds[1] {
                lifetimePlan = product
            }
        }
    }
    
    // MARK: PaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchasing:
                print("State purchasing")
            case .deferred:
                print("State purchasing")
            case .purchased:
                print("purchased")
                if (transaction.payment.productIdentifier == productIds[0]) {
                    self.premiumEnableSuccessful(plan: PremiumPlanType.EnhancedSimulation)
                } else if (transaction.payment.productIdentifier == productIds[1]) {
                    self.premiumEnableSuccessful(plan: PremiumPlanType.LifetimeSimulation)
                }
            case .restored:
                print("restored")
                if (transaction.payment.productIdentifier == productIds[0]) {
                    self.premiumEnableSuccessful(plan: PremiumPlanType.EnhancedSimulation)
                } else if (transaction.payment.productIdentifier == productIds[1]) {
                    self.premiumEnableSuccessful(plan: PremiumPlanType.LifetimeSimulation)
                }
            case .failed:
                print("Failed")
                self.delegate?.inAppPurchasesManagerTransactionDidFail(manager: self)
                
            }
        }
    }
    
    
    // @param callback inputs are (isPremium, isTrial, No Premium Reason)
    func verifySubscription(callback: @escaping (Bool, Bool, String)->Void) {
        let receiptURL = Bundle.main.appStoreReceiptURL
        let receiptOrNil = NSData(contentsOf: receiptURL!)
        guard let receipt = receiptOrNil else {
            print("Error: receipt is empty")
            return
        }
        
        let requestContents: [String: Any] = [
            "receipt-data": receipt.base64EncodedString(options: []),
            "password": "2de7d0ed748445899827664ed7bb1390"
        ]
        
        let appleServer = receiptURL?.lastPathComponent == "sandboxReceipt" ? "sandbox" : "buy"
        let stringURL = "https://\(appleServer).itunes.apple.com/verifyReceipt"
        
        Alamofire.request(stringURL, method: .post, parameters: requestContents, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                if let value = response.result.value as? NSDictionary {
                    if let latestReceipt = value["latest_receipt_info"] as? NSArray {
//                        print("*** Got LatestReceiptInfo: \(latestReceipt)")
                        
                        let receiptCount = latestReceipt.count
//                        print("There are \(receiptCount) receipts in total")
                        
                        if receiptCount > 0 {
                            if let newestLatestReceipt = latestReceipt[receiptCount-1] as? NSDictionary {
                                
                                if let expiresDateString = newestLatestReceipt["expires_date_ms"] as? NSString {
                                    let expiresDateNum = expiresDateString.doubleValue
                                    let expiresDate = Date(timeIntervalSince1970: expiresDateNum/1000)
                                    let today = Date()
//                                    print("verifySubscription: ExpirationDate: \(expiresDate), Today: \(today)")
                                    let isPremiumStillValid = expiresDate >= today
                                    if isPremiumStillValid {
                                        if let isTrialPeriodString = newestLatestReceipt["is_trial_period"] as? NSString {
                                            let isTrialPeriod = isTrialPeriodString.boolValue
                                            print("verifySubscription: User is premium, isTrialPeriodStatus: \(isTrialPeriod)")
                                            self.isPremium = true
                                            self.isTrial = isTrialPeriod
                                            callback(true, isTrialPeriod, "")
                                            return
                                        } else {
                                            print("verifySubscription: cannot read is_trial_period flag, but user is premium")
                                            self.isPremium = true
                                            self.isTrial = false
                                            callback(true, false, "")
                                            return
                                        }
                                    } else {
                                        print("verifySubscription: subscription expired")
                                        self.isPremium = false
                                        self.isTrial = false
                                        callback(false, false, "Subscription expired.")
                                        return
                                    }
                                }
                            }
                        }
                        
                        print("Error: receipt not found, cannot validate user subscription")
                        self.isPremium = false
                        self.isTrial = false
                        callback(false, false, "Purchase receipts not found.")
                        return
                    }
                    
                    print("verifySubscription: Subscription not subscribed")
                    self.isPremium = false
                    self.isTrial = false
                    callback(false, false, "No subscription records were found.")
                    
                } else {
                    print("Error: Receiving receipt from App Store failed: \(response.result)")
                    self.isPremium = false
                    self.isTrial = false
                    callback(false, false, "Problem fetching purchases data from the App Store.")
                }
        }
    }
    
    
    func restorePurchases() {
        print("Refresh started")
        let request = SKReceiptRefreshRequest()
        request.delegate = self
        request.start()
    }
    
    func requestDidFinish(_ request: SKRequest) {
        print("request did finish")
        
        if request is SKReceiptRefreshRequest {
            print("request success request type is SKReceiptRefreshRequest")
            
            self.verifySubscription { (isPremium, isTrial, failReason) in
                print("request restore purchases verified: isPremium:\(isPremium), isTrial:\(isTrial)")
                if isPremium {
                    NotificationCenter.default.post(name: InAppPurchasesManagerRestorePurchasesSuccessNotification, object: nil, userInfo: nil)
                } else {
                    NotificationCenter.default.post(name: InAppPurchasesManagerRestorePurchasesFailureNotification, object: nil, userInfo: ["reason": failReason])
                }
            }
            
        } else {
            print("request sucess request type is NOT SKReceiptRefreshRequest")
        }
        
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("request failed \(error.localizedDescription)")
        print("request failed request \(request)")
        if request is SKReceiptRefreshRequest {
            print("request failed request type is SKReceiptRefreshRequest")
            let reason = error.localizedDescription
            NotificationCenter.default.post(name: InAppPurchasesManagerRestorePurchasesFailureNotification, object: nil, userInfo: ["reason": reason])
        } else {
            print("request failed request type is NOT SKReceiptRefreshRequest")
        }
        
    }
    
}
