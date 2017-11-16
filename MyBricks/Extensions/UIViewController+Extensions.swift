//
//  UIViewController+Extensions.swift
//  MyBricks
//
//  Created by Leif Harrison on 8/1/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit
import LocalAuthentication

extension UIViewController {

    func addGradientBackground() {
        let gradientView = GradientView(frame: view.bounds)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.startColor = UIColor(white: 0.95, alpha: 1.0)
        gradientView.endColor = UIColor(white: 0.85, alpha: 1.0)
        gradientView.startPointX = 0.5
        gradientView.startPointY = 0
        gradientView.endPointX = 0.5
        gradientView.endPointY = 1
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

    func evaluateBiometricAuthentication(credential: URLCredential, completion: @escaping ((Bool)->Void)) {
        let myContext = LAContext()
        let myLocalizedReasonString = "Login to your Brickset account"

        var authError: NSError?
        if #available(iOS 8.0, macOS 10.12.1, *) {
            if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
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
        else {
            // Fallback on earlier versions
            print("Biometric authentication not supported.")
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

    func displayLocalAuthenticationError(error:LAError) {
        var message = ""
        switch error.code {
        case LAError.authenticationFailed:
            message = "Authentication was not successful because the user failed to provide valid credentials."
            break
        case LAError.userCancel:
            message = "Authentication was canceled by the user"
            break
        case LAError.userFallback:
            message = "Authentication was canceled because the user tapped the fallback button"
            break
        case LAError.touchIDNotEnrolled:
            message = "Authentication could not start because Touch ID has no enrolled fingers."
        case LAError.passcodeNotSet:
            message = "Passcode is not set on the device."
            break
        case LAError.systemCancel:
            message = "Authentication was canceled by system"
            break
        default:
            message = error.localizedDescription
        }

        self.showAlertWith(title: "Authentication Failed", message: message)
    }

    func showAlertWith(title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(actionButton)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
