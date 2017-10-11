//
//  BricksetServices.swift
//  MyBricks
//
//  Created by Leif Harrison on 7/14/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import Foundation

import Alamofire
import Fuzi

class BricksetServices {
    static let sharedInstance = BricksetServices()

    let baseURL = "https://brickset.com/api/v2.asmx/"
    let apiKey = "PJ6U-J8Ob-GG1k"

    func login(username: String, password: String, completion: @escaping ([String]) -> Void) {
        let url = baseURL + "login"
        var parameters = defaultParameters()
        parameters["username"] = username
        parameters["password"] = password

        let request = Alamofire.request( url, parameters: parameters)

        let requestCompletion: (DataResponse<XMLDocument>) -> Void = { response in
            if let error = response.result.error {
                print("Error: \(error)")
            }
            else if let document = response.result.value, let userHash = document.root?.stringValue {
                print("userHash: \(userHash)")
                completion([""])
            }
        }

        request.responseXMLDocument(completionHandler: requestCompletion)
    }

    func getNews(completion: @escaping ([Theme]) -> Void) {
        let url = "https://brickset.com/feed"

        let requestCompletion: (DataResponse<XMLDocument>) -> Void = { response in
            if let error = response.result.error {
                print("Error: \(error)")
            }
            else if let document = response.result.value {
                print("Document: \(document)")
//                if let root = document.root {
//                    var themes: [Theme] = []
//
//                    for element in root.children {
//                        if let theme = Theme(element: element) {
//                            themes.append(theme)
//                        }
//                    }
//
//                    completion(themes)
//                }
                completion([])
            }
        }

        let parameters = defaultParameters()
        let request = Alamofire.request( url, parameters: parameters)
        request.responseXMLDocument(completionHandler: requestCompletion)
    }

    func getThemes(completion: @escaping ([Theme]) -> Void) {
        let url = baseURL + "getThemes"

        let parameters = defaultParameters()
        let request = Alamofire.request( url, parameters: parameters)
        print("Request: \(request)")

        let requestCompletion: (DataResponse<XMLDocument>) -> Void = { response in
            //print("Document: \(document)")
            if let error = response.result.error {
                print("Error: \(error)")
            }
            else if let document = response.result.value {
                if let root = document.root {
                    var themes: [Theme] = []

                    for element in root.children {
                        if let theme = Theme(element: element) {
                            themes.append(theme)
                        }
                    }

                    completion(themes)
                }
            }
        }
        request.responseXMLDocument(completionHandler: requestCompletion)
    }

    func getSets(theme: String, completion: @escaping ([Set]) -> Void) {
        let url = baseURL + "getSets"

        var parameters = defaultParameters()
        parameters["query"] = ""
        parameters["theme"] = theme
        parameters["subtheme"] = ""
        parameters["setNumber"] = ""
        parameters["year"] = ""
        parameters["owned"] = ""
        parameters["wanted"] = ""
        parameters["orderBy"] = "Number"
        parameters["pageSize"] = "50"
        parameters["pageNumber"] = ""
        parameters["userName"] = ""

        let request = Alamofire.request( url, parameters: parameters)
        print("Request: \(request)")

        let requestCompletion: (DataResponse<XMLDocument>) -> Void = { response in
            //print("Document: \(document)")
            if let error = response.result.error {
                print("Error: \(error)")
            }
            else if let document = response.result.value {
                if let root = document.root {
                    var sets: [Set] = []

                    for element in root.children {
                        if let set = Set(element: element) {
                            sets.append(set)
                        }
                    }

                    completion(sets)
                }
            }
        }
        request.responseXMLDocument(completionHandler: requestCompletion)
    }

    fileprivate func defaultParameters() -> Parameters {
        return ["apiKey": apiKey, "userHash": ""]
    }


}

enum BackendError: Error {
    case network(error: Error) // Capture any underlying Error from the URLSession API
    case dataSerialization(error: Error)
    case jsonSerialization(error: Error)
    case xmlSerialization(error: Error)
    case objectSerialization(reason: String)
}

extension DataRequest {

    public static func XMLResponseSerializer() -> DataResponseSerializer<XMLDocument> {
        return DataResponseSerializer { request, response, data, error in
            // Pass through any underlying URLSession error to the .network case.
            guard error == nil else { return .failure(BackendError.network(error: error!)) }

            // Use Alamofire's existing data serializer to extract the data, passing the error as nil, as it has
            // already been handled.
            let result = Request.serializeResponseData(response: response, data: data, error: nil)

            guard case let .success(validData) = result else {
                return .failure(BackendError.dataSerialization(error: result.error! as! AFError))
            }

            do {
                let xml = try XMLDocument(data: validData)
                return .success(xml)
            } catch {
                return .failure(BackendError.xmlSerialization(error: error))
            }
        }
    }

    @discardableResult func responseXMLDocument( queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<XMLDocument>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: DataRequest.XMLResponseSerializer(), completionHandler: completionHandler)
    }

}
