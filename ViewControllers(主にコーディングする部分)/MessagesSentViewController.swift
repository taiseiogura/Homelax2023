//
//  MessagesSentViewController.swift
//  Homelax
//
//  Created by Taisei Ogura on 2023/01/24.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import PKHUD


class MessagesSentViewController: UIViewController {
    
    private var messages = [Message]()
    private var messagesFromMe = [MessageFromMe]()
    @IBOutlet weak var reloadButton: UIButton!
    
    @IBOutlet weak var bottomButtonView: BottomButtonView!
    let cellId = "cellId2"
    
    @IBOutlet weak var messagesSentTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNav()
        currentViewController = self
        currentViewControllerId = "MessagesSent"
        a {
            self.messagesSentTableView.reloadData()
        }
        
        bottomButtonView.messagesSentButton.setBackgroundImage(bellImage_filled, for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        currentViewController = self
        currentViewControllerId = "MessagesSent"
        
        if isDark {
            self.view.backgroundColor = backGroundColor_gray
            messagesSentTableView.backgroundColor = backGroundColor_gray
            reloadButton.titleLabel?.textColor = .lightGray
        }
    }
    
//    func initCollection
    
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
        

        self.navigationItem.title = "送ったメッセージ"
        self.tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func a(completion: @escaping () -> Void) {
        messagesSentTableView.delegate = self
        messagesSentTableView.dataSource = self
        getMessages()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion()
        }
    }
    
    func getMessages() {
        Firestore.firestore().collection("messages").getDocuments { (snapshots, err) in
            if let err = err {
                print ("message情報の取得に失敗しました。\(err)")
                return
            }
            
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let message = Message.init(dic: dic)
                let messageFromMe = MessageFromMe.init(dic: dic)
                
                if message.uidFrom == Auth.auth().currentUser?.uid {
                    self.messagesFromMe.append(messageFromMe)
                }
            
            })
        }
    }
    
    @IBAction func tappedReloadButton(_ sender: Any) {
        messagesSentTableView.reloadData()
        HUD.show(.progress)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            HUD.hide { (_) in
                HUD.flash(.success, onView:  self.view, delay: 0.5)
            }
        }
    }
}

extension MessagesSentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesFromMe.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messagesSentTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MessageSentTableViewCell
        cell.messagesFromMe = messagesFromMe[indexPath.row]
        
        if isDark {
            cell.backgroundColor = backGroundColor_gray
        }

//        cell.contentView.backgroundColor = backGroundColor_gray
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let cell = messagesSentTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MessageSentTableViewCell
        let messag = messagesFromMe[indexPath.row].message
    
        let storyboard = UIStoryboard.init(name: "SeeLongMessage", bundle: nil)
        let seeLongMessageViewController = storyboard.instantiateViewController(withIdentifier: "SeeLongMessageViewController") as? SeeLongMessageViewController
        let nav = UINavigationController(rootViewController: seeLongMessageViewController!)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: { () in
            seeLongMessageViewController!.longMessageTextView.text = messag
        })
    }
}

class MessageSentTableViewCell: UITableViewCell {
    var messagesFromMe: MessageFromMe? {
        didSet {
            nameLabel.text = messagesFromMe?.toName ?? "??" + "さん"
            messageLabel.text = messagesFromMe?.message
            dateFromString { date in
                let formatter: DateFormatter = DateFormatter()
                formatter.dateFormat = "MM/dd"
                self.dateLabel.text = formatter.string(from: date)
            }
            
            if isDark {
                nameLabel.textColor = .white
                dateLabel.textColor = .white
                messageLabel.textColor = .white
            }
        }
    }
    
    func dateFromString (completion: (Date) -> Void) {
        let date = messagesFromMe?.createdAt
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy/MM/dd-HH:mm:ss"
        completion(formatter.date(from: date ?? Date().description)!)
    }
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
