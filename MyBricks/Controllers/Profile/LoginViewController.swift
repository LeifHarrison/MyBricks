//
//  LoginViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/11/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.applyDefaultStyle()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        usernameField.becomeFirstResponder()
    }

    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------

    @IBAction func login(_ sender: AnyObject?) {
        if let username = usernameField.text, let password = passwordField.text {
            BricksetServices.shared.login(username: username, password: password, completion: { result in
                if result.isSuccess {
                    let myContext = LAContext()
                    let myLocalizedReasonString = "Login to your Brickset account"

                    var authError: NSError?
                    if #available(iOS 8.0, macOS 10.12.1, *) {
                        if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                            myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString) { success, evaluateError in
                                if success {
                                    // User authenticated successfully, take appropriate action
                                    let credential = URLCredential(user: username, password: password, persistence: .permanent)
                                    if let protectionSpace = BricksetServices.shared.loginProtectionSpace {
                                        URLCredentialStorage.shared.setDefaultCredential(credential, for: protectionSpace)
                                    }
                                    NSLog("Biometric authentication success!")
                                    self.dismiss(animated: true, completion: nil)
                                }
                                else {
                                    // User did not authenticate successfully, look at error and take appropriate action
                                    NSLog("Biometric authentication error: \(String(describing: evaluateError))")
                                }
                            }
                        }
                        else {
                            // Could not evaluate policy; look at authError and present an appropriate message to user
                            NSLog("Biometric authentication error: \(String(describing: authError))")
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                    else {
                        // Fallback on earlier versions
                        NSLog("Biometric authentication not supported.")
                        self.dismiss(animated: true, completion: nil)
                    }

                }
                else {
                    let alert = UIAlertController(title: "Error", message: result.error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }

    @IBAction func cancel(_ sender: AnyObject?) {
        dismiss(animated: true, completion: nil)
    }

}

//==============================================================================
// MARK: - UITextFieldDelegate
//==============================================================================

extension LoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            passwordField.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
            login(self)
        }
        return false
    }
}
