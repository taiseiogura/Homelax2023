//
//  AboutViewController.swift
//  homeLux
//
//  Created by Taisei Ogura on 2022/11/03.
//

import UIKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var bottomButtonsView: BottomButtonView!
    @IBOutlet weak var mailLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var overviewLongLabel: UILabel!
    @IBOutlet weak var whatToWriteLabel: UILabel!
    @IBOutlet weak var whatToWriteLongLabel: UILabel!
    @IBOutlet weak var whatIfLabel: UILabel!
    @IBOutlet weak var whatIfLongLabel: UILabel!
    @IBOutlet weak var multipleOkLabel: UILabel!
    @IBOutlet weak var multipleOkOfCourseLabel: UILabel!
    @IBOutlet weak var askMeLabel: UILabel!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        bottomButtonsView.infoButton.setBackgroundImage(infoImageFilled, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initNav()
        currentViewController = self
        currentViewControllerId = "About"
        
        if isDark {
            self.view.backgroundColor = backGroundColor_gray
            mailLabel.textColor = .lightGray
            setToWhite(label: overviewLabel)
            setToWhite(label: overviewLongLabel)
            setToWhite(label: whatToWriteLabel)
            setToWhite(label: whatToWriteLongLabel)
            setToWhite(label: whatIfLabel)
            setToWhite(label: whatIfLongLabel)
            setToWhite(label: multipleOkLabel)
            setToWhite(label: multipleOkOfCourseLabel)
            setToWhite(label: askMeLabel)
        }
        
        func setToWhite(label: UILabel) {
            label.textColor = .white
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

        self.navigationItem.title = "About"
        self.tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc func tappedButton() {
        self.dismiss(animated: true)
    }
    
    @IBAction func tappedPrivacyPolicyButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "PrivacyPolicyForView", bundle: nil)
        let nextVc = storyboard.instantiateViewController(withIdentifier: "PrivacyPolicyForViewViewController")
        nextVc.modalPresentationStyle = .pageSheet
        present(nextVc, animated: true, completion: nil)
    }
    
}

class MailLabel: UILabel {
    override init(frame: CGRect) {
            super.init(frame: frame)
            self.copyInit()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            self.copyInit()
        }

        func copyInit() {
            self.isUserInteractionEnabled = true
            // 長押しコピー
            //self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(CopyUILabel.showMenu(sender:))))
            // 軽くタッチコピー
            self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MailLabel.showMenu(sender:))))
        }

        @objc func showMenu(sender:AnyObject?) {
            self.becomeFirstResponder()
            let contextMenu = UIMenuController.shared
            if !contextMenu.isMenuVisible {
                contextMenu.showMenu(from: self, rect: self.bounds)
            }
        }

        override func copy(_ sender: Any?) {
            let pasteBoard = UIPasteboard.general
            pasteBoard.string = text
        }

        override var canBecomeFirstResponder: Bool {
            return true
        }

        override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
            return action == #selector(UIResponderStandardEditActions.copy)
        }
}
