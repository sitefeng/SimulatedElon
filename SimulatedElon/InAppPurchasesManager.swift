//
//  InAppPurchasesManager.swift
//  SimulatedElon
//
//  Created by Si Te Feng on 3/26/18.
//  Copyright © 2018 Si Te Feng. All rights reserved.
//

import UIKit
import StoreKit

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
    
    
    
    
    
    
    
    
}
