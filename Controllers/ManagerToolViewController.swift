//
//  ManagerToolSignInViewController.swift
//  homeLux
//
//  Created by Taisei Ogura on 2022/12/04.
//

import UIKit
import FirebaseAuth

class ManagerToolViewController: UIViewController {
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authenticate { isAuthenticated in
            if isAuthenticated == true {
                self.dismiss(animated: true)
            } else {
                self.errorLabel.text = "！エラー！\nこのページにアクセスできるのは管理者のみです。"
            }
        }
    }
    

    @IBAction func backToHome(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let HomeViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        let nav = UINavigationController(rootViewController: HomeViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    func authenticate(completion: @escaping(Bool) -> Void) {
        var isAuthenticated: Bool = false
        if Auth.auth().currentUser?.email == "t.ogura.20210@seishokaichi.ed.jp" {
            isAuthenticated = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            completion(isAuthenticated)
        }
    }
    
}
