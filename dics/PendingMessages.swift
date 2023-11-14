//
//  PendingMessages.swift
//  Homelax
//
//  Created by Taisei Ogura on 2023/03/19.
//

import Foundation
import Firebase

class PendingMessage {
    
    let message: String
    let toName: String
    let uidTo: String
    let fromName: String
    let uidFrom: String
    let theirClass: String
    let createdAt: String
    let isAnonymous: Bool
    var isPermitted: Bool
    var docId: String
    
    init(dic: [String: Any]) {
        self.message = dic["message"] as? String ?? ""
        self.toName = dic["toName"] as? String ?? ""
        self.uidTo = dic["uidTo"] as? String ?? ""
        self.fromName = dic["fromName"] as? String ?? ""
        self.uidFrom = dic["uidFrom"] as? String ?? ""
        self.theirClass = dic["theirClass"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? String ?? ""
        self.isAnonymous = dic["isAnonymous"] as? Bool ?? false
        self.isPermitted = dic["isPermitted"] as? Bool ?? false
        self.docId = dic["docId"] as? String ?? ""
    }
    
}
