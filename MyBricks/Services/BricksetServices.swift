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
import Fuzi
import KeychainAccess

// swiftlint:disable file_length, type_body_length

enum ServiceError: Error {
    case serviceFailure(reason: String)
    case loginFailed(reason: String)
    case unknownError
}

typealias GetThemesCompletion = (Result<[SetTheme]>) -> Void
typealias GetSubthemesCompletion = (Result<[SetSubtheme]>) -> Void
typealias GetYearsCompletion = (Result<[SetYear]>) -> Void

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

    let baseURL = "https://brickset.com/api/v2.asmx/"

    //--------------------------------------------------------------------------
    // MARK: - General Services
    //--------------------------------------------------------------------------

    // Check if an API key is valid.
    func checkKey(completion: @escaping (Result<Bool>) -> Void) {
        let url = baseURL + "checkKey"
        let parameters = defaultParameters()

        let request = Alamofire.request( url, parameters: parameters)
        let requestCompletion: (DataResponse<XMLDocument>) -> Void = { response in
            if let error = response.result.error {
                completion(Result.failure(error))
            }
            else if let document = response.result.value, let result = document.root?.stringValue {
                if result.contains("ERROR") {
                    let array = result.components(separatedBy: ": ")
                    if array.count > 0 {
                        let errorDetail = array[1]
                        completion(Result.failure(ServiceError.serviceFailure(reason:errorDetail)))
                        return
                    }
                }

                if result.contains("OK") {
                    completion(Result.success(true))
                }
                else if result.contains("INVALIDKEY") {
                    completion(Result.success(false))
                }
                else {
                    completion(Result.failure(ServiceError.unknownError))
                }

            }
        }
        request.responseXMLDocument(completionHandler: requestCompletion)
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
    func login(username: String, password: String, completion: @escaping (Result<String>) -> Void) {
        let url = baseURL + "login"
        var parameters = defaultParameters()
        parameters["username"] = username
        parameters["password"] = password

        let request = Alamofire.request( url, parameters: parameters)
        let requestCompletion: (DataResponse<XMLDocument>) -> Void = { response in
            if let error = response.result.error {
                completion(Result.failure(error))
            }
            else if let document = response.result.value, let result = document.root?.stringValue {
                if result.contains("ERROR") {
                    let array = result.components(separatedBy: ": ")
                    if array.count > 0 {
                        let errorDetail = array[1]
                        completion(Result.failure(ServiceError.loginFailed(reason:errorDetail)))
                        return
                    }
                }
                
                UserDefaults.standard.setValue(username, forKey: self.userNameKey)
                let keychain = Keychain(service: self.keychainServiceName)
                keychain[username] = result

                completion(Result.success(result))
            }
        }

        request.responseXMLDocument(completionHandler: requestCompletion)
    }

    // Check if a userHash key is valid.
    func checkUserHash(completion: @escaping (Result<Bool>) -> Void) {
        let url = baseURL + "checkUserHash"
        var parameters = defaultParameters()

        let keychain = Keychain(service: keychainServiceName)
        guard let username = UserDefaults.standard.value(forKey: userNameKey) as? String, let userHash = keychain[username] else {
            completion(Result.failure(ServiceError.unknownError))
            return
        }
        parameters["userHash"] = userHash

        let request = Alamofire.request( url, parameters: parameters)
        let requestCompletion: (DataResponse<XMLDocument>) -> Void = { response in
            if let error = response.result.error {
                completion(Result.failure(error))
            }
            else if let document = response.result.value, let result = document.root?.stringValue {
                if result.contains("ERROR") {
                    let array = result.components(separatedBy: ": ")
                    if array.count > 0 {
                        let errorDetail = array[1]
                        completion(Result.failure(ServiceError.loginFailed(reason:errorDetail)))
                        return
                    }
                }

                if result.contains(username) {
                    completion(Result.success(true))
                }
                else if result.contains("INVALID") {
                    completion(Result.success(false))
                }
                else {
                    completion(Result.failure(ServiceError.unknownError))
                }
            }
        }
        request.responseXMLDocument(completionHandler: requestCompletion)
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
        let request = Alamofire.request( url, parameters: parameters)
        let requestCompletion: (DataResponse<XMLDocument>) -> Void = { response in
            if let error = response.result.error {
                completion(Result.failure(error))
            }
            else if let document = response.result.value {
                if let root = document.root {
                    var themes: [SetTheme] = []
                    
                    for element in root.children {
                        if let theme = SetTheme(element: element) {
                            themes.append(theme)
                        }
                    }
                    
                    completion(Result.success(themes))
                }
            }
        }
        request.responseXMLDocument(completionHandler: requestCompletion)
    }
    
    func getThemesForUser(owned: Bool, wanted: Bool, completion: @escaping GetThemesCompletion) {
        let url = baseURL + "getThemesForUser"
        
        var parameters = userParameters()
        parameters["owned"] = owned ? "1" : ""
        parameters["wanted"] = wanted ? "1" : ""

        let request = Alamofire.request( url, parameters: parameters)
        let requestCompletion: (DataResponse<XMLDocument>) -> Void = { response in
            if let error = response.result.error {
                completion(Result.failure(error))
            }
            else if let document = response.result.value {
                if let root = document.root {
                    var themes: [SetTheme] = []
                    
                    for element in root.children {
                        if let theme = SetTheme(element: element) {
                            themes.append(theme)
                        }
                    }
                    
                    completion(Result.success(themes))
                }
            }
        }
        request.responseXMLDocument(completionHandler: requestCompletion)
    }
    
    func getSubthemes(theme: String, completion: @escaping GetSubthemesCompletion) {
        let url = baseURL + "getSubthemes"
        
        var parameters = defaultParameters()
        parameters["theme"] = theme

        let request = Alamofire.request( url, parameters: parameters)
        let requestCompletion: (DataResponse<XMLDocument>) -> Void = { response in
            if let error = response.result.error {
                completion(Result.failure(error))
            }
            else if let document = response.result.value {
                if let root = document.root {
                    var subthemes: [SetSubtheme] = []
                    
                    for element in root.children {
                        if let theme = SetSubtheme(element: element) {
                            subthemes.append(theme)
                        }
                    }
                    
                    completion(Result.success(subthemes))
                }
            }
        }
        request.responseXMLDocument(completionHandler: requestCompletion)
    }
    
    func getSubthemesForUser(theme: String, owned: Bool, wanted: Bool, completion: @escaping GetSubthemesCompletion) {
        let url = baseURL + "getSubthemes"
        
        var parameters = userParameters()
        parameters["theme"] = theme
        parameters["owned"] = owned ? "1" : ""
        parameters["wanted"] = wanted ? "1" : ""

        let request = Alamofire.request( url, parameters: parameters)
        let requestCompletion: (DataResponse<XMLDocument>) -> Void = { response in
            if let error = response.result.error {
                completion(Result.failure(error))
            }
            else if let document = response.result.value {
                if let root = document.root {
                    var subthemes: [SetSubtheme] = []
                    
                    for element in root.children {
                        if let theme = SetSubtheme(element: element) {
                            subthemes.append(theme)
                        }
                    }
                    
                    completion(Result.success(subthemes))
                }
            }
        }
        request.responseXMLDocument(completionHandler: requestCompletion)
    }
    
    func getYears(theme: String, completion: @escaping GetYearsCompletion) {
        let url = baseURL + "getYears"
        
        var parameters = defaultParameters()
        parameters["theme"] = theme
        
        let request = Alamofire.request( url, parameters: parameters)
        let requestCompletion: (DataResponse<XMLDocument>) -> Void = { response in
            if let error = response.result.error {
                completion(Result.failure(error))
            }
            else if let document = response.result.value {
                if let root = document.root {
                    var years: [SetYear] = []
                    
                    for element in root.children {
                        if let theme = SetYear(element: element) {
                            years.append(theme)
                        }
                    }
                    
                    completion(Result.success(years))
                }
            }
        }
        request.responseXMLDocument(completionHandler: requestCompletion)
    }
    
    func getYearsForUser(theme: String, owned: Bool, wanted: Bool, completion: @escaping GetYearsCompletion) {
        let url = baseURL + "getYears"
        
        var parameters = userParameters()
        parameters["theme"] = theme
        parameters["owned"] = owned ? "1" : ""
        parameters["wanted"] = wanted ? "1" : ""

        let request = Alamofire.request( url, parameters: parameters)
        let requestCompletion: (DataResponse<XMLDocument>) -> Void = { response in
            if let error = response.result.error {
                completion(Result.failure(error))
            }
            else if let document = response.result.value {
                if let root = document.root {
                    var years: [SetYear] = []
                    
                    for element in root.children {
                        if let theme = SetYear(element: element) {
                            years.append(theme)
                        }
                    }
                    
                    completion(Result.success(years))
                }
            }
        }
        request.responseXMLDocument(completionHandler: requestCompletion)
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Sets
    //--------------------------------------------------------------------------

    // Retrieve a list of sets. All parameters except apiKey are optional but must be passed as blanks if not used.
    @discardableResult func getSets(_ request: GetSetsRequest, completion: @escaping (Result<[Set]>) -> Void) -> Request {
        let url = baseURL + "getSets"

        var parameters = userParameters()
        parameters["query"] = request.query ?? ""
        parameters["theme"] = request.theme ?? ""
        parameters["subtheme"] = request.subtheme ?? ""
        parameters["setNumber"] = request.setNumber ?? ""
        parameters["year"] = request.year ?? ""
        parameters["owned"] = request.owned ? "1" : ""
        parameters["wanted"] = request.wanted ? "1" : ""
        parameters["orderBy"] = request.sortingSelection.parameterValue
        parameters["pageSize"] = "1000"
        parameters["pageNumber"] = ""
        parameters["userName"] = ""

        let request = Alamofire.request( url, parameters: parameters)
        let requestCompletion: (DataResponse<XMLDocument>) -> Void = { response in
            if let error = response.result.error {
                completion(Result.failure(error))
            }
            else if let document = response.result.value {
                if let root = document.root {
                    var sets: [Set] = []

                    for element in root.children {
                        if let set = Set(element: element) {
                            sets.append(set)
                        }
                    }

                    completion(Result.success(sets))
                }
            }
        }
        request.responseXMLDocument(completionHandler: requestCompletion)
        return request
    }

    @discardableResult func getSet(setID: String, completion: @escaping (Result<SetDetail>) -> Void) -> DataRequest {
        let url = baseURL + "getSet"

        var parameters = userParameters()
        parameters["setID"] = setID

        let request = Alamofire.request( url, parameters: parameters)
        let requestCompletion: (DataResponse<XMLDocument>) -> Void = { response in
            if let error = response.result.error {
                completion(Result.failure(error))
            }
            else if let document = response.result.value {
                if let root = document.root {
                    var sets: [SetDetail] = []

                    for element in root.children {
                        if let set = SetDetail(element: element) {
                            sets.append(set)
                        }
                    }

                    if sets.count == 1, let firstSet = sets.first {
                        completion(Result.success(firstSet))
                    }
                    else {
                        completion(Result.failure(ServiceError.unknownError))
                    }
                }
            }
        }
        request.responseXMLDocument(completionHandler: requestCompletion)
        return request
    }

    func getReviews(setID: String, completion: @escaping (Result<[SetReview]>) -> Void) {
        let url = baseURL + "getReviews"

        var parameters = defaultParameters()
        parameters["setID"] = setID

        let request = Alamofire.request( url, parameters: parameters)
        let requestCompletion: (DataResponse<XMLDocument>) -> Void = { response in
            if let error = response.result.error {
                completion(Result.failure(error))
            }
            else if let document = response.result.value {
                if let root = document.root {
                    var reviews: [SetReview] = []

                    for element in root.children {
                        if let review = SetReview(element: element) {
                            reviews.append(review)
                        }
                    }

                    completion(Result.success(reviews))
                }
            }
        }
        request.responseXMLDocument(completionHandler: requestCompletion)
    }

    func getInstructions(setID: String, completion: @escaping (Result<[SetInstructions]>) -> Void) {
        let url = baseURL + "getInstructions"
        
        var parameters = defaultParameters()
        parameters["setID"] = setID
        
        let request = Alamofire.request( url, parameters: parameters)
        let requestCompletion: (DataResponse<XMLDocument>) -> Void = { response in
            if let error = response.result.error {
                completion(Result.failure(error))
            }
            else if let document = response.result.value {
                if let root = document.root {
                    var instructions: [SetInstructions] = []
                    
                    for element in root.children {
                        if let instruction = SetInstructions(element: element) {
                            instructions.append(instruction)
                        }
                    }
                    
                    completion(Result.success(instructions))
                }
            }
        }
        request.responseXMLDocument(completionHandler: requestCompletion)
    }
    
    @discardableResult func getAdditionalImages(setID: String, completion: @escaping (Result<[SetImage]>) -> Void) -> DataRequest {
        let url = baseURL + "getAdditionalImages"
        
        var parameters = defaultParameters()
        parameters["setID"] = setID
        
        let request = Alamofire.request( url, parameters: parameters)
        let requestCompletion: (DataResponse<XMLDocument>) -> Void = { response in
            if let error = response.result.error {
                completion(Result.failure(error))
            }
            else if let document = response.result.value {
                if let root = document.root {
                    var images: [SetImage] = []
                    
                    for element in root.children {
                        if let image = SetImage(element: element) {
                            images.append(image)
                        }
                    }
                    
                    completion(Result.success(images))
                }
            }
        }
        request.responseXMLDocument(completionHandler: requestCompletion)
        return request
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Set Collection Management
    //--------------------------------------------------------------------------

    func getCollectionTotals(completion: @escaping (Result<UserCollectionTotals>) -> Void) {
        let url = baseURL + "getCollectionTotals"
        let parameters = userParameters()

        let request = Alamofire.request( url, parameters: parameters)
        let requestCompletion: (DataResponse<XMLDocument>) -> Void = { response in
            if let error = response.result.error {
                completion(Result.failure(error))
            }
            else if let document = response.result.value, let root = document.root {
                if let collectionTotals = UserCollectionTotals(element: root) {
                    completion(Result.success(collectionTotals))
                }
            }
        }
        request.responseXMLDocument(completionHandler: requestCompletion)
    }

    func setCollectionOwns(setID: String, owned: Bool, completion: @escaping (Result<Bool>) -> Void) {
        let url = baseURL + "setCollection_owns"

        var parameters = userParameters()
        parameters["setID"] = setID
        parameters["owned"] = owned

        let request = Alamofire.request( url, method: .post, parameters: parameters)
        let requestCompletion: (DataResponse<XMLDocument>) -> Void = { response in
            if let error = response.result.error {
                completion(Result.failure(error))
            }
            else if let document = response.result.value, let result = document.root?.stringValue {
                if result.contains("OK") {
                    completion(Result.success(true))
                }
                else {
                    completion(Result.failure(ServiceError.unknownError))
                }
            }
        }
        request.responseXMLDocument(completionHandler: requestCompletion)
    }
    
    func setCollectionWants(setID: String, wanted: Bool, completion: @escaping (Result<Bool>) -> Void) {
        let url = baseURL + "setCollection_wants"
        
        var parameters = userParameters()
        parameters["setID"] = setID
        parameters["wanted"] = wanted
        
        let request = Alamofire.request( url, method: .post, parameters: parameters)
        let requestCompletion: (DataResponse<XMLDocument>) -> Void = { response in
            if let error = response.result.error {
                completion(Result.failure(error))
            }
            else if let document = response.result.value, let result = document.root?.stringValue {
                if result.contains("OK") {
                    completion(Result.success(true))
                }
                else {
                    completion(Result.failure(ServiceError.unknownError))
                }
            }
        }
        request.responseXMLDocument(completionHandler: requestCompletion)
    }
    
    func setCollectionQuantityOwned(setID: String, quantityOwned: Int, completion: @escaping (Result<Bool>) -> Void) {
        let url = baseURL + "setCollection_qtyOwned"
        
        var parameters = userParameters()
        parameters["setID"] = setID
        parameters["qtyOwned"] = quantityOwned
        
        let request = Alamofire.request( url, method: .post, parameters: parameters)
        let requestCompletion: (DataResponse<XMLDocument>) -> Void = { response in
            if let error = response.result.error {
                completion(Result.failure(error))
            }
            else if let document = response.result.value, let result = document.root?.stringValue {
                if result.contains("OK") {
                    completion(Result.success(true))
                }
                else {
                    completion(Result.failure(ServiceError.unknownError))
                }
            }
        }
        request.responseXMLDocument(completionHandler: requestCompletion)
    }
    
    func setUserRating(setID: String, rating: Int, completion: @escaping (Result<Bool>) -> Void) {
        let url = baseURL + "setUserRating"
        
        var parameters = userParameters()
        parameters["setID"] = setID
        parameters["rating"] = rating
        
        let request = Alamofire.request( url, method: .post, parameters: parameters)
        let requestCompletion: (DataResponse<XMLDocument>) -> Void = { response in
            if let error = response.result.error {
                completion(Result.failure(error))
            }
            else if let document = response.result.value, let result = document.root?.stringValue {
                if result.contains("OK") {
                    completion(Result.success(true))
                }
                else {
                    completion(Result.failure(ServiceError.unknownError))
                }
            }
        }
        request.responseXMLDocument(completionHandler: requestCompletion)
    }
    
    func setCollectionUserNotes(setID: String, notes: String, completion: @escaping (Result<Bool>) -> Void) {
        let url = baseURL + "setCollection_userNotes"
        
        var parameters = userParameters()
        parameters["setID"] = setID
        parameters["notes"] = notes
        
        let request = Alamofire.request( url, method: .post, parameters: parameters)
        let requestCompletion: (DataResponse<XMLDocument>) -> Void = { response in
            if let error = response.result.error {
                completion(Result.failure(error))
            }
            else if let document = response.result.value, let result = document.root?.stringValue {
                if result.contains("OK") {
                    completion(Result.success(true))
                }
                else {
                    completion(Result.failure(ServiceError.unknownError))
                }
            }
        }
        request.responseXMLDocument(completionHandler: requestCompletion)
    }
    
    //--------------------------------------------------------------------------
    // MARK: - RSS Feeds
    //--------------------------------------------------------------------------

    func getNews(completion: @escaping (Result<RSSFeed>) -> Void) {
        let url = "https://brickset.com/feed"
        Alamofire.request(url).responseRSS({ (response) -> Void in
            if let feed: RSSFeed = response.result.value {
                completion(Result.success(feed))
            }
            else {
                completion(Result.failure(ServiceError.unknownError))
            }
        })
    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    fileprivate func defaultParameters() -> Parameters {
        return ["apiKey": Constants.Brickset.apiKey]
    }
    
    fileprivate func userParameters() -> Parameters {
        var parameters = defaultParameters()

        let keychain = Keychain(service: keychainServiceName)
        if let username = UserDefaults.standard.value(forKey: userNameKey) as? String, let userHash = keychain[username] {
            parameters["userHash"] = userHash
        }
        else {
            parameters["userHash"] = ""
        }

        return parameters
    }

}

//==============================================================================
// MARK: - DataRequest Extension (XML Parsing)
//==============================================================================

extension DataRequest {

    // swiftlint:disable unused_closure_parameter

    public static func XMLResponseSerializer() -> DataResponseSerializer<XMLDocument> {
        return DataResponseSerializer { request, response, data, error in
            // Pass through any underlying URLSession error to the .network case.
            guard error == nil else { return .failure(error!) }

            // Use Alamofire's existing data serializer to extract the data, passing the error as nil, as it has
            // already been handled.
            let result = Request.serializeResponseData(response: response, data: data, error: nil)

            guard case let .success(validData) = result else {
                return .failure(result.error!)
            }

            do {
                let xml = try XMLDocument(data: validData)
                return .success(xml)
            }
            catch {
                return .failure(error)
            }
        }
    }

    // swiftlint:enable unused_closure_parameter

    @discardableResult func responseXMLDocument( queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<XMLDocument>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: DataRequest.XMLResponseSerializer(), completionHandler: completionHandler)
    }

}
