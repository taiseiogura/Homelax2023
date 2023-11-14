//
//  SinUpViewController.swift
//  homeLux
//
//  Created by Taisei Ogura on 2022/11/03.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import PKHUD



class SignUpViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var gradeTextField: UITextField!
    @IBOutlet weak var classTextField: UITextField!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var eyeButton: UIButton!
    
    var eyeButtonSlashed: Bool = true
    
    var grades: [String] = []
    var classes: [String] = []
    var numbers: [String] = []
    
    weak var pickerViewForGrades: UIPickerView?
    weak var pickerViewForClasses: UIPickerView?
    weak var pickerViewForNumbers: UIPickerView?
    
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("hiThere")
        
        currentViewController = self
        
        registerButton.layer.cornerRadius = 10.0
        registerButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100, alpha: 1)
        registerButton.isEnabled = false
        
        gradeTextField.delegate = self
        classTextField.delegate = self
        numberTextField.delegate = self
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        eyeButton.setBackgroundImage(eyeSlashImage, for: .normal)
        
        setUpEnumsForGrades()
        setUpEnumsForClasses()
        setUpEnumsForNumbers()
        
        registerButton.addTarget(self, action: #selector(tappedRegisterButton), for: .touchUpInside)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
           self.view.endEditing(true)
    }
    
    @IBAction func tappedEyeButton(_ sender: Any) {
        if !eyeButtonSlashed {
            passwordTextField.isSecureTextEntry = true
            eyeButtonSlashed = true
            eyeButton.setBackgroundImage(eyeSlashImage, for: .normal)
        } else {
            passwordTextField.isSecureTextEntry = false
            eyeButtonSlashed = false
            eyeButton.setBackgroundImage(eyeImage, for: .normal)
        }
    }
    
    
    @objc private func tappedRegisterButton() {
        
        showDialog()
        ////////
        
    }
    
    func getMyClass(completion: @escaping(String) -> Void) {
        guard let grade = gradeTextField.text else { return }
        guard let clas = classTextField.text else { return }
        if grade == "中１" && clas == "A" {
            completion("1A")
        } else if grade == "中１" && clas == "B" {
            completion("1B")
        } else if grade == "中２" && clas == "A" {
            completion("2A")
        } else if grade == "中２" && clas == "B" {
            completion("2B")
        } else if grade == "中３" && clas == "A" {
            completion("3A")
        } else if grade == "中３" && clas == "B" {
            completion("3B")
        } else if grade == "高１" && clas == "A" {
            completion("4A")
        } else if grade == "高１" && clas == "B" {
            completion("4B")
        } else if grade == "高２" && clas == "A" {
            completion("5A")
        } else if grade == "高２" && clas == "B" {
            completion("5B")
        } else if grade == "高３" && clas == "A" {
            completion("6A")
        } else if grade == "高３" && clas == "B" {
            completion("6B")
        }else if grade == "その他" && clas == "A" {
            completion("7A")
        } else if grade == "その他" && clas == "B" {
            completion("7B")
        } else if grade == "その他" && clas == "(manager)" {
            completion("manager")
        } else {
            print("学年・クラスを見直してください")
        }
    }

    
    func register() {
        
        getMyClass { collec in
            HUD.show(.progress, onView: self.view)
            
            guard let grade = self.gradeTextField.text else { return }
            guard let clas = self.classTextField.text else { return }
            guard let number = self.numberTextField.text else { return }
            guard let name = self.nameTextField.text else {return}
            guard let email = self.emailTextField.text else { return }
            guard let password = self.passwordTextField.text else { return }
            //let homeView = HomeViewController.self
            
            Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
                if let err = err {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        HUD.hide { (_) in
                            HUD.flash(.error, onView: self.view, delay: 2)
                        }
                    }
                    return
                }
                
                guard let uid = res?.user.uid else { return }
                let docData = [
                    "collec": collec,
                    "grade": grade,
                    "clas": clas,
                    "number": number,
                    "name": name,
                    "email": email,
                    "password": password,
                    //"createdAt": Timestamp()
                ]
                Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
                    if let err = err {
                        return
                    }
                    
                }
                Firestore.firestore().collection(collec).document(uid).setData(docData) { (err) in
                    if let err = err {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            HUD.hide { (_) in
                                HUD.flash(.error, onView: self.view)
                            }
                        }
                        return
                    }
                    
                    Auth.auth().signIn(withEmail: email, password: password)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        HUD.hide { (_) in
                            notifTest()
                            HUD.flash(.success, onView: self.view)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
//                                self.dismiss(animated: true, completion: nil)
                                crossTransition(storyBoardName: "Home")
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func showDialog() {
        let controller = UIAlertController(title: "パスワードの確認",
                                           message: "パスワードをもう一度入力してください。",
                                           preferredStyle: .alert)

        controller.addTextField { textField in
            textField.placeholder = "パスワード"
            textField.isSecureTextEntry = true
            textField.keyboardAppearance = .dark
        }

        let cancelAction = UIAlertAction(title: "キャンセル",
                                         style: .cancel, handler: nil)

        let buyAction = UIAlertAction(title: "次へ",
                                      style: .default, handler: { action in
            do {
                guard let password = self.passwordTextField.text else {return}
                if controller.textFields?.first?.text == password {
                    self.register()
                }
            }
        })

        controller.addAction(cancelAction)
        controller.addAction(buyAction)
        
        self.present(controller, animated: true, completion: nil)

//        completion(controller)
    }
    
    
    func setUpEnumsForGrades(){
        grades.append("")
        grades.append("中１")
        grades.append("中２")
        grades.append("中３")
        grades.append("高１")
        grades.append("高２")
        grades.append("高３")
        grades.append("その他")
        
        let pv1 = UIPickerView()
        pv1.tag = 1
        pv1.delegate = self
        pv1.dataSource = self
        
        gradeTextField.delegate = self
        gradeTextField.inputAssistantItem.leadingBarButtonGroups = []
        gradeTextField.inputView = pv1
        self.pickerViewForGrades = pv1
    }
    
    func setUpEnumsForClasses() {
        classes.append("")
        classes.append("A")
        classes.append("B")
        classes.append("(manager)")

        
        let pv2 = UIPickerView()
        pv2.tag = 2
        pv2.delegate = self
        pv2.dataSource = self
        
        classTextField.delegate = self
        classTextField.inputAssistantItem.leadingBarButtonGroups = []
        classTextField.inputView = pv2
        self.pickerViewForClasses = pv2
    }
    
    func setUpEnumsForNumbers() {
        numbers.append("")
        
        for i in 0..<30 {
            numbers.append(String(i + 1))
        }
        
        let pv3 = UIPickerView()
        pv3.tag = 3
        pv3.delegate = self
        
        numberTextField.delegate = self
        numberTextField.inputAssistantItem.leadingBarButtonGroups = []
        numberTextField.inputView = pv3
        self.pickerViewForNumbers = pv3
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return grades.count
        } else if pickerView.tag == 2 {
            return classes.count
        } else if pickerView.tag == 3{
            return numbers.count
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return grades[row]
        } else if pickerView.tag == 2{
            return classes[row]
        } else {
            return numbers[row]
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            gradeTextField.text = grades[row]
        } else if pickerView.tag == 2 {
            classTextField.text = classes[row]
        } else {
            numberTextField.text = numbers[row]
        }
    }
    
    
    @IBAction func signInButton(_ sender: Any) {
        if Auth.auth().currentUser?.uid == nil {
            modalToSignIn(style: .fullScreen)
        } else {
            modalToSignIn(style: .pageSheet)
        }
    }
    
    func modalToSignIn(style: UIModalPresentationStyle) {
        let storyboard = UIStoryboard(name: "SignIn", bundle: nil)
        let SignInViewController = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        let nav = UINavigationController(rootViewController: SignInViewController)
        nav.modalPresentationStyle = style
        self.present(nav, animated: true, completion: nil)
    }
    
    
}

extension SignUpViewController: UITextViewDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        print("textField.text: ", textField.text)
        let gradeIsEmpty = gradeTextField.text?.isEmpty ?? false
        let classIsEmpty = classTextField.text?.isEmpty ?? false
        let numberIsEmpty = numberTextField.text?.isEmpty ?? false
        let nameIsEmpty = nameTextField.text?.isEmpty ?? false
        let emailIsEmpty = emailTextField.text?.isEmpty ?? false
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? false
        
        if classIsEmpty || numberIsEmpty || nameIsEmpty || emailIsEmpty || passwordIsEmpty {
            registerButton.isEnabled = false
            registerButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100, alpha: 1)
        } else {
            registerButton.isEnabled = true
            registerButton.backgroundColor = .rgb(red: 162, green: 85, blue: 0, alpha: 1)
        }
    }
}
