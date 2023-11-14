//
//  StartViewController.swift
//  homelax-ultra
//
//  Created by Taisei Ogura on 2023/03/29.
//

import Foundation
import UIKit

class StartViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkDarkMode()

        label.text = ""

        self.label.text = "こんにちは！\n画面をタップしてください。"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapped(_:)))
                
        //UIGestureのデリゲート
        tapGesture.delegate = self
        
        //viewに追加
        self.view.addGestureRecognizer(tapGesture)
        
        flashLabel()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        currentViewController = self
        currentViewControllerId = "Start"
    }
    
    private func flashLabel() {
            // 1秒かけてラベルのアルファ値を変更する(repeatオプションを使用)
            UIView.animate(withDuration: 1.0,
                           delay: 0.0,
                           options: .repeat,
                           animations: {
                            self.label.alpha = 0.0
            }) { (_) in
                self.label.alpha = 1.0
            }
        }
    
    @objc func tapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            crossTransition(storyBoardName: "Home")
        }
    }
}
