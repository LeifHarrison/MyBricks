//
//  DownloadedInstructions+CoreDataProperties.swift
//  MyBricks
//
//  Created by Leif Harrison on 6/26/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import Foundation
import CoreData

extension DownloadedInstructions {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DownloadedInstructions> {
        return NSFetchRequest<DownloadedInstructions>(entityName: "DownloadedInstructions")
    }

    @NSManaged public var creationDate: Date
    @NSManaged public var fileDescription: String?
    @NSManaged public var fileName: String
    @NSManaged public var fileSize: Int64
    @NSManaged public var setName: String?
    @NSManaged public var setNumber: String?

    var fileURL: URL? {
        let directoryURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if !directoryURLs.isEmpty {
            return directoryURLs[0].appendingPathComponent(fileName)
        }

        return nil
    }
    
}
