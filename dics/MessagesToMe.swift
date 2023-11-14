//
//  MessagesToMe.swift
//  homeLux
//
//  Created by Taisei Ogura on 2022/12/01.
//

import Foundation
import Firebase

class MessageToMe {
    
    let message: String
    let uidTo: String
    let uidFrom: String
    let fromName: String
    let createdAt: String
    let isAnonymous: Bool
    var feedBack: Int
    var documentId: String
    
    init(dic: [String: Any]) {
        self.message = dic["message"] as? String ?? ""
        self.uidTo = dic["uidTo"] as? String ?? ""
        self.uidFrom = dic["uidFrom"] as? String ?? ""
        self.fromName = dic["fromName"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? String ?? ""
        self.isAnonymous = dic["isAnonymous"] as? Bool ?? false
        self.feedBack = dic["feedBack"] as? Int ?? 0
        self.documentId = dic["documentId"] as? String ?? ""
    }
}
