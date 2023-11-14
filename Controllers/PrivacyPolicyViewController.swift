//
//  PrivacyPolicyViewController.swift
//  homelax-ultra
//
//  Created by Taisei Ogura on 2023/05/07.
//

import Foundation
import UIKit
import Firebase

class PrivacyPolicyViewController: UIViewController {

    @IBOutlet weak var agreeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentViewController = self
    }
    
    @IBAction func agreeButton(_ sender: Any) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let db = Firestore.firestore().collection("users").document(uid)
        db.updateData(["hasConfirmedToPrivacyPolicy": true]) { err in
            if let err = err {
                print(err)
            } else {
                crossTransition(storyBoardName: "Home")
            }
        }
    }
    
}

