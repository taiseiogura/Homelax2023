//
//   User.swift
//  homeLux
//
//  Created by Taisei Ogura on 2022/11/03.
//

import Foundation
import Firebase

class User {
    
    let collec: String
    let grade: String
    let clas: String
    let number: String
    let name: String
    let email: String
    let createdAt: Timestamp
    let hasConfirmedToPrivacyPolicy: Bool
    
    var uid: String?
    
    init(dic: [String: Any]) {
        self.collec = dic["collec"] as? String ?? ""
        self.grade = dic["grade"] as? String ?? ""
        self.clas = dic["clas"] as? String ?? ""
        self.number = dic["number"] as? String ?? ""
        self.name = dic["name"] as? String ?? ""
        self.email = dic["email"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.hasConfirmedToPrivacyPolicy = dic["hasConfirmedToPrivacyPolicy"] as? Bool ?? false
    }
    
}

class ShuffledUser {
    
    let collec: String
    let grade: String
    let clas: String
    let number: String
    let name: String
    let email: String
    let createdAt: Timestamp
    
    var uid: String?
    
    init(dic: [String: Any]) {
        self.collec = dic["collec"] as? String ?? ""
        self.grade = dic["grade"] as? String ?? ""
        self.clas = dic["clas"] as? String ?? ""
        self.number = dic["number"] as? String ?? ""
        self.name = dic["name"] as? String ?? ""
        self.email = dic["email"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
    
}

