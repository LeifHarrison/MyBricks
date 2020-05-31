//
//  SetDetail.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/10/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import Foundation

// swiftlint:disable cyclomatic_complexity

struct SetDetail: Codable {

    var setID: Int? // Unique Brickset database primary key
    var number: String?
    var numberVariant: Int?
    var name: String?
    var year: Int?
    var theme: String?
    var themeGroup: String?
    var subtheme: String?
    var category: String?
    var released: Bool?
    var pieces: Int?
    var minifigs: Int?
    var bricksetURL: String?
    var rating: Decimal?
    var reviewCount: Int?
    var packagingType: String?
    var availability: String?
    var instructionsCount: Int?
    var additionalImageCount: Int?
    var lastUpdated: String?

    var image: SetImage?
    var collection: SetUserCollection?
    var ageRange: SetAgeRange?
    var dimensions: SetDimensions?
    var extendedData: SetExtendedData?

    //var images: [SetImage] = []
    //var retailPrices: [SetRetailPrice] = []

    // Move to SetBarcode
    var EAN: String?
    var UPC: String?

    // Move to LEGOCom
    var dateAddedToSAH: Date? // The date the set was first sold as shop.LEGO.com in the USA
    var dateRemovedFromSAH: Date? // The date the set was last sold as shop.LEGO.com in the USA. If USDateAddedToSAH is not blank but this is, it's still available.

    // Move to SetCollections
    var ownedByTotal: Int?
    var wantedByTotal: Int?

    //--------------------------------------------------------------------------
    // MARK: - Computed Properties
    //--------------------------------------------------------------------------
    
    var isOwned: Bool {
        return collection?.owned ?? false
    }

    var isWanted: Bool {
        return collection?.wanted ?? false
    }

    var fullSetNumber: String {
        if let variant = numberVariant {
            return (number ?? "") + "-" + "\(variant)"
        }
        else {
            return number ?? ""
        }
    }

    var displayableSetNumber: String {
        if let variant = numberVariant, variant > 1 {
            return (number ?? "") + "-" + "\(variant)"
        }
        else {
            return number ?? ""
        }
    }
    
    var setNumberAgeYearDescription: String? {
        var descriptionString = fullSetNumber
        if let ageDescription = ageRangeDescription, ageDescription.count > 0 {
            descriptionString.append(" | ")
            descriptionString.append(ageDescription)
        }
        if let year = year {
            descriptionString.append(" | ")
            descriptionString.append("\(year)")
        }
        return descriptionString
    }

    var ageRangeDescription: String? {
        if let ageMin = ageRange?.min, let ageMax = ageRange?.max {
            return "\(ageMin)-\(ageMax)"
        }
        else if let ageMin = ageRange?.min {
            return "\(ageMin)+"
        }
        else {
            return ""
        }
    }
    
    var preferredPriceDescription: String? {
//        var preferredPrice = retailPrices.first
//        for price in retailPrices where Locale.current.currencyCode == price.locale.currencyCode {
//            preferredPrice = price
//        }
//
//        return preferredPrice?.priceDescription()
        return nil
    }

    var largeImageURL: String? {
        if let imageURL = self.image?.imageURL {
            return imageURL.replacingOccurrences(of: "/images/", with: "/large/")
        }
        return nil
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------

    func isRetired() -> Bool {
        return (dateAddedToSAH == nil) || (dateRemovedFromSAH != nil)
    }

    func themeDescription() -> String? {
        if let theme = theme, let subtheme = subtheme, theme.count > 0 && subtheme.count > 0 {
            return "\(theme) | \(subtheme)"
        }
        else if let theme = theme {
            return theme
        }
        else {
            return ""
        }
    }
    
    func categoryAndGroupDescription() -> String? {
        if let category = category, let themeGroup = themeGroup {
            return "\(category) | \(themeGroup.capitalized)"
        }
        else if let category = category {
            return category
        }
        else if let themeGroup = themeGroup {
            return themeGroup.capitalized
        }
        else {
            return ""
        }
    }
    
    func availabilityDescription() -> String? {
        var result = ""
        if let availability = availability {
            result.append(availability.capitalized)
        }
        if let packagingType = packagingType {
            if result.count > 0 {
                result.append(" | ")
            }
            result.append(packagingType.capitalized)
        }
        if let dimensions = dimensionsDescription() {
            result.append(" (\(dimensions)")
            if let weightDescription = weightDescription() {
                result.append(" | \(weightDescription))")
            }
            else {
                result.append(")")
            }

        }
        else if let weightDescription = weightDescription() {
            result.append(" (\(weightDescription))")
        }
        return result
    }

    func dimensionsDescription() -> String? {
        if let height = self.dimensions?.height, let width = self.dimensions?.width, let depth = self.dimensions?.depth {
            let widthMeasurement = Measurement(value: (width as NSDecimalNumber).doubleValue, unit: UnitLength.centimeters)
            let heightMeasurement = Measurement(value: (height as NSDecimalNumber).doubleValue, unit: UnitLength.centimeters)
            let depthMeasurement = Measurement(value: (depth as NSDecimalNumber).doubleValue, unit: UnitLength.centimeters)
            let formatter = MeasurementFormatter()
            formatter.unitStyle = .short
            formatter.unitOptions = .naturalScale
            let numberFormatter = NumberFormatter()
            numberFormatter.maximumFractionDigits = 1
            formatter.numberFormatter = numberFormatter
            return "\(formatter.string(from: widthMeasurement)) x \(formatter.string(from: heightMeasurement)) x \(formatter.string(from: depthMeasurement))"
        }
        return nil
    }
    
    func weightDescription() -> String? {
        if let weight = self.dimensions?.weight {
            let weightMeasurement = Measurement(value: (weight as NSDecimalNumber).doubleValue, unit: UnitMass.kilograms)
            let formatter = MeasurementFormatter()
            formatter.unitOptions = .naturalScale
            let numberFormatter = NumberFormatter()
            numberFormatter.maximumFractionDigits = 1
            formatter.numberFormatter = numberFormatter
            return formatter.string(from: weightMeasurement)
        }
        return nil
    }
    
    func lastUpdatedDate() -> Date? {
        if let lastUpdated = self.lastUpdated {
            let formatter = Formatters.bricksetDateFormatter
            return formatter.date(from: lastUpdated)
        }
        return nil
    }
}

struct SetAgeRange: Codable {
    var min: Int?
    var max: Int?
}

struct SetDimensions: Codable {
    var height: Decimal?
    var width: Decimal?
    var depth: Decimal?
    var weight: Decimal?
}

struct SetExtendedData: Codable {
    var setDescription: String?
    var notes: String?
    var tags: [String]?

    enum CodingKeys: String, CodingKey {
        case setDescription = "description"
        case notes
        case tags
    }
}

struct SetImage: Codable, Equatable {
    var thumbnailURL: String?
    var imageURL: String?
}

class SetUserCollection: Codable {
    // Use a class instead of a struct so it can be passed by reference
    var owned: Bool?
    var wanted: Bool?
    var qtyOwned: Int?
    var rating: Int?
    var notes: String?
}
