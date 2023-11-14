//
//  OptionalMessageSenderViewController.swift
//  homelax-ultra
//
//  Created by Taisei Ogura on 2023/03/25.
//

import Foundation
import UIKit
import Firebase
import PKHUD
import IQKeyboardManagerSwift

var isAnonymous: Bool = false

class OptionalMessageSenderViewController: UIViewController {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    private var chatRooms = [ChatRoom]()
    private var candidateUids: [String]? = []
    private var candidates = [Candidate]()
    var partner: User?
    let homeViewController = HomeViewController()
    @IBOutlet weak var puclishLabel: UILabel!
    @IBOutlet weak var byCheckingLabel: UILabel!
    
    @IBOutlet var confirmLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var checkedImage = UIImage (named: "checkbox_true")!
    var uncheckedImage = UIImage(named: "checkbox_false")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getDefaultSelection {
            self.initButtons()
        }
        initNav()
        currentViewController = self
        currentViewControllerId = "OptionalMessageSender"
        self.textInit()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.nameLabel.text = (self.partner?.name ?? "error") + "さん"
        }
        
        if isDark {
            self.view.backgroundColor = backGroundColor_gray
            nameLabel.textColor = .white
            puclishLabel.textColor = .lightGray
            byCheckingLabel.textColor = .white
            checkedImage = UIImage (named: "checkbox_true_white")!
            uncheckedImage = UIImage(named: "checkbox_false_white")!
            confirmLabel.textColor = .white
            messageLabel.textColor = .white
        }
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
        }

        self.navigationItem.title = "選択中の相手"
        
        let leftBarButton = UIBarButtonItem(title: "〈 戻る", style: .plain, target: self, action: #selector(tappedButton))
        navigationItem.leftBarButtonItem = leftBarButton
        
        self.tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func getDefaultSelection(completion: @escaping () -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let db = Firestore.firestore().collection("users").document(uid).collection("settings").document(uid)
        db.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()?[defaultAno] as! Bool
                
                if data {
                    isAnonymous = false
                }else{
                    isAnonymous = true
                }
            } else {
                isAnonymous = true
                print("Document does not exist")
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            completion()
        })
    }
    
    private func textInit() {
        nameLabel.text = "loading..."
        messageLabel?.text = ""
        confirmLabel?.text = ""
    }
    
    @objc func tappedButton() {
        self.dismiss(animated: true)
    }
    
    func getPartnerInfo(completion:@escaping (User) -> Void) {
        let partnerInfo = partner
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(partnerInfo!)
        }
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        initButtons()
    }
    
    func initButtons() {
        if isAnonymous == false {
            isAnonymous = true
            self.imageView.image = checkedImage
            return
        } else {
            isAnonymous = false
            self.imageView.image = uncheckedImage
            return
        }
    }
    
    
    //MARK InputAccessory Setup
    private lazy var chatInputAccessoryView2: ChatInputAccessoryView2 = {
        let view = ChatInputAccessoryView2()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        view.delegate = self
        return view
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return chatInputAccessoryView2
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}

extension OptionalMessageSenderViewController: ChatInputAccessoryView2Delegate {
    func tappedSendButton(text: String) {
        
        var isSensitive: Bool = false
                NGs.forEach { NG in
                    if text.contains(NG) == true {
                        isSensitive = true
                    }
                }

        self.chatInputAccessoryView2.chatTextView.resignFirstResponder()
        self.chatInputAccessoryView2.removeText()
        self.chatInputAccessoryView2.chatTextView.endEditing(true)

        getPartnerInfo { [self] partnerInfo in

            func getAnonymosity(completion: @escaping (String) -> Void) {
                if isAnonymous == true {
                    completion("名前を公開して")
                } else {
                    completion("匿名で")
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                getAnonymosity { anonymousity in

                    if isSensitive == true {
                        let dialog = UIAlertController(title: "不適切な表現が検出されました。", message: "このまま送信すると、管理者がチェックをしたのちに送信します。よろしいですか？（または表現を変えてもう一度送ってください。）", preferredStyle: .alert)
                        dialog.addAction(UIAlertAction(title: "送信して管理者のチェックを受ける", style: .destructive,
                                                       handler: { action in
                            do {
                                print("text: ", text, "partnerName",partnerInfo.uid, "currentuerUid", Auth.auth().currentUser?.uid ?? "" )

                                guard let uidFrom = Auth.auth().currentUser?.uid else { return }
                                guard let uidTo = partnerInfo.uid else { return }

                                var theirClas: String = ""

                                let commands = Commands()
                                commands.getMyClass { theirClass in
                                    theirClas = theirClass
                                }

                                var fromName:String = ""

                                commands.getMyName { myName in
                                    fromName = myName
                                }

                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {

                                    /// DateFomatterクラスのインスタンス生成
                                    let dateFormatter = DateFormatter()

                                    /// カレンダー、ロケール、タイムゾーンの設定（未指定時は端末の設定が採用される）
                                    dateFormatter.calendar = Calendar(identifier: .gregorian)
                                    dateFormatter.locale = Locale(identifier: "ja_JP")
                                    dateFormatter.timeZone = TimeZone(identifier:  "Asia/Tokyo")

                                    /// 変換フォーマット定義（未設定の場合は自動フォーマットが採用される）
                                    dateFormatter.dateFormat = "yyyy/MM/dd-HH:mm:ss"

                                    /// データ変換（Date→テキスト）
                                    let timeStamp = dateFormatter.string(from: Date())

                                    var isPermitted: Bool = false

                                    let docData = [
                                        "createdAt": timeStamp,
                                        "theirClass": theirClas,
                                        "uidFrom": uidFrom,
                                        "fromName": fromName,
                                        "uidTo": uidTo + ".unchecked",
                                        "toName": partnerInfo.name,
                                        "message": text,
                                        "isAnonymous": isAnonymous,
                                        "isPermitted": isPermitted,
                                    ] as [String : Any]

                                    HUD.show(.progress, onView: self.view)

                                    Firestore.firestore().collection("uncheckedMessages").addDocument(data: docData) { (err) in
                                        if let err = err {
                                            print ("message情報の保存に失敗しました。\(err)")
                                            HUD.hide { (_) in
                                                HUD.flash(.error, onView: self.view)
                                            }
                                            return
                                        }

                                        print("message情報の保存に成功しました。")
                                        HUD.hide { (_) in
                                            HUD.flash(.success, onView: self.view)
                                        }
                                        self.confirmLabel.text = "ほめ言葉を受け付けました。このメッセージは管理者が確認した後に送られます。"
                                        self.messageLabel.text = text
                                    }
                                }
                            }
                        }))
                        dialog.addAction(UIAlertAction(title: "キャンセル", style: .default, handler: nil))

                        self.present(dialog, animated: true)
                    } else {
                        let dialog = UIAlertController(title: "メッセージを「\(anonymousity)」送信します。", message: "よろしいですか？", preferredStyle: .alert)
                        dialog.addAction(UIAlertAction(title: "送信", style: .default,
                                                       handler: { action in
                            do {
                                print("text: ", text, "partnerName",partnerInfo.uid, "currentuerUid", Auth.auth().currentUser?.uid ?? "" )

                                guard let uidFrom = Auth.auth().currentUser?.uid else { return }
                                guard let uidTo = partnerInfo.uid else { return }

                                var theirClas: String = ""

                                let commands = Commands()
                                commands.getMyClass { theirClass in
                                    theirClas = theirClass
                                }

                                var fromName:String = ""

                                commands.getMyName { myName in
                                    fromName = myName
                                }

                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {

                                    /// DateFomatterクラスのインスタンス生成
                                    let dateFormatter = DateFormatter()

                                    /// カレンダー、ロケール、タイムゾーンの設定（未指定時は端末の設定が採用される）
                                    dateFormatter.calendar = Calendar(identifier: .gregorian)
                                    dateFormatter.locale = Locale(identifier: "ja_JP")
                                    dateFormatter.timeZone = TimeZone(identifier:  "Asia/Tokyo")

                                    /// 変換フォーマット定義（未設定の場合は自動フォーマットが採用される）
                                    dateFormatter.dateFormat = "yyyy/MM/dd-HH:mm:ss"

                                    /// データ変換（Date→テキスト）
                                    let timeStamp = dateFormatter.string(from: Date())

                                    let docData = [
                                        "createdAt": timeStamp,
                                        "theirClass": theirClas,
                                        "uidFrom": uidFrom,
                                        "fromName": fromName,
                                        "uidTo": uidTo,
                                        "toName": partnerInfo.name,
                                        "message": text,
                                        "isAnonymous": isAnonymous,
                                    ] as [String : Any]

                                    HUD.show(.progress, onView: self.view)

                                    Firestore.firestore().collection("messages").addDocument(data: docData) { (err) in
                                        if let err = err {
                                            print ("message情報の保存に失敗しました。\(err)")
                                            HUD.hide { (_) in
                                                HUD.flash(.error, onView: self.view)
                                            }
                                            return
                                        }

                                        print("message情報の保存に成功しました。")
                                        HUD.hide { (_) in
                                            HUD.flash(.success, onView: self.view)
                                        }
                                        self.confirmLabel.text = "ほめ言葉を受け付けました。ありがとうございます。もしよかったら、直接伝えてみませんか？"
                                        self.messageLabel.text = text
                                    }
                                }
                            }
                        }))

                        dialog.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))

                        self.present(dialog, animated: true, completion: nil)
                        return
                    }

                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touched")
        self.chatInputAccessoryView2.chatTextView.resignFirstResponder()
    }
    

}

