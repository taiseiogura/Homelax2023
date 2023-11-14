//
//  UsersListViewController.swift
//  homeLux
//
//  Created by Taisei Ogura on 2022/11/29.
//

import UIKit
import Firebase
private var myGrade: String = ""
private var myClass: String = ""
private var myCollec: String = ""

class UserListViewController: UIViewController {

    @IBOutlet var userListTableView: UITableView!
    private let cellId = "cellId"
    private var users = [User]()
    private var selectedUser: User?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userListTableView.tableFooterView = UIView()
        
        userListTableView.delegate = self
        userListTableView.dataSource = self

        getMyClass()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.initNav()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
//        getMyClass()
        currentViewController = self
        currentViewControllerId = "UserList"
        
        if isDark {
            self.view.backgroundColor = backGroundColor_gray
            userListTableView.backgroundColor = backGroundColor_gray
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
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        
        self.navigationItem.title = myCollec
        
        let rightBarButton = UIBarButtonItem(title: "メッセージを送る", style: .plain, target: self, action: #selector(tappedButton))
        navigationItem.rightBarButtonItem = rightBarButton
        rightBarButton.isEnabled = false
        self.tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc func tappedButton() {

        let storyboard = UIStoryboard.init(name: "OptionalMessageSender", bundle: nil)
        
        let optionalMessageSender = storyboard.instantiateViewController(withIdentifier: "OptionalMessageSenderViewController") as? OptionalMessageSenderViewController
        let nav = UINavigationController(rootViewController: optionalMessageSender!)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: { () in
            optionalMessageSender!.partner = self.selectedUser
        })

        
        
    }
    
//    func enableButton() {
//        rightbarbutton
//    }
    
    
    private func getMyClass(){
        Firestore.firestore().collection("users").getDocuments { (snapshots, err) in
            if let err = err {
                print("user情報の取得に失敗しました。\(err)")
                return
            }
            
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let user = User.init(dic: dic)
                
                guard let uid = Auth.auth().currentUser?.uid else { return }
                
                if uid == snapshot.documentID {
                    print("I'm here")
                    
                    myGrade = user.grade.description
                    myClass = user.clas
                    myCollec = user.collec
                    print("haha",myGrade, myClass, myCollec)
                    self.fetch()
                    return
                }
                return
                
            })
        }
    }
    
    private func fetch() {
        Firestore.firestore().collection(myCollec).getDocuments { (snapshots, err) in
            if let err = err {
                print("user情報の取得に失敗しました。\(err)")
                return
            }
            
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let user = User.init(dic: dic)
                
                user.uid = snapshot.documentID
                
                guard let uid = Auth.auth().currentUser?.uid else { return }
                
                if uid == snapshot.documentID {
                    return
                }
                
                self.users.append(user)
                self.userListTableView.reloadData()
                
            })
        }
    }
    
    @objc func tappedCloseButton() {
        self.dismiss(animated: true)
    }
    

    
}

extension UserListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserListTableViewCell
        cell.user = users[indexPath.row]
        
        let cellSelectedBgView = UIView()
        if isDark {
            cell.backgroundColor = backGroundColor_gray
            cellSelectedBgView.backgroundColor = .darkGray
        } else {
            cellSelectedBgView.backgroundColor = UIColor.rgb(red: 234, green: 182, blue: 118, alpha: 1)
        }
        cell.selectedBackgroundView = cellSelectedBgView
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        self.selectedUser = user
        navigationItem.rightBarButtonItem?.isEnabled = true
        navigationItem.rightBarButtonItem?.tintColor = .systemBlue
        
        print("user:", self.selectedUser?.uid ?? "")
        
    }
    
    @objc func tappedSendMessageButton() {
        
    }
    
}


class UserListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var user: User? {
        didSet {
            nameLabel.text = user?.name
            if isDark {
                nameLabel.textColor = .white
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

