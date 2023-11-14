//
//  MessageSenderViewController.swift
//  homelax-ultra
//
//  Created by Taisei Ogura on 2023/03/25.
//

import UIKit
import PKHUD
import IQKeyboardManagerSwift
import Firebase

//var chatRoomUid: String = ""

var chatRoomCreatedAt: Timestamp = Timestamp()
let homeViewController = HomeViewController()
var isSelected: Bool = false
let defaultAno: String = "デフォルトの匿名性"

class MessageSenderViewController: UIViewController {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    private var chatRooms = [ChatRoom]()
    private var candidateUids: [String]? = []
    private var candidates = [Candidate]()
    @IBOutlet weak var puclishLabel: UILabel!
    @IBOutlet weak var byCheckingLabel: UILabel!
    @IBOutlet weak var reloadButton: UIButton!
    
    var checkedImage = UIImage (named: "checkbox_true")!
    var uncheckedImage = UIImage(named: "checkbox_false")!
    
    
    private var partnerName: String = ""
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet var confirmLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchChatRoomInfoFromFirestore {
            self.chooseLatest { partnerName in
                self.nameLabel.text = partnerName + "さん"
            }
        }
        self.textInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        currentViewController = self
        currentViewControllerId = "MessageList"
        initNav()
        getDefaultSelection {
            self.initButtons()
        }
        
        checkDarkMode()
        
        if isDark {
            self.reloadButton.tintColor = .gray
            self.view.backgroundColor = backGroundColor_gray
            self.nameLabel.textColor = .white
            self.puclishLabel.textColor = .lightGray
            self.byCheckingLabel.textColor = .white
            checkedImage = UIImage (named: "checkbox_true_white")!
            uncheckedImage = UIImage(named: "checkbox_false_white")!
            confirmLabel.textColor = .white
            messageLabel.textColor = .white
        }
    }
    
    
    
    func getDefaultSelection(completion: @escaping() -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let db = Firestore.firestore().collection("users").document(uid).collection("settings").document(uid)
        db.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()?[defaultAno] as! Bool
                
                if data {
                    isSelected = false
                }else{
                    isSelected = true
                }
            } else {
                isSelected = true
                print("Document does not exist")
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            completion()
        })
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

        self.navigationItem.title = "今日の相手"

        
        self.tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func textInit() {
        nameLabel?.text = "Loading..."
        messageLabel?.text = ""
        confirmLabel?.text = ""
    }
    
    func fetchChatRoomInfoFromFirestore(completion: @escaping () -> Void){
        Firestore.firestore().collection("chatRooms").getDocuments { (snapshots,err) in
            if let err = err {
                print("chatroom情報の取得に失敗しました。\(err)")
                return
            }
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let chatRoom = ChatRoom.init(dic: dic)
                let candidate = Candidate.init(dic: dic)
                chatRoom.uid = snapshot.documentID
                
                guard let myUid = Auth.auth().currentUser?.uid else { return }
                
                
                if myUid == chatRoom.members?[0] ?? "0" {
                    self.candidates.append(candidate)
                }
                print("AAAA",candidate.names?[1] ?? "err", self.candidates.count)
            })
            completion()
        }
    }
    
    func chooseLatest(completion:@escaping(String) -> Void) {
        print("CAND-NUM\(candidates.count)")
        var latestCandidateNum: Int = 0
        if candidates.count >= 1 {
            for n in 0...candidates.count - 1 {
                if n == 0 {
                    partnerName = candidates[0].names?[1] ?? ""
                    latestCandidateNum = 0
                    
                } else {
                    
                    if candidates[latestCandidateNum].createdAt.dateValue() < candidates[n].createdAt.dateValue() {
//                        nameLabel.text = (candidates[n].names?[1] ?? "") + "さん"
                        latestCandidateNum = n
                        partnerName = candidates[n].names?[1] ?? ""
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completion(self.partnerName)
            }
        }
    }
    
    func getPartnerUid(completion: @escaping (String) -> Void) {
        var partnerUid: String = ""
        print("CAND-NUM\(candidates.count)")
        var latestCandidateNum: Int = 0
        if candidates.count >= 1 {
            for n in 0...candidates.count - 1 {
                if n == 0 {
                    partnerUid = candidates[n].members?[1] ?? "error"
                } else {
                    if candidates[latestCandidateNum].createdAt.dateValue() < candidates[n].createdAt.dateValue() {
                        partnerUid = candidates[n].members?[1] ?? "error"
                        latestCandidateNum = n
                    }
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            completion(partnerUid)
        }
    }

    
    @IBAction func buttonTapped(_ sender: Any) {
        initButtons()
    }
    
    func initButtons() {
        if isSelected == false {
            isSelected = true
            self.imageView.image = checkedImage
        } else {
            isSelected = false
            self.imageView.image = uncheckedImage
        }
    }
    
    
    
    @IBAction func reloadButton(_ sender: Any) {
        candidates.removeAll()

        self.fetchChatRoomInfoFromFirestore {
            self.chooseLatest { partnerName in
                self.nameLabel.text = partnerName + "さん"
            }
        }
    }
    
    
    //MARK AccessoriesSetUps
    private lazy var chatInputAccessoryView: ChatInputAccessoryView = {
        let view = ChatInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        view.delegate = self
        
        return view
    }()
    
    func resizeInputView(){
        
    }

    
    override var inputAccessoryView: UIView? {
        get {
            return chatInputAccessoryView
        }
    }
    
    
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}

extension MessageSenderViewController: ChatInputAccessoryViewDelegate {
    
    
    
    func tappedSendButton(text: String) {
        var NG: Bool = false
        print(isSelected)
        NGs.forEach { NGWord in
            if text.contains(NGWord) == true {
                NG = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            func getAnonymosity(completion: @escaping (String) -> Void) {
                if isSelected == true {
                    completion("名前を公開して")
                } else {
                    completion("匿名で")
                }
            }


            getAnonymosity { isAnonymous in

                    if NG == true {
                        let dialog = UIAlertController(title: "不適切な表現が検出されました。", message: "このまま送信すると、管理者がチェックをしたのちに送信します。よろしいですか？（フィルタリングを厳しめに設定しています。表現を変えてもう一度送ってくださると嬉しいです。）", preferredStyle: .alert)
                        dialog.addAction(UIAlertAction(title: "送信して管理者のチェックを受ける", style: .destructive,
                                                       handler: { action in
                            do {
                                self.getPartnerUid { partnerUid in
                                    self.chooseLatest { partnerName in
                                        self.chatInputAccessoryView.chatTextView.resignFirstResponder()
                                        self.chatInputAccessoryView.removeText()
                                        //        chatInputAccesoryView.chatTextView.endEditing(true)
                                        HUD.show(.progress, onView: self.view)
                                        print("text: ", text)

                                        guard let uidFrom = Auth.auth().currentUser?.uid else { return }
                                        //            guard let fromName =
                                        let toName = partnerName
                                        var fromName: String = ""
                                        /// DateFomatterクラスのインスタンス生成
                                        let dateFormatter = DateFormatter()

                                        /// カレンダー、ロケール、タイムゾーンの設定（未指定時は端末の設定が採用される）
                                        dateFormatter.calendar = Calendar(identifier: .gregorian)
                                        dateFormatter.locale = Locale(identifier: "ja_JP")
                                        dateFormatter.timeZone = TimeZone(identifier:  "Asia/Tokyo")

                                        /// 変換フォーマット定義（未設定の場合は自動フォーマットが採用される）
                                        dateFormatter.dateFormat = "yyyy/MM/dd-HH:mm:ss"

                                        var theirClas: String = ""

                                        let commands = Commands()
                                        commands.getMyClass { theirClass in
                                            theirClas = theirClass
                                        }

                                        /// データ変換（Date→テキスト）
                                        let timeStamp = dateFormatter.string(from: Date())

                                        commands.getMyName { myName in
                                            fromName = myName
                                        }

                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {

                                            let docData = [
                                                "createdAt": timeStamp,
                                                "theirClass": theirClas,
                                                "fromName": fromName,
                                                "uidFrom": uidFrom,
                                                "toName": toName,
                                                "uidTo": partnerUid + ".unchecked",
                                                "message": text,
                                                "isAnonymous": isSelected,
                                                "feedBack": 0
                                            ] as [String : Any]

                                            Firestore.firestore().collection("uncheckedMessages").addDocument(data: docData) { (err) in
                                                if let err = err {
                                                    print ("message情報の保存に失敗しました。\(err)")

                                                    HUD.hide { (_) in
                                                        HUD.flash(.error, onView: self.view)
                                                    }
                                                    self.confirmLabel.text = "ほめ言葉の送信に失敗しました。もう一度送信してください。"
                                                    self.messageLabel.text = "error"

                                                    return
                                                }

                                                print("message情報の保存に成功しました。")
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                    HUD.hide { (_) in
                                                        HUD.flash(.success, onView: self.view)
                                                    }
                                                    self.confirmLabel.text = "ほめ言葉を受け付けました。このメッセージは管理者が確認した後に送られます。"
                                                    self.messageLabel.text = text
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }))
                        dialog.addAction(UIAlertAction(title: "キャンセル", style: .default, handler: nil))

                        self.present(dialog, animated: true)

                    } else {
                        let dialog = UIAlertController(title: "メッセージを「\(isAnonymous)」送信します。", message: "よろしいですか？", preferredStyle: .alert)
                        dialog.addAction(UIAlertAction(title: "送信", style: .default,
                          handler: { action in
                            do {

                                self.getPartnerUid { partnerUid in
                                    self.chooseLatest { partnerName in
                                        self.chatInputAccessoryView.chatTextView.resignFirstResponder()
                                        self.chatInputAccessoryView.removeText()
                                        //        chatInputAccesoryView.chatTextView.endEditing(true)
                                        HUD.show(.progress, onView: self.view)
                                        print("text: ", text)

                                        guard let uidFrom = Auth.auth().currentUser?.uid else { return }
                                        //            guard let fromName =
                                        let toName = partnerName
                                        var fromName: String = ""
                                        /// DateFomatterクラスのインスタンス生成
                                        let dateFormatter = DateFormatter()

                                        /// カレンダー、ロケール、タイムゾーンの設定（未指定時は端末の設定が採用される）
                                        dateFormatter.calendar = Calendar(identifier: .gregorian)
                                        dateFormatter.locale = Locale(identifier: "ja_JP")
                                        dateFormatter.timeZone = TimeZone(identifier:  "Asia/Tokyo")

                                        /// 変換フォーマット定義（未設定の場合は自動フォーマットが採用される）
                                        dateFormatter.dateFormat = "yyyy/MM/dd-HH:mm:ss"

                                        var theirClas: String = ""

                                        let commands = Commands()
                                        commands.getMyClass { theirClass in
                                            theirClas = theirClass
                                        }

                                        /// データ変換（Date→テキスト）
                                        let timeStamp = dateFormatter.string(from: Date())

                                        commands.getMyName { myName in
                                            fromName = myName
                                        }

                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {

                                            let docData = [
                                                "createdAt": timeStamp,
                                                "theirClass": theirClas,
                                                "fromName": fromName,
                                                "uidFrom": uidFrom,
                                                "toName": toName,
                                                "uidTo": partnerUid,
                                                "message": text,
                                                "isAnonymous": isSelected,
                                            ] as [String : Any]

                                            Firestore.firestore().collection("messages").addDocument(data: docData) { (err) in
                                                if let err = err {
                                                    print ("message情報の保存に失敗しました。\(err)")

                                                    HUD.hide { (_) in
                                                        HUD.flash(.error, onView: self.view)
                                                    }
                                                    self.confirmLabel.text = "ほめ言葉の送信に失敗しました。もう一度送信してください。"
                                                    self.messageLabel.text = "error"

                                                    return
                                                }

                                                print("message情報の保存に成功しました。")
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                    HUD.hide { (_) in
                                                        HUD.flash(.success, onView: self.view)
                                                    }
                                                    self.confirmLabel.text = "ほめ言葉を受け付けました。ありがとうございます。もしよかったら、直接伝えてみませんか？"
                                                    self.messageLabel.text = text

            //                                        Messaging.messaging().send
                                                }
                                            }
                                        }
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touched")
        self.chatInputAccessoryView.chatTextView.resignFirstResponder()
    }
}
