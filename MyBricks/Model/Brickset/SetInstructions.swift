//
//  SetInstructions.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/25/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import Foundation

public struct SetInstructions: Codable {
    
    var fileDescription: String?
    var fileURL: String?
    
    var destinationURL: URL? {
        if let urlString = self.fileURL, let sourceURL = URL(string: urlString) {
            let directoryURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            if !directoryURLs.isEmpty {
                return directoryURLs[0].appendingPathComponent(sourceURL.lastPathComponent)
            }
        }
        
        return nil
    }

    enum CodingKeys: String, CodingKey {
        case fileDescription = "description"
        case fileURL = "URL"
    }

}
