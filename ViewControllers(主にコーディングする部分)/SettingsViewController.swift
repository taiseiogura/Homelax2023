//
//  Setting.swift
//  homelax-ultra
//
//  Created by Taisei Ogura on 2023/03/28.
//

import Foundation
import UIKit
import Firebase
import PKHUD

var nameToSave: String = ""
var isSet: Bool = false
var hasChangeds: [Bool] = []
var nameHasChanged: Bool = false
var originalName: String = ""

var needNotifSet: Bool = false


var valueToSave: [(Bool, String)] = []
var indSettings: [(Bool, String)] = []

class SettingsViewController: UIViewController {
    
    //
    //    var result: Bool = false
    
    private let cellId = "cellIdForSettings"
    
    @IBOutlet weak var bottomButtonView: BottomButtonView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var settingLabel: UILabel!
    
    var isNotifAuthorized: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isDark {
            self.view.backgroundColor = backGroundColor_gray
            nameLabel.textColor = .white
            settingLabel.textColor = .white
            settingsTableView.backgroundColor = backGroundColor_gray
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        valueToSave.removeAll()
        indSettings.removeAll()
        settings.removeAll()
        
        checkDarkMode()
        
        //        self.bottomButtonView.removeFromSuperview()
        self.bottomButtonView.loadNib()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.bottomButtonView.loadNib()
            
            if isDark {
                self.view.backgroundColor = backGroundColor_gray
                self.nameLabel.textColor = .white
                self.settingLabel.textColor = .white
                self.settingsTableView.backgroundColor = backGroundColor_gray
                self.initNav()
                self.settingsTableView.reloadData()
            } else {
                self.view.backgroundColor = UIColor.rgb(red: 229, green: 211, blue: 177, alpha: 1)
                self.nameLabel.textColor = .black
                self.settingLabel.textColor = .black
                self.settingsTableView.backgroundColor = UIColor.rgb(red: 229, green: 211, blue: 177, alpha: 1)
                self.initNav()
                self.settingsTableView.reloadData()
            }
            
            self.bottomButtonView.settingButton.setBackgroundImage(settingImage_filled, for: .normal)
        })
        
        currentViewController = self
        currentViewControllerId = "Settings"
        
        getNotifStatus {
        }
        
        bottomButtonView.settingButton.setBackgroundImage(settingImage_filled, for: .normal)
        
        needNotifSet = false
        
        nameToSave = ""
        originalName = ""
        
        Commands().getSettingsArray {
            self.initDics()
        }
        
        Commands().getMyName { myName in
            self.nameLabel.text = myName + " さん"
            originalName = myName
        }
        
        initNav()
        
        nameHasChanged = false
        
        
        settingsTableView.tableFooterView = UIView()
        
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        
        HUD.show(.progress, onView: self.view)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.settingsTableView.reloadData()
            HUD.hide()
        }
        
        setButton()
    }
    
    func initNav() {
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            
            // NavigationBarの背景色の設定
            if isDark {
                appearance.backgroundColor = backGroundColor_gray
                appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
                navigationController?.navigationBar.tintColor = .lightGray
                
            } else {
                appearance.backgroundColor = UIColor.rgb(red: 229, green: 211, blue: 177, alpha: 1)
                //              NavigationBarのタイトルの文字色の設定
                appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
                navigationController?.navigationBar.tintColor = .darkGray
            }
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        
        self.navigationItem.title = "設定"
        
        self.tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func initDics() {
        let int: Int = settings.count
        
        //        hasChanges
        for var n in 0..<int {
            hasChangeds.append(false)
            n += n
        }
        
        //        valueToSave
        //        indSettings
        checkFirebaseStatus()
    }
    
    @IBAction func tappedEditNameButton(_ sender: Any) {
        showDialog()
    }
    
    func saveToFirebase(completion:@escaping () -> Void) {
        if hasChangeds.contains(true) {
            
            print(valueToSave)
            
            guard let uid = Auth.auth().currentUser?.uid else {return}
            let db = Firestore.firestore().collection("users").document(uid).collection("settings").document(uid)
            
            db.getDocument { (document, err) in
                if let document = document, document.exists {
                    valueToSave.forEach { (bool, name) in
                        db.updateData([name:bool])
                    }
                } else {
                    var dic: [String : Any] = [:]
                    valueToSave.forEach { (bool, name) in
                        dic.updateValue(bool, forKey: name)
                    }
                    print("INITIALIZING SETTING DATA")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        db.setData(dic)
                    })
                }
            }
        }
        
        if nameHasChanged {
            Commands().getMyClass { myClass in
                guard let uid = Auth.auth().currentUser?.uid else {return}
                let db = Firestore.firestore()
                
                db.collection(myClass).document(uid).updateData(["name":nameToSave])
                db.collection("users").document(uid).updateData(["name":nameToSave])
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            completion()
        }
    }
    
    func checkFirebaseStatus() {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let db = Firestore.firestore().collection("users").document(uid).collection("settings").document(uid)
        
        db.getDocument { snap, err in
            if let err = err {
                print("Fatal Error: \(err)")
            }
            
            setDics()
        }
        
        func setDics() {
            valueToSave.removeAll()
            indSettings.removeAll()
            
            let i = settings.count
            
            for var n in 0 ..< i {
                print("SETTINGS: \(settings[n].settingName)")
                n = n + 1
            }
            
            initArray {
                for var n in 0 ..< i {
                    
                    print("INDSETTINGS: \(indSettings)")
                    let name = settings[n].settingName
                    
                    if indSettings.count < n + 1 || hasChangeds.count < n + 1 {
                        showDialog2()
                    } else {
                        if name == "通知" {
                            if self.isNotifAuthorized == true {
                                indSettings[n] = (true, name)
                                valueToSave[n] = (true, name)
                            } else {
                                indSettings[n] = (false, name)
                                valueToSave[n] = (false, name)
                            }
                            print(valueToSave)
                        } else {
                            
                            db.getDocument { (document, error) in
                                if let document = document, document.exists {
                                    print("BOOL VALUE", document.data()?[name] as! Bool)
                                    let data = document.data()?[name] as! Bool
                                    
                                    indSettings[n] = (data, name)
                                    valueToSave[n] = (data, name)
                                    
                                } else {
                                    print("Document does not exist")
                                    indSettings[n] = (false, name)
                                    valueToSave[n] = (false, name)
                                }
                                
                            }
                            
                            print(name)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                                n = n + 1
                            })
                        }
                        
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                            
                            print(indSettings)
                            print(valueToSave)
                        })
                        
                    }
                }
            }
            
            
            func initArray(completion: @escaping () -> Void) {
                let i = settings.count
                
                for var n in 0 ..< i {
                    let name = settings[n].settingName
                    
                    indSettings.append((false, name))
                    valueToSave.append((false, name))
                    
                    n = n + 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                    completion()
                })
            }
            
        }
    }
        
        func showDialog() {
            let controller = UIAlertController(title: "名前の変更",
                                               message: "新しく登録する名前を記入してください。（フルネーム：苗字と名前の間はスペースなし）",
                                               preferredStyle: .alert)
            
            controller.addTextField { textField in
                Commands().getMyName { myName in
                    textField.placeholder = myName
                }
                textField.keyboardAppearance = .dark
            }
            
            let cancelAction = UIAlertAction(title: "キャンセル",
                                             style: .cancel, handler: nil)
            
            let buyAction = UIAlertAction(title: "次へ",
                                          style: .default, handler: { action in
                do {
                    
                    guard let text = controller.textFields?.first?.text else {return}
                    
                    if text == "" {
                        return
                    }
                    nameToSave = text
                    
                    if nameToSave != originalName {
                        self.nameLabel.text = text
                        nameHasChanged = true
                        self.nameLabel.textColor = UIColor.rgb(red: 255, green: 120, blue: 130, alpha: 1)
                    } else if nameToSave == originalName {
                        self.nameLabel.text = text + " さん"
                        nameHasChanged = false
                        self.nameLabel.textColor = .black
                    }
                    
                    
                    self.setButton()
                }
            })
            
            controller.addAction(cancelAction)
            controller.addAction(buyAction)
            
            self.present(controller, animated: true, completion: nil)
            
            //        completion(controller)
        }
        
        @IBAction func logOutButton(_ sender: Any) {
            let dialog = UIAlertController(title: "ログアウト", message: "再度ログインするにはパスワードが必要です。", preferredStyle: .alert)
            dialog.addAction(UIAlertAction(title: "ログアウトする", style: .destructive,
                                           handler: { action in
                do {
                    try Auth.auth().signOut()
                    crossTransition(storyBoardName: "SignIn")
                    
                } catch {
                    print("ログアウトに失敗しました。\(error)")
                }
            }))
            dialog.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
            // 生成したダイアログを実際に表示します
            self.present(dialog, animated: true, completion: nil)
        }
        
        @IBAction func tappedSaveButton(_ sender: Any) {
            saveButton.isEnabled = false
            saveButton.tintColor = .lightGray
            
            let settingsViewController = SettingsViewController()
            
            HUD.show(.progress, onView: currentViewController.view)
            settingsViewController.saveToFirebase {
                
                print("NEED?: \(needNotifSet)")
                
                if needNotifSet {
                    let dialog = UIAlertController(title: "通知の設定", message: "通知の設定画面にうつります。", preferredStyle: .alert)
                    dialog.addAction(UIAlertAction(title: "次へ", style: .destructive,
                                                   handler: { action in
                        do {
                            hiding()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                if let url = URL(string:"app-settings:path=" + (Bundle.main.bundleIdentifier ?? "")) {
                                    if #available(iOS 10.0, *) {
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    } else {
                                        UIApplication.shared.openURL(url)
                                    }
                                }
                            }
                        }
                    }))
                    dialog.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { action in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            HUD.hide { (_) in
                                HUD.flash(.error, onView: currentViewController.view)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                
                                crossTransition(storyBoardName: "Settings")
                            }
                        }
                    }))
                    // 生成したダイアログを実際に表示します
                    self.present(dialog, animated: true, completion: nil)
                    
                } else {
                    hiding()
                }
                
                func hiding() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        HUD.hide { (_) in
                            HUD.flash(.success, onView: currentViewController.view)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            crossTransition(storyBoardName: "Settings")
                        }
                    }
                }
            }
        }
        
        
        @objc func setButton(){
            print("1")
            print(indSettings)
            
            if hasChangeds.contains(true) || nameHasChanged == true {
                self.saveButton.isEnabled = true
                self.saveButton.tintColor = UIColor.rgb(red: 0, green: 116, blue: 178, alpha: 1)
            } else {
                self.saveButton.isEnabled = false
                self.saveButton.tintColor = .lightGray
            }
        }
        
        func getNotifStatus(completion: () -> Void) {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                
                switch settings.authorizationStatus {
                case .authorized:
                    self.isNotifAuthorized = true
                    
                case .denied:
                    self.isNotifAuthorized = false
                    
                default:
                    self.isNotifAuthorized = false
                }
            }
            completion()
        }
        
    }
    
    extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 80
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            //        return settings.count
            return settings.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = settingsTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SettingsTableViewCell
            let cellSelectedBgView = UIView()
            
            if isDark {
                cellSelectedBgView.backgroundColor = backGroundColor_gray
            } else {
                cellSelectedBgView.backgroundColor = UIColor.rgb(red: 229, green: 211, blue: 177, alpha: 1)
            }
            cell.selectedBackgroundView = cellSelectedBgView
            cell.viewController = self
            
            let num = indexPath.row + 1
            if settings.count <  num || indSettings.count < num || hasChangeds.count < indexPath.row + 1 {
                showDialog2()
            } else {
                cell.settings = settings[indexPath.row]
                cell.indSetting = indSettings[indexPath.row]
                cell.hasChanged = hasChangeds[indexPath.row]
                cell.int = indexPath.row
                
                if isDark {
                    cell.backgroundColor = backGroundColor_gray
                }
            }
            
            return cell
            
        }
        
        
    }
    
    func showDialog2() {
        let controller = UIAlertController(title: "読み込みエラー",
                                           message: "もう一度読み込み直してください m(__)m",
                                           preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "ホームにもどる", style: .default, handler: {_ in
            crossTransition(storyBoardName: "Home")
        }))
        
        currentViewController.present(controller, animated: true)
    }
    
    
    
    class SettingsTableViewCell: UITableViewCell {
        
        @IBOutlet weak var label: UILabel!
        @IBOutlet weak var segmentControl: UISegmentedControl!
        
        weak var viewController: SettingsViewController?
        
        var int: Int? {
            didSet {
                
            }
        }
        
        var settings: Setting? {
            didSet {
                label.text = settings?.settingName
                // 設定するセグメントの文字列を格納する[String]
                let titles = [settings?.segmentToolFirstWord, settings?.segmentToolSecondWord]
                
                // storyboard上で設定されているセグメントを一旦全削除
                segmentControl.removeAllSegments()
                
                // titlesで作成した文字列でセグメントを設定
                for (i, title) in titles.enumerated() {
                    segmentControl.insertSegment(withTitle: title, at: i, animated: false)
                }
                
                // 最初に選択されているセグメントを指定
                //            segmentControl.selectedSegmentIndex = 0
                
                //            // tintColorの設定
                //            segmentControl.tintColor = .blue
                
                //            // 背景色を設定
                //            segmentControl.backgroundColor = .yellow
                //
                // 選択されているセグメントのTintColor
                segmentControl.selectedSegmentTintColor = .white
                //
                //            // 選択されているセグメントの文字色
                segmentControl.setTitleTextAttributes( [.foregroundColor: UIColor.black], for: .selected)
                
                // 選択されていないセグメントの文字色
                segmentControl.setTitleTextAttributes( [.foregroundColor: UIColor.gray], for: .normal)
                
                if isDark {
                    label.textColor = .white
                }
            }
        }
        
        var indSetting: (Bool?, String?) {
            didSet {
                if indSetting.0 == true {
                    segmentControl.selectedSegmentIndex = 0
                } else if indSetting.0 == false {
                    segmentControl.selectedSegmentIndex = 1
                } else {
                    print("ERR setting segment control")
                }
            }
        }
        
        var hasChanged: Bool? {
            didSet{
                
            }
        }
        
        @IBAction func tappedInfoButton(_ sender: Any) {
            let storyboad = UIStoryboard(name: "SeeLongMessage", bundle: nil)
            let seeLongMessageViewController = storyboad.instantiateViewController(withIdentifier: "SeeLongMessageViewController") as? SeeLongMessageViewController
            let nav = UINavigationController(rootViewController: seeLongMessageViewController!)
            nav.modalPresentationStyle = .pageSheet
            currentViewController.present(nav, animated: true, completion: { () in
                seeLongMessageViewController!.longMessageTextView.text = self.settings?.longMessage
            })
        }
        
        
        @IBAction func segmentToolValueChanged(_ sender: Any) {
            var ifTrue: Bool?
            
            
            guard let i = int else {return}
            
            
            if segmentControl.selectedSegmentIndex.self == 0 {
                ifTrue = true
                valueToSave[i].0 = ifTrue ?? true
                valueToSave[i].1 = settings?.settingName ?? "error"
            } else if segmentControl.selectedSegmentIndex.self == 1 {
                ifTrue = false
                valueToSave[i].0 = ifTrue ?? true
                valueToSave[i].1 = settings?.settingName ?? "error"
            } else {
                print("ERROR of segmentControl")
            }
            
            if valueToSave[i].0 != indSettings[i].0 {
                segmentControl.selectedSegmentTintColor = UIColor.rgb(red: 244, green: 166, blue: 156, alpha: 1)
                hasChangeds[i] = true
                
                if settings?.settingName == "通知" {
                    print("SETTING_TO_TRUE")
                    needNotifSet = true
                }
                
            } else {
                segmentControl.selectedSegmentTintColor = .white
                hasChangeds[i] = false
                
                if settings?.settingName == "通知" {
                    print("SETTING_TO_FALSE")
                    needNotifSet = false
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.viewController?.setButton()
            }
            
        }
        
        
        override func awakeFromNib() {
            super.awakeFromNib()
        }
    }

