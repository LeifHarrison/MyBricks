//
//  AuthenticatedServiceAPI.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 6/25/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import Foundation

import Alamofire

protocol AuthenticatedServiceAPI: class {
    
    var isLoggedIn: Bool { get }
    var userName: String? { get }
    var loginProtectionSpace: URLProtectionSpace? { get }
    var logoImage: UIImage? { get }
    
    func login(username: String, password: String, completion: @escaping (Result<String, ServiceError>) -> Void)
    func logout(_ completion: @escaping () -> Void)

}
