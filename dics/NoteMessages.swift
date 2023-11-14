//
//  NoteMessages.swift
//  homelax-ultra
//
//  Created by Taisei Ogura on 2023/03/27.
//

import Foundation
import Firebase

class NoteMessages {
    let message: String
    
    init(dic: [String: Any]) {
        self.message = dic["message"] as? String ?? ""
    }
}
