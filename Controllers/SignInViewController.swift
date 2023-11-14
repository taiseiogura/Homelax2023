//
//  SignInViewController.swift
//  homeLux
//
//  Created by Taisei Ogura on 2022/11/29.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import PKHUD

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var signInLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var yetNoAccountButton: UIButton!
    @IBOutlet weak var errButton: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if Auth.auth().currentUser?.uid != nil {
//            self.dismiss(animated: true)
//        }
        
        self.initializer()
    }
    
    func initializer() {
        errButton.text = ""
        signInButton.layer.cornerRadius = 10
        signInButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100, alpha: 1)
        signInButton.isEnabled = false
        signInButton.addTarget(self, action: #selector(tappedSignInButton), for: .touchUpInside)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @IBAction func yetNoAccountButton(_ sender: Any) {
        if Auth.auth().currentUser?.uid == nil {
            modalToSignUp(style: .fullScreen)
        } else {
            modalToSignUp(style: .pageSheet)
        }
    }
    
    func modalToSignUp(style: UIModalPresentationStyle) {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let signUpViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        let nav = UINavigationController(rootViewController: signUpViewController)
        nav.modalPresentationStyle = style
        self.present(nav, animated: true, completion: nil)
    }
    
    @objc private func tappedSignInButton() {
        self.signInButton.isEnabled = false
        self.signInButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100, alpha: 1)
        self.errButton.text = ""
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        HUD.show(.progress)
        Auth.auth().signIn(withEmail: email, password: password) {(res, err) in
            if let err  = err {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    HUD.hide { (_) in
                        HUD.flash(.error, onView: self.view, delay: 0)
                    }
                }
                print("ログインに失敗しました。\(err)")
                self.errButton.text = "メールアドレスとパスワードをもう一度確認してください。"
                self.signInButton.isEnabled = true
                self.signInButton.backgroundColor = .rgb(red: 162, green: 85, blue: 0, alpha: 1)
                return
            }
            
            HUD.hide()
            print("ログインに成功しました。")
            self.transit()
        }
    }
    
    private func transit() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let HomeViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        let nav = UINavigationController(rootViewController: HomeViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
}

extension SignInViewController: UITextViewDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        let emailIsEmpty = emailTextField.text?.isEmpty ?? false
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? false
        
        if emailIsEmpty || passwordIsEmpty {
            signInButton.isEnabled = false
            signInButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100, alpha: 1)
        } else {
            signInButton.isEnabled = true
            signInButton.backgroundColor = .rgb(red: 162, green: 85, blue: 0, alpha: 1)
        }
    }
}
