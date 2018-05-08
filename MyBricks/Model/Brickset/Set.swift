//
//  Set.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/10/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import Foundation
import Fuzi

struct Set {

    var setID: String? // Unique Brickset database primary key
    var number: String?
    var numberVariant: String?
    var name: String?
    var year: String?
    var theme: String?
    var themeGroup: String?
    var subtheme: String?
    var pieces: Int?
    var minifigs: Int?
    var thumbnailURL: String? // Max dimensions 96x72
    var largeThumbnailURL: String? // Max dimensions 240x180
    var imageURL: String? // Max dimensions 690x690
    var bricksetURL: String?
    var released: Bool = true
    var owned: Bool = false
    var wanted: Bool = false
    var quantityOwned: Int?
    var userNotes: String?
    var ownedByTotal: Int?
    var wantedByTotal: Int?
    var dateAddedToSAH: Date? // The date the set was first sold as shop.LEGO.com in the USA
    var dateRemovedFromSAH: Date? // The date the set was last sold as shop.LEGO.com in the USA. If USDateAddedToSAH is not blank but this is, it's still available.
    var rating: Decimal?
    var reviewCount: Int?
    var packagingType: String?
    var availability: String?
    var instructionsCount: Int?
    var additionalImageCount: Int?
    var EAN: String?
    var UPC: String?
    var lastUpdated: Date?
    var ageMin: Int?
    var ageMax: Int?
    var height: Decimal? // Packaging height, in cm
    var width: Decimal? // Packaging width, in cm
    var depth: Decimal? // Packaging depth, in cm
    var weight: Decimal? // Weight, in Kg
    var category: String?
    var userRating: Int?

    var retailPrices: [SetRetailPrice] = []

    init?(element: XMLElement) {
        setID = element.firstChild(tag: "setID")?.stringValue
        number = element.firstChild(tag: "number")?.stringValue
        numberVariant = element.firstChild(tag: "numberVariant")?.stringValue
        name = element.firstChild(tag: "name")?.stringValue
        year = element.firstChild(tag: "year")?.stringValue
        theme = element.firstChild(tag: "theme")?.stringValue
        themeGroup = element.firstChild(tag: "themeGroup")?.stringValue
        subtheme = element.firstChild(tag: "subtheme")?.stringValue
        if let intString = element.firstChild(tag: "pieces")?.stringValue {
            pieces = Int(intString)
        }
        if let intString = element.firstChild(tag: "minifigs")?.stringValue {
            minifigs = Int(intString)
        }
        thumbnailURL = element.firstChild(tag: "thumbnailURL")?.stringValue
        largeThumbnailURL = element.firstChild(tag: "largeThumbnailURL")?.stringValue
        imageURL = element.firstChild(tag: "imageURL")?.stringValue
        bricksetURL = element.firstChild(tag: "bricksetURL")?.stringValue
        if let boolString = element.firstChild(tag: "released")?.stringValue, let boolValue = Bool(boolString) {
            released = boolValue
        }
        if let boolString = element.firstChild(tag: "owned")?.stringValue, let boolValue = Bool(boolString) {
            owned = boolValue
        }
        if let boolString = element.firstChild(tag: "wanted")?.stringValue, let boolValue = Bool(boolString) {
            wanted = boolValue
        }
        if let intString = element.firstChild(tag: "qtyOwned")?.stringValue {
            quantityOwned = Int(intString)
        }
        userNotes = element.firstChild(tag: "userNotes")?.stringValue
        if let intString = element.firstChild(tag: "ownedByTotal")?.stringValue {
            ownedByTotal = Int(intString)
        }
        if let intString = element.firstChild(tag: "wantedByTotal")?.stringValue {
            wantedByTotal = Int(intString)
        }
        if let dateString = element.firstChild(tag: "USDateAddedToSAH")?.stringValue {
            dateAddedToSAH = BricksetServices.shortDateFormatter.date(from: dateString)
        }
        if let dateString = element.firstChild(tag: "USDateRemovedFromSAH")?.stringValue {
            dateRemovedFromSAH = BricksetServices.shortDateFormatter.date(from: dateString)
        }
        if let decimalString = element.firstChild(tag: "rating")?.stringValue {
            rating = Decimal(string: decimalString)
        }
        if let intString = element.firstChild(tag: "reviewCount")?.stringValue {
            reviewCount = Int(intString)
        }
        packagingType = element.firstChild(tag: "packagingType")?.stringValue
        availability = element.firstChild(tag: "availability")?.stringValue
        if let intString = element.firstChild(tag: "instructionsCount")?.stringValue {
            instructionsCount = Int(intString)
        }
        if let intString = element.firstChild(tag: "additionalImageCount")?.stringValue {
            additionalImageCount = Int(intString)
        }
        EAN = element.firstChild(tag: "EAN")?.stringValue
        UPC = element.firstChild(tag: "UPC")?.stringValue
        if let retailPriceUS = element.firstChild(tag: "USRetailPrice")?.stringValue {
            let pricePerPiece = (Double(retailPriceUS) ?? 0) / Double(pieces ?? 1) * 100
            let pricePerPieceString = String(format:"%0.1f", pricePerPiece) + "¢"
            retailPrices.append(SetRetailPrice(locale: Locale(identifier: "en_US"), price: retailPriceUS, pricePerPiece: pricePerPieceString))
        }
        if let retailPriceCA = element.firstChild(tag: "CARetailPrice")?.stringValue {
            let pricePerPiece = (Double(retailPriceCA) ?? 0) / Double(pieces ?? 1) * 100
            let pricePerPieceString = String(format:"%0.1f", pricePerPiece) + "¢"
            retailPrices.append(SetRetailPrice(locale: Locale(identifier: "en_CA"), price: retailPriceCA, pricePerPiece: pricePerPieceString))
        }
        if let retailPriceUK = element.firstChild(tag: "UKRetailPrice")?.stringValue {
            let pricePerPiece = (Double(retailPriceUK) ?? 0) / Double(pieces ?? 1) * 100
            let pricePerPieceString = String(format:"%0.1f", pricePerPiece) + "p"
            retailPrices.append(SetRetailPrice(locale: Locale(identifier: "en_GB"), price: retailPriceUK, pricePerPiece: pricePerPieceString))
        }
        if let retailPriceEU = element.firstChild(tag: "EURetailPrice")?.stringValue {
            let pricePerPiece = (Double(retailPriceEU) ?? 0) / Double(pieces ?? 1) * 100
            let pricePerPieceString = String(format:"%0.1f", pricePerPiece) + "¢"
            retailPrices.append(SetRetailPrice(locale: Locale(identifier: "en_EU"), price: retailPriceEU, pricePerPiece: pricePerPieceString))
        }
        if let dateString = element.firstChild(tag: "lastUpdated")?.stringValue {
            lastUpdated = BricksetServices.longDateFormatter.date(from: dateString)
        }
        if let intString = element.firstChild(tag: "ageMin")?.stringValue {
            ageMin = Int(intString)
        }
        if let intString = element.firstChild(tag: "ageMax")?.stringValue {
            ageMax = Int(intString)
        }
        if let decimalString = element.firstChild(tag: "height")?.stringValue {
            height = Decimal(string: decimalString)
        }
        if let decimalString = element.firstChild(tag: "width")?.stringValue {
            width = Decimal(string: decimalString)
        }
        if let decimalString = element.firstChild(tag: "depth")?.stringValue {
            depth = Decimal(string: decimalString)
        }
        if let decimalString = element.firstChild(tag: "weight")?.stringValue {
            weight = Decimal(string: decimalString)
        }
        category = element.firstChild(tag: "category")?.stringValue
        if let intString = element.firstChild(tag: "userRating")?.stringValue {
            userRating = Int(intString)
        }
     }

    //--------------------------------------------------------------------------
    // MARK: - Computed Properties
    //--------------------------------------------------------------------------

    var fullSetNumber: String {
        if let variant = numberVariant, let variantNumber = Int(variant), variantNumber > 1  {
            return (number ?? "") + "-" + variant
        }
        else {
            return number ?? ""
        }
    }

    var ageRangeString: String? {
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
    
    var preferredPriceString: String? {
        var preferredPrice = retailPrices.first
        for price in retailPrices {
            if Locale.current.currencyCode == price.locale.currencyCode {
                preferredPrice = price
            }
        }

        return preferredPrice?.priceDescription()
    }

    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------

    func isRetired() -> Bool {
        return (dateAddedToSAH == nil) || (dateRemovedFromSAH != nil)
    }

    func themeDescription() -> String? {
        if let theme = theme, let subtheme = subtheme, theme.count > 0 && subtheme.count > 0 {
            return "\(theme) / \(subtheme)"
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
            return "\(category) / \(themeGroup.capitalized)"
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
                result.append(" / ")
            }
            result.append(packagingType.capitalized)
        }
        if let dimensions = dimensionsDescription() {
            result.append(" (\(dimensions)")
            if let weightDescription = weightDescription() {
                result.append(" / \(weightDescription))")
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

