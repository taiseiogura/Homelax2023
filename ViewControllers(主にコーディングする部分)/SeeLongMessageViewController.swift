//
//  SeeLongMessageViewController.swift
//  homeLux
//
//  Created by Taisei Ogura on 2022/12/04.
//

import UIKit

class SeeLongMessageViewController: UIViewController {

    @IBOutlet weak var longMessageTextView: UITextView!


    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isDark {
            self.view.backgroundColor = backGroundColor_gray
            longMessageTextView.textColor = .white
        }
    }
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
