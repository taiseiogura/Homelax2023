//
//  BottomButtonView.swift
//  homelax-ultra
//
//  Created by Taisei Ogura on 2023/03/25.
//

import UIKit

protocol BottomButtonViewDelegate: AnyObject {
    func tappedPushTransitButton(type: UIViewController, storyboardName: String)
}

class BottomButtonView: UIView {
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var messageLogButton: UIButton!
    @IBOutlet weak var messagesSentButton: UIButton!
    @IBOutlet weak var backGroundImage: UIImageView!
    
    @IBOutlet weak var sentLabel: UILabel!
    @IBOutlet weak var receivedLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var settingLabel: UILabel!
    
    weak var delegate: (BottomButtonViewDelegate)?
    
    let senderImage_white = UIImage.init(named: "sender_white")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        loadNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }

    func loadNib() {
        
        print("NIB LOADING")
        
        if let view = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? UIView {
            view.frame = self.bounds
            self.addSubview(view)
        }
        
        if isDark {
            backGroundImage.tintColor = .black
            setColor(label: sentLabel)
            setColor(label: infoLabel)
            setColor(label: receivedLabel)
            setColor(label: settingLabel)
            
            setButtonColor(button: settingButton)
            setButtonColor(button: infoButton)
            setButtonColor(button: messageLogButton)
            setButtonColor(button: messagesSentButton)
        }
        
        func setColor(label: UILabel) {
            label.textColor = .white
        }
        
        func setButtonColor(button: UIButton) {
            button.tintColor = .white
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    //MARK Buttons
    
    @IBAction func tappedInfoButton(_ sender: Any) {
        buttonAction(button: infoButton, toImage: infoImageFilled!)
        if currentViewControllerId != "About" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                crossTransition(storyBoardName: "About")
            }
        }
    }
    
    @IBAction func tappedSendButton(_ sender: Any) {
        buttonAction(button: sendButton, toImage: sendImage_filled!)
        print(currentViewController)
        print(HomeViewController().self)
        if currentViewControllerId != "Home" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                crossTransition(storyBoardName: "Home")
            }
        }
    }
    
    @IBAction func tappedSettingsButton(_ sender: Any) {
        buttonAction(button: settingButton, toImage: settingImage_filled!)
        if currentViewControllerId != "UserList"{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                pushTransit(type: currentViewController, storyboardName: "UserList")
                crossTransition(storyBoardName: "Settings")
            }
        }
    }
    
    @IBAction func tappedReceivedMessageButton(_ sender: Any) {
        buttonAction(button: messageLogButton, toImage: giftImage_filled!)
        print(currentViewController,"3")
        if currentViewControllerId != "MessageLog" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                pushTransit(type: currentViewController, storyboardName: "MessageLog")
                crossTransition(storyBoardName: "MessageLog")
            }
        }
    }
    
    @IBAction func tappedSentMessageButton(_ sender: Any) {
//        buttonAction(button: messagesSentButton, toImage: bellImage_filled!)
        if currentViewControllerId != "MessagesSent" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                pushTransit(type: currentViewController, storyboardName: "MessagesSent")
                crossTransition(storyBoardName: "MessagesSent")
            }
        }
    }
    
}
