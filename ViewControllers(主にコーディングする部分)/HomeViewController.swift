//
//  HomeViewController.swift
//  homelax-ultra
//
//  Created by Taisei Ogura on 2023/03/25.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging

import SwiftUI

let backGroundColor_gray = UIColor.rgb(red: 39, green: 31, blue: 12, alpha: 1)

class HomeViewController: UIViewController {
    
    @IBOutlet weak var noteMessageTextView: UITextView!
    @IBOutlet weak var bottomButtonView: BottomButtonView!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var frameImageView: UIImageView!
    
    let logoImage_white = UIImage.init(named: "white")
    let frameImage_white = UIImage.init(named: "f1026_1_white")
    
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var chooseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        if isDark {
            self.view.backgroundColor = backGroundColor_gray
            self.logoImage.image = self.logoImage_white
            self.noteMessageTextView.textColor = .white
            self.noteLabel.textColor = .white
            self.frameImageView.image = self.frameImage_white
        }
        
        bottomButtonView.sendButton.isEnabled = false
        
        Messaging.messaging().subscribe(toTopic: "allUsers") { error in
          print("Subscribed to weather topic")
        }

        initNav()
        initButtons()
        
        if Auth.auth().currentUser?.uid == nil {
            modalToSignUp(style: .fullScreen)
        } else {
            
            let db = Firestore.firestore().collection("users").document(Auth.auth().currentUser?.uid ?? "")
            
            db.getDocument { (snapshot, err) in
                if let err = err {
                    print(err)
                    return
                }
                
                let dic = snapshot?.data()
                let user = User.init(dic: dic!)
                
                if user.hasConfirmedToPrivacyPolicy == true {
                    hasAnswered { hasAnswered in
                            print("2 HAS ANSWERED: \(hasAnswered)")
                            if hasAnswered == true {
                                print("TRANSITION TO HOWYA")
                                crossTransition(storyBoardName: "HowYa")
                            }
                    }
                } else {
                    crossTransition(storyBoardName: "PrivacyPolicy")
                }
                
            }
            
        }
         
        getNoteMessagesFromFirestore { noteMessages in
            if noteMessages.isEmpty {
                self.noteMessageTextView.text = "こんにちは！メッセージを送ってみましょう！"
            } else {
                self.noteMessageTextView.text = noteMessages.randomElement()
            }
        }
        
        bottomButtonView.sendButton.setBackgroundImage(sendImage_filled, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentViewController = self
        currentViewControllerId = "Home"
        initNav()
        BottomButtonView().sendButton.isEnabled = false
        
        checkDarkMode()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            if isDark {
                self.view.backgroundColor = backGroundColor_gray
                self.logoImage.image = self.logoImage_white
                self.noteMessageTextView.textColor = .white
                self.noteLabel.textColor = .white
                self.frameImageView.image = self.frameImage_white
            }
        })
    }
    
    func initButtons() {
        todayButton.setTitle("今日の相手\nに送る", for: .normal)
        chooseButton.setTitle("任意の相手\nに送る", for: .normal)
        todayButton.configuration?.titleAlignment = .center
        chooseButton.configuration?.titleAlignment = .center
    }
    
    func initNav() {
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            // NavigationBarの背景色の設定
            appearance.backgroundColor = UIColor.rgb(red: 229, green: 211, blue: 177, alpha: 1)
            // NavigationBarのタイトルの文字色の設定
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel]
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }

        self.navigationItem.title = "Home"
        self.tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func modalToSignUp(style: UIModalPresentationStyle) {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let signUpViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        let nav = UINavigationController(rootViewController: signUpViewController)
        nav.modalPresentationStyle = style
        self.present(nav, animated: true, completion: nil)
    }

    func modalToSignIn(style: UIModalPresentationStyle) {
        let storyboard = UIStoryboard(name: "SignIn", bundle: nil)
        let SignInViewController = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        let nav = UINavigationController(rootViewController: SignInViewController)
        nav.modalPresentationStyle = style
        self.present(nav, animated: true, completion: nil)
    }
    
    @IBAction func tappedManagerTool(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "ManagerOptions", bundle: nil)
        let managerOptionsViewController = storyboard.instantiateViewController(withIdentifier: "ManagerOptionsViewController") as! ManagerOptionsViewController
        managerOptionsViewController.modalPresentationStyle = .pageSheet
        self.present(managerOptionsViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func tappedTodayButton(_ sender: Any) {
        pushTransit(type: currentViewController, storyboardName: "MessageSender")
    }
    
    @IBAction func tappedChooseButton(_ sender: Any) {
        pushTransit(type: currentViewController, storyboardName: "UserList")
    }
    
}



//extension HomeViewController: BottomButtonViewDelegate {
//    func tappedPushTransitButton(type: UIViewController, storyboardName: String) {
//        let storyboard = UIStoryboard.init(name: storyboardName, bundle: nil)
//        let viewController = storyboard.instantiateViewController(withIdentifier: storyboardName + "ViewController")
//        self.navigationController?.pushViewController(viewController, animated: true)
//    }
//}

