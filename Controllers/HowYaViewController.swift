//
//  HowYaViewController.swift
//  homelax-ultra
//
//  Created by Taisei Ogura on 2023/04/09.
//

import Foundation
import UIKit
import Firebase
import PKHUD

class HowYaViewController: UIViewController {
    
    var scale: Int = 2
    
    @IBOutlet weak var happyFaceImage: UIButton!
    @IBOutlet weak var fineFaceImage: UIButton!
    @IBOutlet weak var notOkFaceImage: UIButton!
    @IBOutlet weak var badFaceImage: UIButton!
    
    @IBOutlet weak var okButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentViewController = self
        okButton.isEnabled = false
        okButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100, alpha: 1)
        okButton.layer.cornerRadius = 10
    }
    
    @IBAction func tappedHappyButton(_ sender: Any) {
        resetButtons {
            self.happyFaceImage.backgroundColor = nil
            enableSubmitButton()
        }
        scale = 1
    }
    
    @IBAction func tappedFineButton(_ sender: Any) {
        resetButtons {
            self.fineFaceImage.backgroundColor = nil
            enableSubmitButton()
        }
        scale = 2
    }
    
    @IBAction func tappedNotOkButton(_ sender: Any) {
        resetButtons {
            self.notOkFaceImage.backgroundColor = nil
            enableSubmitButton()
        }
        scale = 3
    }
    
    @IBAction func tappedBadButton(_ sender: Any) {
        resetButtons {
            self.badFaceImage.backgroundColor = nil
            enableSubmitButton()
        }
        scale = 4
    }
    
    func enableSubmitButton() {
        okButton.backgroundColor = .rgb(red: 162, green: 85, blue: 0, alpha: 1)
        okButton.isEnabled = true
    }
    
    func resetButtons(completion: () -> Void) {
        resetButton(image: happyFaceImage)
        resetButton(image: fineFaceImage)
        resetButton(image: notOkFaceImage)
        resetButton(image: badFaceImage)
        completion()
    }
    
    @IBAction func tappedOkButton(_ sender: Any) {
        okButton.isEnabled = false
        registerForFirebase(scale: scale)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            crossTransition(storyBoardName: "Home")
        })
    }
    
    
    func resetButton(image: UIButton) {
        image.backgroundColor = UIColor.rgb(red: 229, green: 211, blue: 177, alpha: 0.43)
    }
    
    func registerForFirebase(scale: Int) {
        var uid: String = ""
        
        if Auth.auth().currentUser?.uid == nil {
            print("NO USER REC")
            return
        }else {
            uid = Auth.auth().currentUser!.uid
            print("USER REC")
        }
//        Firestore.firestore().collection("isHappy").addDocument(data: ["a":"a"])
        Firestore.firestore().collection("isHappy").document(uid).setData(["a":"a"])
//        doc.setData(["a" : "a"])
        
        let db = Firestore.firestore().collection("isHappy").document(uid).collection("isHappy")
        Commands().getMyClass { clas in
            
            print("CLASS:", clas)
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
            
            let dic = [
                "answeredAt" : Date(),
                "happyScale" : scale,
                "grade" : clas,
                "userId" : uid
            ] as! [String:Any]
            
            
            HUD.show(.progress, onView: self.view)
            
            db.addDocument(data: dic) { (err) in
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
            }
        }
        
//        db.getDocument { (document, err) in
//            if let err = err {
//                print(err)
//                return
//            }
//
//            if let document = document, document.exists {
//
//            }
//        }
    }
}

