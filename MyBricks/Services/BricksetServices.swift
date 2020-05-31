//
//  BricksetServices.swift
//  MyBricks
//
//  Created by Leif Harrison on 7/14/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import Foundation

import Alamofire
import AlamofireRSSParser
import KeychainAccess

enum ServiceError: Error {
    case loginFailed(reason: String)
    case serviceFailure(reason: String)
    case decodeError(reason: String)
    case unknownError
}

extension ServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            case .loginFailed(let reason):
                return reason
            case .serviceFailure(let reason):
                return reason
            case .decodeError(let reason):
                return reason
            case .unknownError:
                return "Unknown service error."
        }
    }
}

typealias GetThemesCompletion = (Result<[SetTheme], ServiceError>) -> Void
typealias GetSubthemesCompletion = (Result<[SetSubtheme], ServiceError>) -> Void
typealias GetYearsCompletion = (Result<[SetYear], ServiceError>) -> Void

class BricksetServices: AuthenticatedServiceAPI {

    static let shared = BricksetServices()
    
    private let keychainServiceName = "com.brickset.userHash"
    private let userNameKey = "BricksetUsername"

    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let longDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        return formatter
    }()

    let baseURL = "https://brickset.com/api/v3.asmx/"

    //--------------------------------------------------------------------------
    // MARK: - General Services
    //--------------------------------------------------------------------------

    // Check if an API key is valid.
    func checkKey(completion: @escaping (Result<Bool, ServiceError>) -> Void) {
        let url = baseURL + "checkKey"
        let parameters = defaultParameters()

        let request = AF.request( url, parameters: parameters)
        let requestCompletion: (AFDataResponse<BricksetBasicResponse>) -> Void = { dataResponse in
            switch dataResponse.result {
                case .success(let response):
                    if response.status == "success" {
                        completion(.success(true))
                    }
                    else if let error = response.message {
                        completion(.failure(.serviceFailure(reason: error)))
                    }
                    else {
                        completion(.failure(.unknownError))
                    }
                case .failure(let error):
                    NSLog("Error checking API key: \(error.localizedDescription)")
                    completion(.failure(.serviceFailure(reason: error.localizedDescription)))
            }
        }
        request.responseDecodable(of: BricksetBasicResponse.self, completionHandler: requestCompletion)
    }

    //--------------------------------------------------------------------------
    // MARK: - Login
    //--------------------------------------------------------------------------
    
    class func isLoggedIn() -> Bool {
        return BricksetServices.shared.isLoggedIn
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
        return #imageLiteral(resourceName: "logo_brickset")
    }
    
    // Log in as a user and retrieve a token that can be used in subsequent API calls.
    func login(username: String, password: String, completion: @escaping (Result<String, ServiceError>) -> Void) {
        let url = baseURL + "login"
        var parameters = defaultParameters()
        parameters["username"] = username
        parameters["password"] = password

        let request = AF.request( url, parameters: parameters)
        let requestCompletion: (AFDataResponse<BricksetLoginResponse>) -> Void = { dataResponse in
            switch dataResponse.result {
                case .success(let response):
                    guard let userHash = response.hash else {
                        completion(.failure(.serviceFailure(reason: "Response missing user hash!")))
                        return
                    }
                    UserDefaults.standard.setValue(username, forKey: self.userNameKey)
                    let keychain = Keychain(service: self.keychainServiceName)
                    keychain[username] = userHash
                    completion(.success(userHash))

                case .failure(let error):
                    completion(.failure(.serviceFailure(reason: error.localizedDescription)))
            }
        }
        request.responseDecodable(of: BricksetLoginResponse.self, completionHandler: requestCompletion)
    }

    // Check if a userHash key is valid.
    func checkUserHash(completion: @escaping (Result<Bool, ServiceError>) -> Void) {
        let url = baseURL + "checkUserHash"
        var parameters = defaultParameters()

        let keychain = Keychain(service: keychainServiceName)
        guard let username = UserDefaults.standard.value(forKey: userNameKey) as? String, let userHash = keychain[username] else {
            completion(.failure(ServiceError.unknownError))
            return
        }
        parameters["userHash"] = userHash

        let request = AF.request( url, parameters: parameters)
        let requestCompletion: (AFDataResponse<BricksetBasicResponse>) -> Void = { dataResponse in
            switch dataResponse.result {
                case .success(let response):
                    if response.status == "success" {
                        completion(.success(true))
                    }
                    else if let error = response.message {
                        completion(.failure(.serviceFailure(reason: error)))
                    }
                    else {
                        completion(.failure(.unknownError))
                    }

                case .failure(let error):
                    completion(.failure(.serviceFailure(reason: error.localizedDescription)))
            }
        }
        request.responseDecodable(of: BricksetBasicResponse.self, completionHandler: requestCompletion)
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
    // MARK: - Themes/Subthemes/Years
    //--------------------------------------------------------------------------
    
    func getThemes(completion: @escaping GetThemesCompletion) {
        let url = baseURL + "getThemes"
        
        let parameters = defaultParameters()
        let request = AF.request(url, parameters: parameters)
        let requestCompletion: (AFDataResponse<BricksetGetThemesResponse>) -> Void = { dataResponse in
            switch dataResponse.result {
                case .success(let response):
                    completion(.success(response.themes ?? []))

                case .failure(let error):
                    completion(.failure(.serviceFailure(reason: error.localizedDescription)))
            }
        }
        request.responseDecodable(of: BricksetGetThemesResponse.self, completionHandler: requestCompletion)
    }
    
    // Not available in Brickset v3 API
//    func getThemesForUser(owned: Bool, wanted: Bool, completion: @escaping GetThemesCompletion) {
//        let url = baseURL + "getThemesForUser"
//
//        var parameters = userParameters()
//        parameters["owned"] = owned ? "1" : ""
//        parameters["wanted"] = wanted ? "1" : ""
//
//        let request = AF.request( url, parameters: parameters)
//        let requestCompletion: (AFDataResponse<BricksetGetThemesResponse>) -> Void = { dataResponse in
//            switch dataResponse.result {
//                case .success(let response):
//                    completion(.success(response.themes ?? []))
//
//                case .failure(let error):
//                    completion(.failure(.serviceFailure(reason: error.localizedDescription)))
//            }
//        }
//        request.responseDecodable(of: BricksetGetThemesResponse.self, completionHandler: requestCompletion)
//    }
    
    func getSubthemes(theme: String, completion: @escaping GetSubthemesCompletion) {
        let url = baseURL + "getSubthemes"

        var parameters = defaultParameters()
        parameters["theme"] = theme

        let request = AF.request( url, parameters: parameters)
        let requestCompletion: (AFDataResponse<BricksetGetSubthemesResponse>) -> Void = { dataResponse in
            switch dataResponse.result {
                case .success(let response):
                    completion(.success(response.subthemes ?? []))

                case .failure(let error):
                    completion(.failure(.serviceFailure(reason: error.localizedDescription)))
            }
        }
        request.responseDecodable(of: BricksetGetSubthemesResponse.self, completionHandler: requestCompletion)
    }
    
    // Not available in Brickset v3 API
//    func getSubthemesForUser(theme: String, owned: Bool, wanted: Bool, completion: @escaping GetSubthemesCompletion) {
//        let url = baseURL + "getSubthemes"
//
//        var parameters = userParameters()
//        parameters["theme"] = theme
//        parameters["owned"] = owned ? "1" : ""
//        parameters["wanted"] = wanted ? "1" : ""
//
//        let request = AF.request( url, parameters: parameters)
//        let requestCompletion: (AFDataResponse<BricksetGetSubthemesResponse>) -> Void = { dataResponse in
//            switch dataResponse.result {
//                case .success(let response):
//                    completion(.success(response.subthemes ?? []))
//
//                case .failure(let error):
//                    completion(.failure(.serviceFailure(reason: error.localizedDescription)))
//            }
//        }
//        request.responseDecodable(of: BricksetGetSubthemesResponse.self, completionHandler: requestCompletion)
//    }
    
    func getYears(theme: String, completion: @escaping GetYearsCompletion) {
        let url = baseURL + "getYears"

        var parameters = defaultParameters()
        parameters["theme"] = theme

        let request = AF.request( url, parameters: parameters)
        let requestCompletion: (AFDataResponse<BricksetGetYearsResponse>) -> Void = { dataResponse in
            switch dataResponse.result {
                case .success(let response):
                    completion(.success(response.years ?? []))

                case .failure(let error):
                    completion(.failure(.serviceFailure(reason: error.localizedDescription)))
            }
        }
        request.responseDecodable(of: BricksetGetYearsResponse.self, completionHandler: requestCompletion)
    }
    
    // Not available in Brickset v3 API
//    func getYearsForUser(theme: String, owned: Bool, wanted: Bool, completion: @escaping GetYearsCompletion) {
//        let url = baseURL + "getYears"
//
//        var parameters = userParameters()
//        parameters["theme"] = theme
//        parameters["owned"] = owned ? "1" : ""
//        parameters["wanted"] = wanted ? "1" : ""
//
//        let request = AF.request( url, parameters: parameters)
//        let requestCompletion: (AFDataResponse<BricksetGetYearsResponse>) -> Void = { dataResponse in
//            switch dataResponse.result {
//                case .success(let response):
//                    completion(.success(response.years ?? []))
//
//                case .failure(let error):
//                    completion(.failure(.serviceFailure(reason: error.localizedDescription)))
//            }
//        }
//        request.responseDecodable(of: BricksetGetYearsResponse.self, completionHandler: requestCompletion)
//    }
    
    //--------------------------------------------------------------------------
    // MARK: - Sets
    //--------------------------------------------------------------------------

    // Retrieve a list of sets. All parameters except apiKey are optional but must be passed as blanks if not used.
    @discardableResult func getSets(_ request: BricksetGetSetsRequest, completion: @escaping (Result<[SetDetail], ServiceError>) -> Void) -> Request {
        let url = baseURL + "getSets"

        var parameters = userParameters()

        let jsonData = try! JSONEncoder().encode(request)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        parameters["params"] = jsonString

        let request = AF.request(url, parameters: parameters)
        let requestCompletion: (AFDataResponse<BricksetGetSetsResponse>) -> Void = { dataResponse in
            switch dataResponse.result {
                case .success(let response):
                    completion(.success(response.sets ?? []))
                case .failure(let error):
                    completion(.failure(.serviceFailure(reason: error.localizedDescription)))
            }
        }
        request.responseDecodable(of: BricksetGetSetsResponse.self, completionHandler: requestCompletion)
        return request
    }

    // Convenience cover to getSets for just a specific setID
    @discardableResult func getSet(setID: Int, completion: @escaping (Result<SetDetail, ServiceError>) -> Void) -> Request {
        let setRequest = BricksetGetSetsRequest(setID: setID, includeExtendedData: true)
        let innerCompletion: (Result<[SetDetail], ServiceError>) -> Void = { result in
            switch result {
                case .success(let sets):
                    if let firstSet = sets.first {
                        completion(.success(firstSet))
                    }
                    else {
                        completion(.failure(.serviceFailure(reason: "No results")))
                }
                case .failure(let error):
                    completion(.failure(error))
            }
        }
        return getSets(setRequest, completion: innerCompletion)
    }

    func getReviews(setID: Int, completion: @escaping (Result<[SetReview], ServiceError>) -> Void) {
        let url = baseURL + "getReviews"

        var parameters = defaultParameters()
        parameters["setID"] = setID

        let request = AF.request( url, parameters: parameters)
        let requestCompletion: (AFDataResponse<BricksetGetReviewsResponse>) -> Void = { dataResponse in
             switch dataResponse.result {
                case .success(let response):
                    completion(.success(response.reviews ?? []))
                case .failure(let error):
                    completion(.failure(.serviceFailure(reason: error.localizedDescription)))
            }
        }
        request.responseDecodable(of: BricksetGetReviewsResponse.self, completionHandler: requestCompletion)
    }

    func getInstructions(setID: Int, completion: @escaping (Result<[SetInstructions], ServiceError>) -> Void) {
        let url = baseURL + "getInstructions"

        var parameters = defaultParameters()
        parameters["setID"] = setID

        let request = AF.request( url, parameters: parameters)
        let requestCompletion: (AFDataResponse<BricksetGetInstructionsResponse>) -> Void = { dataResponse in
             switch dataResponse.result {
                case .success(let response):
                    completion(.success(response.instructions ?? []))
                case .failure(let error):
                    completion(.failure(.serviceFailure(reason: error.localizedDescription)))
            }
        }
        request.responseDecodable(of: BricksetGetInstructionsResponse.self, completionHandler: requestCompletion)
    }
    
    @discardableResult func getAdditionalImages(setID: Int, completion: @escaping (Result<[SetImage], ServiceError>) -> Void) -> DataRequest {
        let url = baseURL + "getAdditionalImages"

        var parameters = defaultParameters()
        parameters["setID"] = setID

        let request = AF.request( url, parameters: parameters)
        let requestCompletion: (AFDataResponse<BricksetGetImagesResponse>) -> Void = { dataResponse in
            switch dataResponse.result {
                case .success(let response):
                    completion(.success(response.additionalImages ?? []))
                case .failure(let error):
                    completion(.failure(.serviceFailure(reason: error.localizedDescription)))
            }
        }
        request.responseDecodable(of: BricksetGetImagesResponse.self, completionHandler: requestCompletion)
        return request
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Set Collection Management
    //--------------------------------------------------------------------------

    // Not available in Brickset v3 API
    func getCollectionTotals(completion: @escaping (Result<UserCollectionTotals, ServiceError>) -> Void) {
        let url = baseURL + "getCollectionTotals"
        let parameters = userParameters()

        let request = AF.request( url, parameters: parameters)
        let requestCompletion: (AFDataResponse<Any>) -> Void = { dataResponse in
            switch dataResponse.result {
                case .success(let json):
                    NSLog("JSON: \(json)")
//                    if let root = document.root {
//                        if let collectionTotals = UserCollectionTotals(element: root) {
//                            completion(Result.success(collectionTotals))
//                        }
//                    }
                    completion(.failure(.unknownError))

                case .failure(let error):
                    completion(.failure(.serviceFailure(reason: error.localizedDescription)))
            }

        }
        request.responseJSON(completionHandler: requestCompletion)
    }

    func setCollection(setID: Int, request: BricksetSetCollectionRequest, completion: @escaping (Result<Bool, ServiceError>) -> Void) {
        let url = baseURL + "setCollection"

        var parameters = userParameters()
        parameters["SetID"] = setID

        let jsonData = try! JSONEncoder().encode(request)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        parameters["params"] = jsonString

        let request = AF.request(url, method: .post,parameters: parameters)
        let requestCompletion: (AFDataResponse<BricksetBasicResponse>) -> Void = { dataResponse in
            switch dataResponse.result {
                case .success(let response):
                    if response.status == "success" {
                        completion(.success(true))
                    }
                    else if let error = response.message {
                        completion(.failure(.serviceFailure(reason: error)))
                    }
                    else {
                        completion(.failure(.unknownError))
                    }
                case .failure(let error):
                    NSLog("Error updating set collection: \(error.localizedDescription)")
                    completion(.failure(.serviceFailure(reason: error.localizedDescription)))
            }
        }
        request.responseDecodable(of: BricksetBasicResponse.self, completionHandler: requestCompletion)
    }
    
    //--------------------------------------------------------------------------
    // MARK: - RSS Feeds
    //--------------------------------------------------------------------------

    func getNews(completion: @escaping (Result<RSSFeed, ServiceError>) -> Void) {
        let url = "https://brickset.com/feed"
        let request = AF.request(url)
        let requestCompletion: (AFDataResponse<RSSFeed>) -> Void = { dataResponse in
            switch dataResponse.result {
                case .success(let feed):
                    completion(.success(feed))

                case .failure(let error):
                    completion(.failure(.serviceFailure(reason: error.localizedDescription)))
            }
        }
        request.responseRSS(completionHandler: requestCompletion)
    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    fileprivate func defaultParameters() -> Parameters {
        return ["apiKey": Constants.Brickset.apiKey]
        //return ["apiKey": "TestBadAPIKey"]
    }
    
    fileprivate func userParameters() -> Parameters {
        var parameters = defaultParameters()

        let keychain = Keychain(service: keychainServiceName)
        if let username = UserDefaults.standard.value(forKey: userNameKey) as? String, let userHash = keychain[username] {
            parameters["userHash"] = userHash
            //parameters["userHash"] = "TestBadUserHash"
        }
        else {
            parameters["userHash"] = ""
            //parameters["userHash"] = "TestBadUserHash"
        }

        return parameters
    }

}

extension Formatters {
    
    static let bricksetDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
}
