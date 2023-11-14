//
//  PendingMessagesViewController.swift
//  Homelax
//
//  Created by Taisei Ogura on 2023/03/19.
//

import Foundation
import UIKit
import PKHUD
import Firebase
import FirebaseAuth
import FirebaseFirestore

class PendingMessagesViewController: UIViewController {
    

    private var users = [User]()
    private var pendingMessages = [PendingMessage]()
    private var messagesToShow = [PendingMessage]()
//    private var messages = [Message]()
//    private var messagesToMe = [MessageToMe]()
    var message: String = ""
    var backButton: UIBarButtonItem!
    
    private let cellIdSub = "cellId-sub"
    

    @IBOutlet weak var pendingMessagesTableView: UITableView!
    
    override func viewDidLoad() {
                
        
        super.viewDidLoad()
        
        a {
            self.sortArray()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.pendingMessagesTableView.reloadData()
        }

    }
    
    func initNav() {
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            // NavigationBarの背景色の設定
            appearance.backgroundColor = UIColor.secondarySystemFill
            // NavigationBarのタイトルの文字色の設定
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        
        
        navigationController?.navigationBar.tintColor = .darkGray
        self.navigationItem.title = "Messages Pending"
        backButton = UIBarButtonItem(title: "home", style: .plain, target: self, action: #selector(tappedBackButton(_:)))
        self.navigationItem.leftBarButtonItem = backButton
        
        self.tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func a(completion: @escaping () -> Void) {
        pendingMessagesTableView.delegate = self
        pendingMessagesTableView.dataSource = self
        getPendingMessagesFromFirestore()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion()
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initNav()
    }

    
    private func getPendingMessagesFromFirestore() {
        Firestore.firestore().collection("uncheckedMessages").getDocuments { (snapshots, err) in
            if let err = err {
                print ("message情報の取得に失敗しました。\(err)")
                return
            }
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()

                let pendingMessage = PendingMessage.init(dic: dic)
                let messageToShow = PendingMessage.init(dic: dic)
                
                if pendingMessage.isPermitted == false {
                    self.messagesToShow.append(messageToShow)
                    messageToShow.docId = snapshot.documentID
                }
            
            })
        }
    }
    
    private func sortArray() {
        messagesToShow.sort(by: {a, b -> Bool in
            return a.createdAt > b.createdAt
        })
    }
    
    @IBAction func tappedReloadButton(_ sender: Any) {
        messagesToShow.removeAll()
        a {
            self.sortArray()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.pendingMessagesTableView.reloadData()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            HUD.hide { (_) in
                HUD.flash(.success, onView:  self.view, delay: 0.5)
            }
        }
    }
    
    @objc func tappedBackButton(_ sender: Any) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        
    }
    
    
    func presentDialog(dialog: UIAlertController) {
        print("Calm down dude \(dialog)")
        
        
        self.present(dialog, animated: true)

    }
    
    private func reload() {
        a {
            self.sortArray()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.pendingMessagesTableView.reloadData()
        }
    }
    
    
}


// MARK: UITableViewDelegate, UITableViewDataSource
extension PendingMessagesViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = pendingMessagesTableView.dequeueReusableCell(withIdentifier: cellIdSub, for: indexPath) as! PendingMessagesTableViewCell
        cell.messagesToShow = messagesToShow[indexPath.row]

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let cell = messageLogTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MessageLogTableViewCell
        let messag = messagesToShow[indexPath.row].message
    
        let storyboard = UIStoryboard.init(name: "SeeLongMessage", bundle: nil)
        let seeLongMessageViewController = storyboard.instantiateViewController(withIdentifier: "SeeLongMessageViewController") as? SeeLongMessageViewController
        let nav = UINavigationController(rootViewController: seeLongMessageViewController!)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: { () in
            seeLongMessageViewController!.longMessageTextView.text = messag
        })
    }
}


class PendingMessagesTableViewCell: UITableViewCell {

    var messagesToShow: PendingMessage? {
        didSet{
            messageLabel.text = messagesToShow?.message
            dateFromString { date in
                let formatter: DateFormatter = DateFormatter()
                formatter.dateFormat = "MM/dd"
                self.dateLabel.text = formatter.string(from: date)
            }
            if messagesToShow?.isAnonymous == true {
                nameLabel.text = (messagesToShow?.fromName ?? "匿名") + "さん"
                print("the name is:", messagesToShow?.fromName ?? "err")
            } else {
                nameLabel.text = "匿名"
            }
        }
    }
    
    func dateFromString (completion: (Date) -> Void) {
            let date = messagesToShow?.createdAt
            let formatter: DateFormatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .gregorian)
            formatter.locale = Locale(identifier: "ja_JP")
            formatter.dateFormat = "yyyy/MM/dd-HH:mm:ss"
        completion(formatter.date(from: date ?? Date().description)!)
    }

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func tappedApproveButton(_ sender: Any) {

        let docData = [
            "createdAt": self.messagesToShow?.createdAt,
            "theirClass": self.messagesToShow?.theirClass,
            "uidFrom": self.messagesToShow?.uidFrom,
            "fromName": self.messagesToShow?.fromName,
            "uidTo": self.messagesToShow?.uidTo.dropLast(10),
            "toName": self.messagesToShow?.toName,
            "message": self.messagesToShow?.message,
            "isAnonymous": self.messagesToShow?.isAnonymous
        ] as [String : Any]

        HUD.show(.progress)
        Firestore.firestore().collection("messages").addDocument(data: docData) { (err) in
            if let err = err {
                print ("message情報の保存に失敗しました。\(err)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    HUD.hide{(_) in
                        HUD.flash(.error)
                    }
                    return
                }
            } else {
                print("message情報の保存に成功しました。")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    HUD.hide{(_) in
                        HUD.flash(.success)
                    }
                    
                    Firestore.firestore().collection("uncheckedMessages").document(self.messagesToShow!.docId).delete()
                    
//                    PendingMessagesViewController().reload()
                    
                    return
                }
            }
        }
    }
    
    
}


