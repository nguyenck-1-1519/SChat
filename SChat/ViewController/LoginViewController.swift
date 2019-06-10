//
//  LoginViewController.swift
//  SChat
//
//  Created by can.khac.nguyen on 6/10/19.
//  Copyright © 2019 Can Khac Nguyen. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func signIn() {
        Auth.auth().signInAnonymously { [weak self] (result, error) in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in

                })
                alert.addAction(okAction)
                self?.present(alert, animated: true, completion: nil)
                return
            }
            self?.onLoginSuccess()
        }
    }

    func onLoginSuccess() {
        AppSettings.currentUserName = nicknameTextField.text ?? ""
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let window = appDelegate.window {
            let nav = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "nav")
            window.rootViewController = nav
        }
    }

    @IBAction func onNicknameTextFieldDidChanged(_ sender: UITextField) {
        guard let nickname = sender.text else {
            sender.isEnabled = false
            return
        }
        loginButton.isEnabled = !nickname.isEmpty
    }

    @IBAction func onLoginButtonClicked(_ sender: UIButton) {
        signIn()
    }

    @IBAction func onTextFieldDidEndEditing(_ sender: UITextField) {
        signIn()
    }
}
