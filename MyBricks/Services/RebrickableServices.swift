//
//  RebrickableServices.swift
//  MyBricks
//
//  Created by Leif Harrison on 12/8/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import Foundation

import Alamofire

class RebrickableServices {
    
    static let shared = RebrickableServices()
    
    let baseURL = "https://rebrickable.com/api/v3/"

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
    
    // Get Parts
    // URL: https://rebrickable.com/api/v3/lego/sets/<set number>/parts/
    @discardableResult
    func getParts(setNumber: String, pageURL: String? = nil, completion: @escaping (Result<GetPartsResponse>) -> Void) -> DataRequest {
        let url = pageURL ?? baseURL + "lego/sets/" + setNumber + "/parts/"
        
        let headers: HTTPHeaders = [
            "Authorization": "key \(Constants.Rebrickable.apiKey)",
            "Accept": "application/json"
        ]

        let request = Alamofire.request( url, method: .get, headers: headers )
        let requestCompletion: ((DataResponse<Data>) -> Void) = { response in
            switch response.result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    do {
                        let decodedResponse = try decoder.decode(GetPartsResponse.self, from: data)
                        completion(.success(decodedResponse))
                    }
                    catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    NSLog("Error: \(error)")
                    completion(.failure(error))
            }
        }
        request.responseData(completionHandler: requestCompletion)
        return request
    }

}
