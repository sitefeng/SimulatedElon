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

enum PremiumPlanType: String {
    case EnhancedSimulation = "EnhancedSimulation"
    case LifetimeSimulation = "LifetimeSimulation"
}

protocol InAppPurchasesManagerDelegate: class {
    func inAppPurchasesManager(manager: InAppPurchasesManager, didEnablePlanOfType type:PremiumPlanType)
    func inAppPurchasesManagerTransactionDidFail(manager: InAppPurchasesManager)
}

class InAppPurchasesManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    static private var sharedManager: InAppPurchasesManager?
    
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
    
    func verifySubscription(callback: @escaping (Bool, NSDictionary?)->Void) {
        let receiptURL = Bundle.main.appStoreReceiptURL
        let receiptOrNil = NSData(contentsOf: receiptURL!)
        guard let receipt = receiptOrNil else {
            print("Error: receipt is empty")
            return
        }
        
        let requestContents: [String: Any] = [
            "receipt-data": receipt.base64EncodedString(options: []),
            "password": "your iTunes Connect shared secret"
        ]
        
        let appleServer = receiptURL?.lastPathComponent == "sandboxReceipt" ? "sandbox" : "buy"
        
        let stringURL = "https://\(appleServer).itunes.apple.com/verifyReceipt"
        
        print("Loading user receipt: \(stringURL)...")
        
        Alamofire.request(stringURL, method: .post, parameters: requestContents, encoding: JSONEncoding.default)
            .responseJSON { response in
                if let value = response.result.value as? NSDictionary {
                    print(value)
                    callback(true, value)
                } else {
                    print("Receiving receipt from App Store failed: \(response.result)")
                    callback(false, nil)
                }
        }
    }
    
    
    
    
    
    
}
