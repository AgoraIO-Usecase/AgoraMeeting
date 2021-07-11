//
//  TermsAndPolicyViewController.swift
//  TermsAndPolicyDemo
//
//  Created by LY on 2021/7/9.
//

import UIKit

class TermsAndPolicyViewController: UIViewController {
    static var storeKey = "TermsRead"
    var fromSetting = false
    override func viewDidLoad() {
        super.viewDidLoad()
        if let content = self.view as? TermsAndPolicyView {
            content.fromSetting = fromSetting
            content.setupViews()
        }
    }
    
    @IBAction func closeView(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func agreed(_ sender: Any) {
        TermsAndPolicyViewController.setPolicyPopped(true)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func disagree(_ sender: UIButton) {
        TermsAndPolicyViewController.setPolicyPopped(false)
        exit(0)
    }
}

extension TermsAndPolicyViewController {
    static func loadFromStoryboard(_ storyBoardName: String, _ identifier: String) -> Self? {
        let storyboardVC = UIStoryboard(name: storyBoardName, bundle: nil).instantiateViewController(withIdentifier: identifier)
        return storyboardVC as? Self
    }
    
    static func getPolicyPopped() -> Bool {
        return UserDefaults.standard.bool(forKey: storeKey)
    }
    
    static func setPolicyPopped(_ state: Bool) {
        return UserDefaults.standard.setValue(state, forKey: storeKey)
    }
}
