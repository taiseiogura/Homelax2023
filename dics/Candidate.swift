//
//  Candidates.swift
//  homeLux
//
//  Created by Taisei Ogura on 2022/12/03.
//

import Foundation
import Firebase

class Candidate {
    
    let members: [String]?
    let names: [String]?
    let createdAt: Timestamp
    
    init(dic: [String: Any]) {
        self.members = dic["members"] as? [String] ?? [String]()
        self.names = dic["names"] as? [String] ?? [String]()
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
}
