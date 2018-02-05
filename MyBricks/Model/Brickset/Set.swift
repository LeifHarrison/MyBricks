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
    var released: Bool?
    var owned: Bool?
    var wanted: Bool?
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
        if let boolString = element.firstChild(tag: "released")?.stringValue {
            released = Bool(boolString)
        }
        if let boolString = element.firstChild(tag: "owned")?.stringValue {
            owned = Bool(boolString)
        }
        if let boolString = element.firstChild(tag: "wanted")?.stringValue {
            wanted = Bool(boolString)
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
            retailPrices.append(SetRetailPrice(locale: Locale(identifier: "en_US"), price: retailPriceUS))
        }
        if let retailPriceCA = element.firstChild(tag: "CARetailPrice")?.stringValue {
            retailPrices.append(SetRetailPrice(locale: Locale(identifier: "en_CA"), price: retailPriceCA))
        }
        if let retailPriceUK = element.firstChild(tag: "UKRetailPrice")?.stringValue {
            retailPrices.append(SetRetailPrice(locale: Locale(identifier: "en_GB"), price: retailPriceUK))
        }
        if let retailPriceEU = element.firstChild(tag: "EURetailPrice")?.stringValue {
            retailPrices.append(SetRetailPrice(locale: Locale(identifier: "en_EU"), price: retailPriceEU))
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
        if let variant = numberVariant {
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

        if let price = preferredPrice {
            let flag = price.locale.emojiFlag ?? "🇺🇸"
            let currencySymbol = price.locale.currencySymbol ?? "$"
            return (flag + " " + currencySymbol + price.price)
        }
        return nil
    }

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    func isRetired() -> Bool {
        return (dateAddedToSAH == nil) || (dateRemovedFromSAH != nil)
    }

    func themeDetail() -> String? {
        if let theme = theme, let subtheme = subtheme {
            return "\(theme) / \(subtheme)"
        }
        else if let theme = theme {
            return theme
        }
        else {
            return ""
        }
    }
    
    func availabilityDetail() -> String? {
        if let availability = availability, let packagingType = packagingType {
            return "\(availability.capitalized) / \(packagingType.capitalized)"
        }
        else if let availability = availability {
            return availability.capitalized
        }
        else {
            return packagingType?.capitalized ?? ""
        }
    }

}

