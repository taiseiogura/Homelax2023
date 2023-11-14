//
//  ManagerViewController.swift
//  homeLux
//
//  Created by Taisei Ogura on 2022/11/29.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore
import PKHUD

private var numbers: [String]? = []

private var partnerNumber: String = ""
private var userNam: String = ""
private var userNumber: String = ""

class ManagerViewController: UIViewController {
    private var managerViewCell = ManagerTableViewCell()
    private var myGrade: String = ""
    private var myClass: String = ""
    private let cellId = "cellId"
    private var users = [User]()
    private var shuffledUsers = [ShuffledUser]()
    
    @IBOutlet var managerTableView: UITableView!
    @IBOutlet weak var gradeTextField: UITextField!
    @IBOutlet weak var classTextField: UITextField!
    
    @IBOutlet weak var shuffleButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        managerTableView.delegate = self
        managerTableView.dataSource = self
        
    }
    
    
    func initNav() {
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            // NavigationBarの背景色の設定
            appearance.backgroundColor = UIColor.secondarySystemFill
            // NavigationBarのタイトルの文字色の設定
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel]
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        
        navigationController?.navigationBar.tintColor = .secondaryLabel
        self.navigationItem.title = "Manager Tool"
        self.tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initNav()
        
    }
    
    func initializer() {
        shuffledUsers.removeAll()
        deleteNumbers()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.fetchNumbers(collec: self.getClassFromFireStore())
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.shuffle()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.shuffleButton.isEnabled = true
            self.managerTableView.reloadData()
        }
    }
    
    func deleteNumbers(){
        numbers?.removeAll()
    }
    
    private func getMyClass(){
        b {
            self.managerTableView.reloadData()
        }
    }
    
    func b(completion: @escaping () -> Void) {
        myGrade = gradeTextField.text ?? ""
        myClass = classTextField.text ?? ""
        fetchUsers(collec: getClassFromFireStore())
        numbers?.removeAll()
        fetchNumbers(collec: getClassFromFireStore())
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            completion()
        }
    }
    
    
    
    private func getClassFromFireStore() -> String {
        if myGrade == "1" && myClass == "A" {
            return "1A"
        } else if myGrade == "1" && myClass == "B" {
            return "1B"
        } else if myGrade == "2" && myClass == "A" {
            return "2A"
        } else if myGrade == "2" && myClass == "B" {
            return "2B"
        } else if myGrade == "3" && myClass == "A" {
            return "3A"
        } else if myGrade == "3" && myClass == "B" {
            return "3B"
        } else if myGrade == "4" && myClass == "A" {
            return "4A"
        } else if myGrade == "4" && myClass == "B" {
            return "4B"
        } else if myGrade == "5" && myClass == "A" {
            return "5A"
        } else if myGrade == "5" && myClass == "B" {
            return "5B"
        } else if myGrade == "6" && myClass == "A" {
            return "6A"
        } else if myGrade == "6" && myClass == "B" {
            return "6B"
        } else if myGrade == "7" && myClass == "A" {
            return "7A"
        } else if myGrade == "7" && myClass == "B" {
            return "7B"
        } else {
            print("error")
            return "7B"
        }
    }
    
    func shuffle() {
        
        numbers?.forEach({ (snapshots) in
            let num = snapshots.self
            var isContained: Bool = false
            
            numbers?.forEach({ (snapshot) in
                if num == snapshot.self {
                    isContained = true
                }
            })
            
            numbers?.removeAll(where: {$0 == num})
            let partnerNum = Int(numbers?.randomElement() ?? "0")
            let sPartnerNum = String(partnerNum ?? 0)
            
            getPartnerInfo(collec: getClassFromFireStore(), partnerNumber: partnerNum ?? 0)
            numbers!.removeAll(where: {$0 == sPartnerNum})
            
            if isContained == true {
                numbers?.append(num)
            }
            
        })
    }
    
    
    func getPartnerInfo(collec: String, partnerNumber: Int) {
        print("partnerNumber:",partnerNumber)
        Firestore.firestore().collection(collec).getDocuments { [self] (snapshots, err) in
            if let err = err {
                print("user情報の取得に失敗しました。\(err)")
                return
            }
            
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let user = User.init(dic: dic)
                let shuffledUser = ShuffledUser.init(dic: dic)
                shuffledUser.uid = snapshot.documentID
                let iPartnerNumber: Int = Int(partnerNumber)
                let userNum = Int(user.number)
                if userNum == iPartnerNumber {
                    let userName = user.name
                    let userNum = user.number
                    //self.managerViewCell.setPartnerInfo(userName: userName, userNumber: userNumber)
                    userNam = userName
                    userNumber = userNum
                    //                    print("userNam: ",userNam,"userNumber: ",userNumber)
                    self.shuffledUsers.append(shuffledUser)
                    print("Caution",self.shuffledUsers.count)
                    self.managerTableView.reloadData()
                    return
                }
            })
        }
    }
    
    
    private func fetchUsers(collec: String) {
        Firestore.firestore().collection(collec).getDocuments { (snapshots, err) in
            if let err = err {
                print("user情報の取得に失敗しました。\(err)")
                return
            }
            
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let user = User.init(dic: dic)
                user.uid = snapshot.documentID
                
                self.users.append(user)
            })
        }
    }
    
    private func fetchNumbers(collec: String) {
        
        Firestore.firestore().collection(collec).getDocuments { (snapshots, err) in
            if let err = err {
                print("user情報の取得に失敗しました。\(err)")
                return
            }
            
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let user = User.init(dic: dic)
                
                numbers?.append(user.number)
            })
        }
    }
    
    private func getNumCount(completion: @escaping (Int) -> Void) {
        a { n in
            print("処理中（１）",n)
            completion(n)
        }
    }
    
    func a(completion: @escaping (Int) -> Void) {
        var n: Int = 0
        Firestore.firestore().collection(getClassFromFireStore()).getDocuments { (snapshots, err) in
            if let err = err {
                print("user情報の取得に失敗しました。\(err)")
                return
            }
            snapshots?.documents.forEach({ (snapshot) in
                n = n + 1
                print("NNN",n)
            })
            completion(n)
        }
        print("処理中（２）")
        
    }
    
    //・・・・・・・・・MARK この下ボタンズ・・・・・・・・・//
    
    
    @IBAction func tappedShuffleButton(_ sender: Any) {
        print("shufflebutton is tapped")
        self.shuffleButton.isEnabled = false
        initializer()
    }
    
    
    @IBAction func tappedReloadButton(_ sender: Any) {
        managerTableView.reloadData()
    }
    
    
    @IBAction func tappedShowButton(_ sender: Any) {
        shuffledUsers.removeAll()
        users.removeAll()
        
        print("tapped")
        
        getMyClass()
    }
    
    @IBAction func tappedStartChatButton(_ sender: Any) {
        print("tapped")
        print("myClass: ",myGrade,myClass)
        deleteNumbers()
            self.getNumCount { numCount in
                print(numCount)
                for n in 0...(numCount)-1 {
                    print("userUid",self.users[n].uid ?? "0")
                    print("shuffledUserUid",self.shuffledUsers[n].uid ?? "0")
                    guard let myUid = self.users[n].uid else { return }
                    guard let partnerUid = self.shuffledUsers[n].uid else { return }
                    let members = [myUid, partnerUid]
                    let names = [self.users[n].name, self.shuffledUsers[n].name]
                    let docData = [
                        "members": members,
                        "names": names,
                        "createdAt": Timestamp(),
                    ] as [String : Any]
                    
                    Firestore.firestore().collection("chatRooms").addDocument(data: docData) { (err) in
                        if let err = err {
                            print("chatRoom作成に失敗しました。\(err)")
                            return
                        }
                        print("chatroom作成に成功しました。")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            HUD.hide { (_) in
                                HUD.flash(.success, onView: self.view)
                            }
                        }
                        
                    }
                }
                
            }
    }
    
    @IBAction func tappedToHomeButton(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Home", bundle: nil)
        let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
        let nav = UINavigationController(rootViewController: homeViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    @IBAction func tappedToPendingButton(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Manager", bundle: nil)
        let managerViewController = storyboard.instantiateViewController(withIdentifier: "ManagerViewController")
        let nav = UINavigationController(rootViewController: managerViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    
    
}

extension ManagerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = managerTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ManagerTableViewCell
        cell.user = users[indexPath.row]
        if shuffledUsers.count == users.count {
            cell.shuffledUser = shuffledUsers[indexPath.row]
        }
        return cell
    }
}

public class ManagerTableViewCell: UITableViewCell {

    
    var user :User? {
        didSet {
            myNameLabel.text = user?.name
            myNumberLabel.text = user?.number.description ?? ""
            
        }
    }
    var shuffledUser :ShuffledUser? {
        didSet {
            partnerNameLabel.text = shuffledUser?.name
            partnerNumberLabel.text = shuffledUser?.number.description ?? ""
        }
    }

    
    @IBOutlet weak var myNumberLabel: UILabel!
    @IBOutlet weak var myNameLabel: UILabel!
    
    @IBOutlet weak var partnerNumberLabel: UILabel!
    @IBOutlet weak var partnerNameLabel: UILabel!
    
    
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

