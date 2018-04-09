//
//  APIRequests.swift
//  SimulatedElon
//
//  Created by Si Te Feng on 4/8/18.
//  Copyright © 2018 Si Te Feng. All rights reserved.
//

import UIKit

class APIRequests: NSObject {
    
//    static let baseURL = "https://b0d97ad9.ngrok.io"
    static let baseURL = "https://selon-sms.herokuapp.com"
    
    static let adminSecret = "Bepuwre";
    
    static func welcomeNewUser(userId: String, phoneNumber: String) {
        
        let requestURL = APIRequests.baseURL + "/welcomeNewUser"
        
        let parameters: [String: Any] = [
            "adminSecret": adminSecret,
            "userId": userId,
            "phoneNumber": phoneNumber,
        ]
        
        let url = URL(string: requestURL)!
        var request = try! URLRequest(url: url, method: .post)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                print("Error: No data")
                return
            }
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) {
                print(jsonObject)
            }
            
        }
        dataTask.resume()
    }

}
