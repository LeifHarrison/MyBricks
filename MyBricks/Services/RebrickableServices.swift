//
//  RebrickableServices.swift
//  MyBricks
//
//  Created by Leif Harrison on 12/8/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import Alamofire
import Foundation
import KeychainAccess
import UIKit

class RebrickableServices: AuthenticatedServiceAPI {
    
    static let shared = RebrickableServices()
    
    private let keychainServiceName = "com.rebrickable.userToken"
    private let userNameKey = "RebrickableUsername"

    let baseURL = "https://rebrickable.com/api/v3/"

    private let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private let longDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        return formatter
    }()
    
    //--------------------------------------------------------------------------
    // MARK: - Login
    //--------------------------------------------------------------------------
    
    class func isLoggedIn() -> Bool {
        return RebrickableServices.shared.isLoggedIn
    }
    
    var isLoggedIn: Bool {
        let keychain = Keychain(service: keychainServiceName)
        if let username = UserDefaults.standard.value(forKey: userNameKey) as? String, keychain[username] != nil {
            return true
        }
        else {
            return false
        }
    }
    
    var userName: String? {
        let keychain = Keychain(service: keychainServiceName)
        if let username = UserDefaults.standard.value(forKey: userNameKey) as? String, keychain[username] != nil {
            return username
        }
        return nil
    }
    
    var loginProtectionSpace: URLProtectionSpace? {
        if let url = URL(string: baseURL), let host = url.host {
            return URLProtectionSpace(host: host, port: url.port ?? 0, protocol: NSURLProtectionSpaceHTTPS, realm: host, authenticationMethod: NSURLAuthenticationMethodDefault)
        }
        return nil
    }
    
    var logoImage: UIImage? {
        return #imageLiteral(resourceName: "logo_rebrickable")
    }
    
    // Log in as a user and retrieve a token that can be used in subsequent API calls.
    func login(username: String, password: String, completion: @escaping (Result<String, ServiceError>) -> Void) {
        var parameters: Parameters = [:]
        parameters["username"] = username
        parameters["password"] = password
        
        let url = baseURL + "users/_token/"
        let headers = defaultHeaders()
        let request = Session.default.request( url, method: .post, parameters: parameters, headers: headers )
        
        let requestCompletion: ((AFDataResponse<Any>) -> Void) = { response in
            switch response.result {
                case .success(let value):
                    guard let valueDict = value as? [String: Any], let token = valueDict["user_token"] as? String else {
                        NSLog("Malformed data received from token service")
                        completion(.failure(ServiceError.loginFailed(reason:"Malformed data received from token service")))
                        return
                    }

                    UserDefaults.standard.setValue(username, forKey: self.userNameKey)
                    let keychain = Keychain(service: self.keychainServiceName)
                    keychain[username] = token
                    
                    completion(.success(token))

                case .failure(let error):
                    NSLog("Error while generating token: \(error.localizedDescription)")
                    completion(.failure(ServiceError.loginFailed(reason: error.localizedDescription)))
            }
        }
        request.responseJSON(completionHandler: requestCompletion)
    }
    
    func logout(_ completion: @escaping () -> Void) {
        let keychain = Keychain(service: keychainServiceName)
        if let username = UserDefaults.standard.value(forKey: userNameKey) as? String, keychain[username] != nil {
            keychain[username] = nil
            UserDefaults.standard.removeObject(forKey: userNameKey)
        }
        completion()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Lego
    //--------------------------------------------------------------------------

    // Get Parts
    // URL: https://rebrickable.com/api/v3/lego/sets/<set number>/parts/
    @discardableResult
    func getParts(setNumber: String, pageURL: String? = nil, completion: @escaping (Result<GetPartsResponse, ServiceError>) -> Void) -> DataRequest {
        let url = pageURL ?? baseURL + "lego/sets/" + setNumber + "/parts/"
        let headers = defaultHeaders()
        let request = Session.default.request( url, method: .get, headers: headers )
        let requestCompletion: ((AFDataResponse<Data>) -> Void) = { response in
            switch response.result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    do {
                        let decodedResponse = try decoder.decode(GetPartsResponse.self, from: data)
                        completion(.success(decodedResponse))
                    }
                    catch {
                        completion(.failure(ServiceError.decodeError(reason:error.localizedDescription)))
                    }
                case .failure(let error):
                    NSLog("Error: \(error)")
                    completion(.failure(ServiceError.serviceFailure(reason:error.localizedDescription)))
            }
        }
        request.responseData(completionHandler: requestCompletion)
        return request
    }

    //--------------------------------------------------------------------------
    // MARK: - User
    //--------------------------------------------------------------------------
    
    // Get Parts
    // URL: https://rebrickable.com/api/v3/users/<user_token>/profile/
    @discardableResult
    func getProfile(completion: @escaping (Result<RebrickableProfile, ServiceError>) -> Void) -> DataRequest? {
        guard let userToken = userToken() else {
            completion(.failure(ServiceError.serviceFailure(reason: "Missing user token")))
            return nil
        }
        
        let url = baseURL + "users/" + userToken + "/profile/"
        let headers = defaultHeaders()
        let request = Session.default.request(url, method: .get, headers: headers)
        let requestCompletion: ((AFDataResponse<Data>) -> Void) = { response in
            switch response.result {
                case let .success(data):
                    let decoder = JSONDecoder()
                    do {
                        let decodedResponse = try decoder.decode(RebrickableProfile.self, from: data)
                        completion(.success(decodedResponse))
                    }
                    catch {
                        completion(.failure(ServiceError.decodeError(reason:error.localizedDescription)))
                    }
                case let .failure(error):
                    NSLog("Error: \(error)")
                    completion(.failure(ServiceError.serviceFailure(reason:error.localizedDescription)))
            }
        }
        request.responseData(completionHandler: requestCompletion)
        return request
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    fileprivate func defaultHeaders() -> HTTPHeaders {
        let headers: HTTPHeaders = [
            "Authorization": "key \(Constants.Rebrickable.apiKey)",
            "Accept": "application/json"
        ]
        return headers
    }
    
    fileprivate func userToken() -> String? {
        let keychain = Keychain(service: keychainServiceName)
        if let username = UserDefaults.standard.value(forKey: userNameKey) as? String, let userToken = keychain[username] {
            return userToken
        }
        
        return nil
    }

}
