//
//  UIViewController+Extensions.swift
//  MyBricks
//
//  Created by Leif Harrison on 8/1/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit
import LocalAuthentication

extension UIViewController {

    func addGradientBackground() {
        let gradientView = GradientView(frame: view.bounds)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.startColor = UIColor.white
        gradientView.endColor = UIColor.cloudyBlue
        view.insertSubview(gradientView, at: 0)

        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            let top = gradientView.topAnchor.constraint(equalTo: guide.topAnchor)
            let bottom = guide.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor)
            let leading = gradientView.leadingAnchor.constraint(equalTo: guide.leadingAnchor)
            let trailing = guide.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor)
            NSLayoutConstraint.activate([top, bottom, leading, trailing])
        }
        else {
            let top = gradientView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor)
            let bottom = bottomLayoutGuide.topAnchor.constraint(equalTo: gradientView.bottomAnchor)
            let leading = gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            let trailing = view.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor)
            NSLayoutConstraint.activate([top, bottom, leading, trailing])
        }
    }

    func hideKeyboardWhenViewTapped() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func evaluateBiometricAuthentication(credential: URLCredential, completion: @escaping ((Bool)->Void)) {
        let myContext = LAContext()

        var authError: NSError?
        if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            let myLocalizedReasonString = NSLocalizedString("Login to your Brickset account", comment: "")
            myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString) { success, evaluateError in
                if success {
                    // User authenticated successfully, take appropriate action
                    NSLog("Biometric authentication success!")
                    DispatchQueue.main.async {
                        self.performLogin(credential: credential, completion: completion)
                    }
                }
                else if let error = evaluateError as? LAError {
                    // User did not authenticate successfully, look at error and take appropriate action
                    NSLog("Biometric authentication error: \(String(describing: evaluateError))")
                    if error.code == LAError.userFallback {
                        DispatchQueue.main.async {
                            self.showLoginView()
                        }
                    }
                    else if error.code == LAError.userCancel {
                        DispatchQueue.main.async {
                            completion(false)
                        }
                        return
                    }
                    else {
                        DispatchQueue.main.async {
                            self.showAlertWith(title: "Authentication Failed", message: self.evaluateAuthenticationPolicyMessage(forError: error))
                            self.displayLocalAuthenticationError(error: error)
                        }
                    }
                }
            }
        }
        else if let error = authError as? LAError {
            // Could not evaluate policy; look at authError and present an appropriate message to user
            NSLog("Biometric authentication error: \(String(describing: error))")
            showLoginView()
        }
    }

    func showLoginView() {
        let profileStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        if let loginVC = profileStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            present(loginVC, animated: true, completion: nil)
        }
    }

    func performLogin(credential: URLCredential, completion: @escaping ((Bool)->Void)) {
        if let username = credential.user, let password = credential.password {
            BricksetServices.shared.login(username: username, password: password, completion: { result in
                NSLog("Result: \(result)")
                if result.isSuccess {
                    completion(true)
                }
                else {
                    let alert = UIAlertController(title: "Error", message: result.error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        completion(true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                    self.performSegue(withIdentifier: "showLoginView", sender: self)
                }
            })
        }

    }

    func evaluatePolicyFailErrorMessage(forError error: LAError) -> String {
        var message = ""
        
        switch error {
            case LAError.biometryNotAvailable:
                message = "Authentication could not start because the device does not support biometric authentication."
            case LAError.biometryLockout:
                message = "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."
            case LAError.biometryNotEnrolled:
                message = "Authentication could not start because the user has not enrolled in biometric authentication."
            default:
                message = "Unknown Authentication Error"
        }

        return message;
    }
    
    func evaluateAuthenticationPolicyMessage(forError error: LAError) -> String {
        var message = ""
        
        switch error {
            case LAError.authenticationFailed:
                message = "The user failed to provide valid credentials"
            case LAError.appCancel:
                message = "Authentication was cancelled by application"
            case LAError.invalidContext:
                message = "The context is invalid"
            case LAError.notInteractive:
                message = "Not interactive"
            case LAError.passcodeNotSet:
                message = "Passcode is not set on the device"
            case LAError.systemCancel:
                message = "Authentication was cancelled by the system"
            case LAError.userCancel:
                message = "Authentication was cancelled by the user"
            case LAError.userFallback:
                message = "The user chose to use the fallback authentication method"
            default:
                message = evaluatePolicyFailErrorMessage(forError: error)
        }
        
        return message
    }

    func displayLocalAuthenticationError(error:LAError) {
        let message = evaluateAuthenticationPolicyMessage(forError: error)
        self.showAlertWith(title: "Authentication Failed", message: message)
    }

    func showAlertWith(title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(actionButton)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
