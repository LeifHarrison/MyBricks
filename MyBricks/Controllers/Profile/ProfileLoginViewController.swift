//
//  ProfileLoginViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/11/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit
import LocalAuthentication

class ProfileLoginViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicatorView: ActivityIndicatorView!

    var serviceAPI: AuthenticatedServiceAPI?
    
    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorView.style = .large
        activityIndicatorView.tintColor = UIColor.lightBlueGrey
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let image = serviceAPI?.logoImage {
            imageView.image = image
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        usernameField.becomeFirstResponder()
    }

    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------

    @IBAction func login(_ sender: AnyObject?) {
        guard let api = serviceAPI else { return }
        
        if let username = usernameField.text, let password = passwordField.text {
            activityIndicatorView.startAnimating()
            api.login(username: username, password: password, completion: { result in
                self.activityIndicatorView.stopAnimating()
                if result.isSuccess {
                    let myContext = LAContext()

                    var authError: NSError?
                    if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                        let reason = "Enabling Touch ID allows you quick and secure access to your Brickset account."
                        myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, evaluateError in
                            if success {
                                // User authenticated successfully, take appropriate action
                                let credential = URLCredential(user: username, password: password, persistence: .permanent)
                                if let protectionSpace = api.loginProtectionSpace {
                                    URLCredentialStorage.shared.setDefaultCredential(credential, for: protectionSpace)
                                }
                                NSLog("Biometric authentication success!")
                                self.dismiss(animated: true, completion: nil)
                            }
                            else {
                                // User did not authenticate successfully, look at error and take appropriate action
                                NSLog("Biometric authentication error: \(String(describing: evaluateError))")
                                self.dismiss(animated: true, completion: nil)
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

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    fileprivate func evaluateBiometricAuthentication(credential: URLCredential) {
    }
    
}

//==============================================================================
// MARK: - UITextFieldDelegate
//==============================================================================

extension ProfileLoginViewController: UITextFieldDelegate {

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
