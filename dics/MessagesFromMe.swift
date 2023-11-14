//
//  MessagesFromMe.swift
//  Homelax
//
//  Created by Taisei Ogura on 2023/01/24.
//

import Foundation
import Firebase

class MessageFromMe {
    
    let message: String
    let uidTo: String
    let uidFrom: String
    let toName: String
    let createdAt: String
    let isAnonymous: Bool
    
    init(dic: [String: Any]) {
        self.message = dic["message"] as? String ?? ""
        self.uidTo = dic["uidTo"] as? String ?? ""
        self.uidFrom = dic["uidFrom"] as? String ?? ""
        self.toName = dic["toName"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? String ?? ""
        self.isAnonymous = dic["isAnonymous"] as? Bool ?? false
    }
}
