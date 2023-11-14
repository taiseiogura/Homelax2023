//
//  IsHappy.swift
//  homelax-ultra
//
//  Created by Taisei Ogura on 2023/04/09.
//

import Foundation
import Firebase


class IsHappy {
    
    var happyScale: Int
    var grade: String
    var userId: String
    var answeredAt: Timestamp
    
    init(dic: [String: Any]) {
        self.answeredAt = dic["answeredAt"] as? Timestamp ?? Timestamp()
        self.happyScale = dic["happyScale"] as? Int ?? 2
        self.grade = dic["grade"] as? String ?? ""
        self.userId = dic["userId"] as? String ?? ""
    }
}
