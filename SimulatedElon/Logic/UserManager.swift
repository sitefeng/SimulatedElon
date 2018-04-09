//
//  UserManager.swift
//  SimulatedElon
//
//  Created by Si Te Feng on 4/1/18.
//  Copyright © 2018 Si Te Feng. All rights reserved.
//

import UIKit
import Firebase

class UserManager: NSObject {
    
    static private var sharedManager: UserManager?
    
    private(set) var userId: String?
    private(set) var currentUser: [String: Any]?
    
    private var userReference: DatabaseReference?
    
    override init() {
        super.init()
    }
    
    class func shared() -> UserManager {
        if let manager = self.sharedManager {
            return manager
        } else {
            let manager = UserManager()
            self.sharedManager = manager
            return manager
        }
    }
    
    func startObserving(_ callback: (([String: Any]?)-> Void)?) {
        self.userReference?.removeAllObservers()
        self.userReference = nil
        
        guard let userId = self.userId else {
            return
        }
        
        self.userReference = Database.database().reference(withPath: "users/\(userId)")
        self.userReference?.observe(DataEventType.value, with: { (snap) in
            let user = snap.value
            if let user = user as? [String: Any] {
                self.currentUser = user
            } else {
                self.currentUser = nil
            }
            
            callback?(self.currentUser)
        })
    }
    
    func userIdChanged(newId: String) {
        self.userId = newId
    }
    
    func isUserPremium() -> Bool {
        if let isPremium = self.currentUser?["premium"] as? Bool {
            return isPremium
        } else {
            return false
        }
    }
}
