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
        gradientView.startColor = UIColor(white: 0.95, alpha: 1.0)
        gradientView.endColor = UIColor(white: 0.85, alpha: 1.0)
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
                    print("Biometric authentication success!")
                    DispatchQueue.main.async {
                        self.performLogin(credential: credential, completion: completion)
                    }
                }
                else if let error = evaluateError as? LAError {
                    // User did not authenticate successfully, look at error and take appropriate action
                    print("Biometric authentication error: \(String(describing: evaluateError))")
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
                            self.showAlertWith(title: "Authentication Failed", message: self.evaluateAuthenticationPolicyMessage(forErrorCode: error.errorCode))
                            self.displayLocalAuthenticationError(error: error)
                        }
                    }
                }
            }
        }
        else if let error = authError as? LAError {
            // Could not evaluate policy; look at authError and present an appropriate message to user
            print("Biometric authentication error: \(String(describing: error))")
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
                print("Result: \(result)")
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

    func evaluatePolicyFailErrorMessage(forErrorCode errorCode: Int) -> String {
        var message = ""
        
        switch errorCode {
            case LAError.biometryNotAvailable.rawValue:
                message = "Authentication could not start because the device does not support biometric authentication."
            case LAError.biometryLockout.rawValue:
                message = "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."
            case LAError.biometryNotEnrolled.rawValue:
                message = "Authentication could not start because the user has not enrolled in biometric authentication."
            default:
                message = "Did not find error code on LAError object"
        }

        return message;
    }
    
    func evaluateAuthenticationPolicyMessage(forErrorCode errorCode: Int) -> String {
        var message = ""
        
        switch errorCode {
            case LAError.authenticationFailed.rawValue:
                message = "The user failed to provide valid credentials"
            case LAError.appCancel.rawValue:
                message = "Authentication was cancelled by application"
            case LAError.invalidContext.rawValue:
                message = "The context is invalid"
            case LAError.notInteractive.rawValue:
                message = "Not interactive"
            case LAError.passcodeNotSet.rawValue:
                message = "Passcode is not set on the device"
            case LAError.systemCancel.rawValue:
                message = "Authentication was cancelled by the system"
            case LAError.userCancel.rawValue:
                message = "The user did cancel"
            case LAError.userFallback.rawValue:
                message = "The user chose to use the fallback"
            default:
                message = evaluatePolicyFailErrorMessage(forErrorCode: errorCode)
        }
        
        return message
    }

    func displayLocalAuthenticationError(error:LAError) {
        let message = evaluateAuthenticationPolicyMessage(forErrorCode: error.errorCode)
        self.showAlertWith(title: "Authentication Failed", message: message)
    }

    func showAlertWith(title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(actionButton)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
