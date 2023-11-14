//
//  Settings.swift
//  homelax-ultra
//
//  Created by Taisei Ogura on 2023/03/28.
//

import Foundation
import Firebase

let da = "defaultAnonymity"
let stf = "segmentToolFirstWord"
let sts = "segmentToolSecondWord"
let lm = "longMessage"

class Setting {
    
    var settingName: String
    var segmentToolFirstWord: String
    var segmentToolSecondWord: String
    var longMessage: String
    
    init(dic: [String: Any]) {
        self.settingName = dic[da] as? String ?? ""
        self.segmentToolFirstWord = dic[stf] as? String ?? ""
        self.segmentToolSecondWord = dic[sts] as? String ?? ""
        self.longMessage = dic[lm] as? String ?? ""
    }
}
