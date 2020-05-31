//
//  SetDetail.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/10/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import Foundation
import Fuzi

// swiftlint:disable cyclomatic_complexity

struct SetDetail: Codable {

    var setID: String? // Unique Brickset database primary key
    var number: String?
    var numberVariant: String?
    var name: String?
    var year: String?
    var theme: String?
    var themeGroup: String?
    var subtheme: String?
    var category: String?
    var released: Bool = true
    var pieces: Int?
    var minifigs: Int?
    var bricksetURL: String?
    var rating: Decimal?
    var reviewCount: Int?
    var packagingType: String?
    var availability: String?
    var instructionsCount: Int?
    var additionalImageCount: Int?
    var lastUpdated: Date?



    //var images: [SetImage] = []
    var retailPrices: [SetRetailPrice] = []

    // Move to SetAgeRange
    var ageMin: Int?
    var ageMax: Int?

    // Move to SetDimensions
    var height: Decimal? // Packaging height, in cm
    var width: Decimal? // Packaging width, in cm
    var depth: Decimal? // Packaging depth, in cm
    var weight: Decimal? // Weight, in Kg

    // Move to SetBarcode
    var EAN: String?
    var UPC: String?

    // Move to SetCollection
    var owned: Bool = false
    var wanted: Bool = false
    var quantityOwned: Int?
    var userNotes: String?
    var userRating: Int?
    
    // Move to LEGOCom
    var dateAddedToSAH: Date? // The date the set was first sold as shop.LEGO.com in the USA
    var dateRemovedFromSAH: Date? // The date the set was last sold as shop.LEGO.com in the USA. If USDateAddedToSAH is not blank but this is, it's still available.

    // Move to SetCollections
    var ownedByTotal: Int?
    var wantedByTotal: Int?

    // Deprecated
    var thumbnailURL: String? // Max dimensions 96x72
    var largeThumbnailURL: String? // Max dimensions 240x180
    var imageURL: String? // Max dimensions 690x690

    //--------------------------------------------------------------------------
    // MARK: - Computed Properties
    //--------------------------------------------------------------------------

    var fullSetNumber: String {
        if let variant = numberVariant {
            return (number ?? "") + "-" + variant
        }
        else {
            return number ?? ""
        }
    }

    var displayableSetNumber: String {
        if let variant = numberVariant, let variantNumber = Int(variant), variantNumber > 1 {
            return (number ?? "") + "-" + variant
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
        if let yearDescription = year, yearDescription.count > 0 {
            descriptionString.append(" | ")
            descriptionString.append(yearDescription)
        }
        return descriptionString
    }

    var ageRangeDescription: String? {
        if let ageMin = ageMin, let ageMax = ageMax {
            return "\(ageMin)-\(ageMax)"
        }
        else if let ageMin = ageMin {
            return "\(ageMin)+"
        }
        else {
            return ""
        }
    }
    
    var preferredPriceDescription: String? {
        var preferredPrice = retailPrices.first
        for price in retailPrices where Locale.current.currencyCode == price.locale.currencyCode {
            preferredPrice = price
        }

        return preferredPrice?.priceDescription()
    }

    var largeImageURL: String? {
        if let imageURL = self.imageURL {
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
        if let height = self.height, let width = self.width, let depth = self.depth {
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
        if let weight = self.weight {
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
}
