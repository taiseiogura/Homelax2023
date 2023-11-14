//
//
//  MessageLogViewController.swift
//  homeLux
//
//  Created by Taisei Ogura on 2022/10/23.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import PKHUD

class MessageLogViewController: UIViewController {
    
    private var users = [User]()
    private var messages = [Message]()
    private var messagesToMe = [MessageToMe]()
    private var ids: [String] = []
    var message: String = ""
    @IBOutlet weak var reloadButton: UIButton!
    
    private let cellId = "cellId"

    @IBOutlet var messageLogTableView: UITableView!

    @IBOutlet weak var bottomButtonView: BottomButtonView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        a {
            self.sortArray()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.messageLogTableView.reloadData()
        }
        
        bottomButtonView.messageLogButton.setBackgroundImage(giftImage_filled, for: .normal)

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
        
        
        self.navigationItem.title = "届いたメッセージ"
        self.tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func a(completion: @escaping () -> Void) {
        messageLogTableView.delegate = self
        messageLogTableView.dataSource = self
        getMessagesToMeFromFirestore()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initNav()
        currentViewController = self
        currentViewControllerId = "MessageLog"
        
        if isDark {
            self.view.backgroundColor = backGroundColor_gray
            messageLogTableView.backgroundColor = backGroundColor_gray
            reloadButton.titleLabel?.textColor = .lightGray
        }
    }
    
    
    private func getMessagesToMeFromFirestore() {
        Firestore.firestore().collection("messages").getDocuments { (snapshots, err) in
            if let err = err {
                print ("message情報の取得に失敗しました。\(err)")
                return
            }
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let message = Message.init(dic: dic)
                
                if message.uidTo == Auth.auth().currentUser?.uid {
                    self.ids.append(snapshot.documentID)
                }
            
            })
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
            self.ids.forEach { id in
                let db = Firestore.firestore().collection("messages").document(id)
                db.updateData(["documentId":id])
                
                db.getDocument { (document, err) in
                    if let err = err {
                        print ("message情報の取得に失敗しました。\(err)")
                        return
                    }
                    
                    let dic = document!.data()
                    let message = Message.init(dic: dic!)
                    let messageToMe = MessageToMe.init(dic: dic!)
                    
                    self.messagesToMe.append(messageToMe)
                }
                
            }
        })
    }
    
    private func sortArray() {
        messagesToMe.sort(by: {a, b -> Bool in
            return a.createdAt > b.createdAt
        })
    }
    
    @IBAction func tappedReloadButton(_ sender: Any) {
        messagesToMe.removeAll()
        messages.removeAll()
        ids.removeAll()
        
        a {
            self.sortArray()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.messageLogTableView.reloadData()
        }
        HUD.show(.progress)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            HUD.hide { (_) in
                HUD.flash(.success, onView:  self.view, delay: 0.5)
            }
        }
    }
    
    
}


// MARK: UITableViewDelegate, UITableViewDataSource
extension MessageLogViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesToMe.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messageLogTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MessageLogTableViewCell
        cell.messagesToMe = messagesToMe[indexPath.row]
        cell.id = ids[indexPath.row]
        
        if isDark {
            cell.backgroundColor = backGroundColor_gray
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let cell = messageLogTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MessageLogTableViewCell
        var messag = messagesToMe[indexPath.row].message
    
        let storyboard = UIStoryboard.init(name: "SeeLongMessage", bundle: nil)
        let seeLongMessageViewController = storyboard.instantiateViewController(withIdentifier: "SeeLongMessageViewController") as? SeeLongMessageViewController
        let nav = UINavigationController(rootViewController: seeLongMessageViewController!)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: { () in
            seeLongMessageViewController!.longMessageTextView.text = messag
        })
    }
}

class MessageLogTableViewCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var feedBack: Int = 0
    
    var pickerViewList: [String] = [
        "",
        "1. とてもうれしい",
        "2. うれしい",
        "3. どちらともいえない",
        "4. あまりうれしくない",
        "5. 不快だ"
    ]
    
    var messagesToMe: MessageToMe? {
        didSet{
            
            messageLabel.text = messagesToMe?.message
            dateFromString { date in
                let formatter: DateFormatter = DateFormatter()
                formatter.dateFormat = "MM/dd"
                self.dateLabel.text = formatter.string(from: date)
            }
            if messagesToMe?.isAnonymous == true {
                nameLabel.text = (messagesToMe?.fromName ?? "匿名") + "さん"
                print("the name is:", messagesToMe?.fromName ?? "err")
            } else {
                nameLabel.text = "匿名さん"
            }
            
            if isDark {
                dateLabel.textColor = .white
                nameLabel.textColor = .white
                messageLabel.textColor = .white
            }
            
            if messagesToMe?.feedBack == 0 {
                enableButton()
            } else {
                disableButton()
            }
        }
    }
    
    var id: String? {
        didSet{
            
        }
    }
    
    func enableButton() {
        feedBackButton.isEnabled = true
        feedBackButton.backgroundColor = UIColor.rgb(red: 0, green: 116, blue: 178, alpha: 0.7)
        feedBackButton.layer.cornerRadius = 10
        feedBackButton.tintColor = .white
    }
    
    func disableButton() {
        feedBackButton.isEnabled = false
        feedBackButton.layer.cornerRadius = 10
        feedBackButton.backgroundColor = .lightGray
        feedBackButton.tintColor = .white
    }
    
    func dateFromString (completion: (Date) -> Void) {
            let date = messagesToMe?.createdAt
            let formatter: DateFormatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .gregorian)
            formatter.locale = Locale(identifier: "ja_JP")
            formatter.dateFormat = "yyyy/MM/dd-HH:mm:ss"
        completion(formatter.date(from: date ?? Date().description)!)
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet weak var feedBackButton: UIButton!
    
    var selectedRow = 0
    
    @IBAction func feedBackButton(_ sender: Any) {
        self.disableButton()
        
        let controller = UIAlertController(title: "このほめ言葉についてどう感じましたか", message: "\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        
        let pv = UIPickerView(frame: CGRect(x: 0, y: 70, width: 270, height: 162))
        pv.delegate = self
        pv.dataSource = self

    // comment this line to use white color
       pv.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)

       controller.view.addSubview(pv)

       let action = UIAlertAction(title: "送信", style: UIAlertAction.Style.default) { _ in
           HUD.show(.progress, onView: currentViewController.view)
           print("ROW: \(self.feedBack)")
           if self.feedBack == 0 {
               self.enableButton()
               HUD.hide()
               return
           } else {
               guard let id = self.messagesToMe?.documentId else {return}
               let db = Firestore.firestore().collection("messages").document(id)
               db.updateData(["feedBack" : self.feedBack])
               DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                   HUD.hide{ (_) in
                       HUD.flash(.success, onView: currentViewController.view)
                   }
               })
           }
           
       }
        let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: {_ in
            self.enableButton()
        })


       controller.addAction(action)
       controller.addAction(cancelAction)

        currentViewController.present(controller, animated: true, completion: {
            pv.frame.size.width = controller.view.frame.size.width
        })
               
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerViewList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerViewList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        feedBack = row
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func getHasFbedFromFirebase(){
//        let db = Firestore.firestore()

//        let tokenArray: [String: Any] = ["token": token]
//        let timeStamp: [String: Timestamp] = ["time": Timestamp()]

//        db.collection("tokens").document(messagesToMe.documentID).setData(dic)


//        guard let uid = Auth.auth().currentUser?.uid else {return}
//        db.collection("users").document(uid).collection("tokens").document(token).setData(dic)
    }
}

extension MessageLogTableViewCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
}


