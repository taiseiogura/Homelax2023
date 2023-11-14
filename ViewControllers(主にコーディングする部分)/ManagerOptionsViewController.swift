//
//  ManagerOptionsViewController.swift
//  Homelax
//
//  Created by Taisei Ogura on 2023/03/19.
//

import Foundation
import UIKit
import Firebase


class ManagerOptionsViewController: UIViewController {
    
    private var isHappies = [IsHappy]()
    
    override func viewDidLoad(){
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let managerToolViewController = ManagerToolViewController()
        managerToolViewController.authenticate { isAuthenticated in
            if isAuthenticated != true {
                let storyboard = UIStoryboard.init(name: "ManagerTool", bundle: nil)
                let ManagerToolViewController = storyboard.instantiateViewController(withIdentifier: "ManagerToolViewController")
                let nav = UINavigationController(rootViewController: ManagerToolViewController)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }
        
        currentViewController = self
    }
    
    @IBAction func tappedShuffleButton(_ sender: Any) {
        print("buttonn")
        let storyboard = UIStoryboard.init(name: "Manager", bundle: nil)
        let managerViewController = storyboard.instantiateViewController(withIdentifier: "ManagerViewController")
        let nav = UINavigationController(rootViewController: managerViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    @IBAction func tappedPendingButton(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "PendingMessages", bundle: nil)
        let pendingMessagesViewController = storyboard.instantiateViewController(withIdentifier: "PendingMessagesViewController")
        let nav = UINavigationController(rootViewController: pendingMessagesViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    
    
    
    
    
    var onea = [User]()
    var oneb = [User]()
    var twoa = [User]()
    var twob = [User]()
    var threea = [User]()
    var threeb = [User]()
    var foura = [User]()
    var fourb = [User]()
    var fivea = [User]()
    var fiveb = [User]()
    var sixa = [User]()
    var sixb = [User]()
    var sevena = [User]()
    var sevenb = [User]()
    
    var oneaToChoose = [User]()
    var onebToChoose = [User]()
    var twoaToChoose = [User]()
    var twobToChoose = [User]()
    var threeaToChoose = [User]()
    var threebToChoose = [User]()
    var fouraToChoose = [User]()
    var fourbToChoose = [User]()
    var fiveaToChoose = [User]()
    var fivebToChoose = [User]()
    var sixaToChoose = [User]()
    var sixbToChoose = [User]()
    var sevenaToChoose = [User]()
    var sevenbToChoose = [User]()
    
    func initArrays() {
        let db = Firestore.firestore().collection("users")
        db.getDocuments { (documents, err) in
            if let err = err {
                print("failed to get users\(err)")
                return
            }
            documents?.documents.forEach { document in
                let dic = document.data()
                let user = User.init(dic: dic)
                self.sub(collec: user.collec, user: user)
            }
        }
    }
    
    func sub(collec: String, user: User) {
        switch collec {
        case "1A":
            onea.append(user)
            oneaToChoose.append(user)
        
        case "1B":
            oneb.append(user)
            onebToChoose.append(user)
            
        case "2A":
            twoa.append(user)
            twoaToChoose.append(user)
            
        case "2B":
            twob.append(user)
            twobToChoose.append(user)
            
        case "3A":
            threea.append(user)
            threeaToChoose.append(user)
        
        case "3B":
            threeb.append(user)
            threebToChoose.append(user)
        
        case "4A":
            foura.append(user)
            fouraToChoose.append(user)
        
        case "4B":
            fourb.append(user)
            fourbToChoose.append(user)
        
        case "5A":
            fivea.append(user)
            fiveaToChoose.append(user)
        
        case "5B":
            fiveb.append(user)
            fivebToChoose.append(user)
        
        case "6A":
            sixa.append(user)
            sixaToChoose.append(user)
            
        case "6B":
            sixb.append(user)
            sixbToChoose.append(user)
        
        case "7A":
            sevena.append(user)
            sevenaToChoose.append(user)
        
        case "7B":
            sevenb.append(user)
            sevenbToChoose.append(user)
        
        default:
            print("skip")
        }
        
    }
    
    func shuffle(array: [(User)], arrayToChoose: [(User)]) {
        let numberOfStudents = array.count
        var numArray1:[Int]?
        var numArray2:[Int]?
        var numPairs: [(Int, Int)]?
        
        for n in 0..<numberOfStudents {
            numArray1?.append(n + 1)
            numArray2?.append(n + 1)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
            numArray1?.forEach({ num1 in
                numArray2?.removeAll(where: {$0 == num1})
                
                let partnerNum = numArray2?.randomElement()
                
                numPairs?.append((num1, partnerNum!))
                
                numArray2?.append(num1)
                numArray2?.removeAll(where: {$0 == partnerNum})
                
                print(numPairs)
            })
        })
    }
    
    @IBAction func tappedShuffleAllButton(_ sender: Any) {
        let dialog = UIAlertController(title: "U Sure?", message: nil, preferredStyle: .alert)
        
        let yep = UIAlertAction(title: "Yep", style: .default, handler: {_ in
            self.initArrays()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.shuffle(array: self.onea, arrayToChoose: self.oneaToChoose)
            })
        })
        
        let nope = UIAlertAction(title: "nope", style: .cancel)
        
        currentViewController.present(dialog, animated: true)
        
    }
    
    @IBAction func tappedGetUidsButton(_ sender: Any) {
        let db = Firestore.firestore()
        let firebaseRef = db.collection("users")
        let uidsRef = db.collection("uids")
        
        firebaseRef.getDocuments { (snapshotss, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let snapshots = snapshotss?.documents else {
                print("there aint docs")
                return
            }
            
            for snapshot in snapshots {
                let docId = snapshot.documentID
                let dic = [
                    "uid": docId
                ]
                
                uidsRef.addDocument(data: dic)
            }
            
        }
    }
    
    @IBAction func tappedLetsGoButton(_ sender: Any) {
        let db = Firestore.firestore()
        
        let mainCollec = db.collection("isHappy")
        
        mainCollec.getDocuments { (snapshot, error)  in
            
            if let error = error {
                    print("エラー：\(error)")
                    return
                }
            
            guard let documents = snapshot?.documents else {
                print("there are no docs")
                return
            }
            
            for document in documents {
                let docId = document.documentID
                let subCollecRef = mainCollec.document(docId).collection("isHappy")
                
                subCollecRef.getDocuments { (snap, error) in
                    if let error = error {
                        print("error2:\(error)")
                        return
                    }
                    
                    guard let subDocuments = snap?.documents else {
                        print("サブコレクションのドキュメントがありません")
                        return
                    }
                    
                    for subDocument in subDocuments {
                        // サブコレクションのデータを取得
                        let subData = subDocument.data()
                        // データを使用する処理を記述
                        let isHappy = IsHappy.init(dic: subData)
                        
                        
                        let collec = db.collection("isHappies3")
                        
                        collec.getDocuments { (document, err) in
                            if let err = err {
                                print(err)
                                return
                            }
                            
                            guard let finalDocs = document?.documents else {return}
                            
                            for finalDoc in finalDocs {
                                let data = finalDoc.data()
                                let snapshotData = IsHappy.init(dic: data)
                                
                                let date1: Date = isHappy.answeredAt.dateValue()
                                let date2: Date = snapshotData.answeredAt.dateValue()
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy/MM/dd"
                                
                                let dateString1 = dateFormatter.string(from: date1)
                                let dateString2 = dateFormatter.string(from: date2)
                                
                                if snapshotData.userId == isHappy.userId {
                                    if dateString1 == dateString2 {
                                        print("same date")
                                        break
                                    }
                                }
                            }
                            
                        }
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy/MM/dd"
                        
                        let dateToSave: Date = isHappy.answeredAt.dateValue()
                        
                        let dateStringToSave = dateFormatter.string(from: dateToSave)
                        
                        let dic : [String : Any] = [
                            "answeredAt" : dateStringToSave,
                            "grade" : isHappy.grade,
                            "userId" : isHappy.userId,
                            "happyScale" : isHappy.happyScale
                        ]
                        
                        collec.addDocument(data: dic) { (error) in
                            if let error = error {
                                print("err during writing to firebase\(error)")
                            }
                        }
                    }
                }
            }
            
        }
    }
    
}
