//
//  IndSettings.swift
//  homelax-ultra
//
//  Created by Taisei Ogura on 2023/03/29.
//

import Foundation
import Firebase

let dis = "ダークモード"
let defAn = "デフォルトの匿名性"
let nis = "通知"


class IndSetting {
    
    var darkIsSet: Bool
    var isDefaultAnonymous: Bool
    var notifIsSet: Bool
    
    
    init(dic: [String: Any]) {
        self.darkIsSet = dic[dis] as? Bool ?? false
        self.isDefaultAnonymous = dic[defAn] as? Bool ?? false
        self.notifIsSet = dic[nis] as? Bool ?? false
    }
}
