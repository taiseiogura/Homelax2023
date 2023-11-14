//
//  Commands.swift
//  homelax-ultra
//
//  Created by Taisei Ogura on 2023/03/25.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

var currentViewController: UIViewController = HomeViewController()
var currentViewControllerId: String = "Home"
var settings = [Setting]()
let darkMode: String = "ダークモード"

var isDark: Bool = false

var ishappy = [IsHappy]()

func buttonAction(button: UIButton, toImage: UIImage) {
    button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        print(toImage)
        button.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
}

func pushTransit(type: UIViewController, storyboardName: String) {
    let storyboard = UIStoryboard.init(name: storyboardName, bundle: nil)
    let viewController = storyboard.instantiateViewController(withIdentifier: storyboardName + "ViewController")
    type.navigationController?.pushViewController(viewController, animated: true)
}

func checkDarkMode() {
    guard let uid = Auth.auth().currentUser?.uid else {return}
    let db = Firestore.firestore().collection("users").document(uid).collection("settings").document(uid)
    db.getDocument { (document, error) in
        if let document = document, document.exists {
            let data = document.data()?[darkMode] as! Bool
            
            if data {
                isDark = true
            } else {
                isDark = false
            }
        } else {
            print("Document does not exist")
            isDark = false
        }
    }
}

func hasAnswered(completion: @escaping(Bool) -> Void) {
    
        let answeredAtField = "answeredAt"
        let isHappyCollection = "isHappy"
        let uid = Auth.auth().currentUser?.uid ?? ""
        let db = Firestore.firestore().collection(isHappyCollection).document(uid)
        let query = db.collection(isHappyCollection)
        
        var hasAnswered = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        dateFormatter.locale = Locale(identifier: "ja_JP")
        
        // ユーザーがログインしているかどうかを確認する
        guard !uid.isEmpty else {
            hasAnswered = false
            completion(hasAnswered)
            return
        }
        
        // ユーザーの回答履歴を取得する
        db.getDocument { (snapshot, error) in
            guard let snapshot = snapshot, snapshot.exists else {
                hasAnswered = true
                completion(hasAnswered)
                return
            }
            query.getDocuments { (snapshots, error) in
                if let error = error {
                    print(error)
                    hasAnswered = false
                    completion(false)
                    return
                }
                
                snapshots?.documents.forEach({ (document) in
                    let dic = document.data()
                    let isHappy = IsHappy.init(dic: dic)
                    let date = isHappy.answeredAt.dateValue()
                    if dateFormatter.string(from: date) == dateFormatter.string(from: Date()) {
                        hasAnswered = false
                        print("FILTERED")
                        completion(false)
                    }
                })
            }
        }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
        completion(hasAnswered)
    })
    
}

func notifTest() {
    let content = UNMutableNotificationContent()
    content.title = "通知のチェック"
    content.body = "このような形で通知が送信されます"
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
    let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request)
}


func crossTransition(storyBoardName: String) {
    print(currentViewController, "1")
    let storyboard = UIStoryboard.init(name: storyBoardName, bundle: nil)
    let userListViewController = storyboard.instantiateViewController(withIdentifier: storyBoardName + "ViewController")
    let nav = UINavigationController(rootViewController: userListViewController)
    nav.modalPresentationStyle = .fullScreen
    print(currentViewController,"2")
    currentViewController.present(nav, animated: false, completion: nil)
}

func getNoteMessagesFromFirestore(completion: @escaping([String]) -> Void) {
    
    var noteMessages:[String] = []
    
    Firestore.firestore().collection("noteMessages").getDocuments { (snapthosts, err) in
        if let err = err {
            print("noteMessage情報の取得に失敗しました。\(err)")
            return
        }
        
        snapthosts?.documents.forEach({ (snapshot) in
            let dic = snapshot.data()
            let noteMessage = NoteMessages.init(dic: dic)
            noteMessages.append(noteMessage.message)
            print(noteMessage.message)
        })
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        completion(noteMessages)
    }
}

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
    }
}

class Commands {
    var myGrade: String = ""
    var myClass: String = ""
    
    private func getGradeAndClass(completion: @escaping() -> Void) {
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
                    self.myGrade = user.grade.description
                    self.myClass = user.clas
                    completion()
                }
                return
                
            })
        }
    }
    
    func getSettingsArray(completion: @escaping () -> Void) {
        settings.removeAll()
        
        Firestore.firestore().collection("Settings").getDocuments{ (snapshots, err) in
            if let err = err {
                print("Settings情報の取得に失敗しました。\(err)")
                return
            }

            snapshots?.documents.forEach({ (snapshot) in

                let dic = snapshot.data()
                let setting = Setting.init(dic: dic)
                settings.append(setting)
                
            })
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
            completion()
        })
    }
    
    func getMyName(completion: @escaping(String) -> Void) {
        Firestore.firestore().collection("users").getDocuments{ (snapshots, err) in
            if let err = err {
                print("ユーザー情報の取得に失敗しました。\(err)")
                return
            }

            snapshots?.documents.forEach({ (snapshot) in

                let dic = snapshot.data()
                let user = User.init(dic: dic)
                guard let myUid = Auth.auth().currentUser?.uid else { return }
                user.uid = snapshot.documentID

                if user.uid == myUid {
                    print(user.name)
                    completion(user.name)
                }
            })
        }
    }
    
    func getMyClass(completion: @escaping(String) -> Void) {
        getGradeAndClass(completion: {
            print("myGrade: ", self.myGrade, "myClass: ", self.myClass)
            if self.myGrade == "中２" && self.myClass == "A" {
                completion("1A")
            } else if self.myGrade == "中１" && self.myClass == "B" {
                completion("1B")
            } else if self.myGrade == "中２" && self.myClass == "A" {
                completion("2A")
            } else if self.myGrade == "中２" && self.myClass == "B" {
                completion("2B")
            } else if self.myGrade == "中３" && self.myClass == "A" {
                completion("3A")
            } else if self.myGrade == "中３" && self.myClass == "B" {
                completion("3B")
            } else if self.myGrade == "高１" && self.myClass == "A" {
                completion("4A")
            } else if self.myGrade == "高１" && self.myClass == "B" {
                completion("4B")
            } else if self.myGrade == "高２" && self.myClass == "A" {
                completion("5A")
            } else if self.myGrade == "高２" && self.myClass == "B" {
                completion("5B")
            } else if self.myGrade == "高３" && self.myClass == "A" {
                completion("6A")
            } else if self.myGrade == "高３" && self.myClass == "B" {
                completion("6B")
            } else if self.myGrade == "その他" && self.myClass == "A" {
                completion("7A")
            } else if self.myGrade == "その他" && self.myClass == "B" {
                completion("7B")
            } else if self.myGrade == "その他" && self.myClass == "(manager)" {
                completion("manager")
            }
            else {
                print("error")
            }
        })
    }
}

