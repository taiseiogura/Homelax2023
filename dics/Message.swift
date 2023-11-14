//
//  Message.swift
//  homeLux
//
//  Created by Taisei Ogura on 2022/12/01.
//

import Foundation
import Firebase

class Message {
    
    let message: String
    let toName: String
    let uidTo: String
    let fromName: String
    let uidFrom: String
    let theirClass: String
    let createdAt: String
    let isAnonymous: Bool
    let feedBack: Int
    let documentId: String
    
    init(dic: [String: Any]) {
        self.message = dic["message"] as? String ?? ""
        self.toName = dic["toName"] as? String ?? ""
        self.uidTo = dic["uidTo"] as? String ?? ""
        self.fromName = dic["fromaName"] as? String ?? ""
        self.uidFrom = dic["uidFrom"] as? String ?? ""
        self.theirClass = dic["theirClass"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? String ?? ""
        self.isAnonymous = dic["isAnonymous"] as? Bool ?? false
        self.feedBack = dic["feedBack"] as? Int ?? 0
        self.documentId = dic["documentId"] as? String ?? ""
    }
    
}

