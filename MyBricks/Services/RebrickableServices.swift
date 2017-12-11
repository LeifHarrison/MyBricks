//
//  RebrickableServices.swift
//  MyBricks
//
//  Created by Leif on 12/8/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import Foundation

import Alamofire

class RebrickableServices {
    
    static let shared = RebrickableServices()
    
    let apiKey = "7ee6c70b29646296c7d4778cabb4d476"
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
    func getParts(setNumber: String, completion: @escaping (Result<GetPartsResponse>) -> Void) -> DataRequest {
        let url = baseURL + "lego/sets/" + setNumber + "/parts/"
        
        let headers: HTTPHeaders = [
            "Authorization": "key \(apiKey)",
            "Accept": "application/json"
        ]

        let request = Alamofire.request( url, method: .get, headers: headers )
        print("Request: \(request)")
        
        let requestCompletion: ((DataResponse<Data>) -> Void) = { response in
            switch response.result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    do {
                        let decodedResponse = try decoder.decode(GetPartsResponse.self, from: data)
                        completion(.success(decodedResponse))
                    }
                    catch {
                        print("Error trying to convert data to JSON: ")
                        print(error)
                        completion(.failure(error))
                    }
                case .failure(let error):
                    print("Error: \(error)")
                    completion(.failure(error))
            }

//            if let data = response.result.value {
//                if let jsonDict = json as? [ String: AnyObject ] {
//                    if let results = jsonDict["results"] as? [[String: AnyObject]] {
//                        for resultElement in results {
//                            print("result element = \(resultElement)")
//                        }
//                    }
//                }
//            }
//            else {
//                let error = (response.result.value  as? [[String : AnyObject]])
//                print(error as Any)
//            }
        }
        request.responseData(completionHandler: requestCompletion)
        return request
    }

}
