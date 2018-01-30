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

    var setID: String?
    var number: String?
    var numberVariant: String?
    var name: String?
    var year: String?
    var theme: String?
    var themeGroup: String?
    var subtheme: String?
    var pieces: Int?
    var minifigs: Int?
    var thumbnailURL: String?
    var largeThumbnailURL: String?
    var imageURL: String?
    var bricksetURL: String?
    var released: Bool?
    var owned: Bool?
    var wanted: Bool?
    var quantityOwned: Int?
    var userNotes: String?
    var ownedByTotal: Int?
    var wantedByTotal: Int?
    var dateAddedToSAH: Date?
    var dateRemovedFromSAH: Date?
    var rating: Double?
    var reviewCount: Int?
    var packagingType: String?
    var availability: String?
    var instructionsCount: Int?
    var additionalImageCount: Int?
    var EAN: String?
    var UPC: String?
    var lastUpdated: Date?

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
        pieces = Int(element.firstChild(tag: "pieces")?.stringValue ?? "0")
        minifigs = Int(element.firstChild(tag: "minifigs")?.stringValue ?? "0")
        thumbnailURL = element.firstChild(tag: "thumbnailURL")?.stringValue
        largeThumbnailURL = element.firstChild(tag: "largeThumbnailURL")?.stringValue
        imageURL = element.firstChild(tag: "imageURL")?.stringValue
        bricksetURL = element.firstChild(tag: "bricksetURL")?.stringValue
        released = Bool(element.firstChild(tag: "released")?.stringValue ?? "false")
        owned = Bool(element.firstChild(tag: "owned")?.stringValue ?? "false")
        wanted = Bool(element.firstChild(tag: "wanted")?.stringValue ?? "false")
        quantityOwned = Int(element.firstChild(tag: "qtyOwned")?.stringValue ?? "0")
        userNotes = element.firstChild(tag: "userNotes")?.stringValue
        ownedByTotal = Int(element.firstChild(tag: "ownedByTotal")?.stringValue ?? "0")
        wantedByTotal = Int(element.firstChild(tag: "wantedByTotal")?.stringValue ?? "0")
        if let dateAdded = element.firstChild(tag: "USDateAddedToSAH")?.stringValue {
            dateAddedToSAH = BricksetServices.shortDateFormatter.date(from: dateAdded)
        }
        if let dateRemoved = element.firstChild(tag: "USDateRemovedFromSAH")?.stringValue {
            dateRemovedFromSAH = BricksetServices.shortDateFormatter.date(from: dateRemoved)
        }
        rating = Double(element.firstChild(tag: "rating")?.stringValue ?? "0")
        reviewCount = Int(element.firstChild(tag: "reviewCount")?.stringValue ?? "0")
        packagingType = element.firstChild(tag: "packagingType")?.stringValue
        availability = element.firstChild(tag: "availability")?.stringValue
        instructionsCount = Int(element.firstChild(tag: "instructionsCount")?.stringValue ?? "0")
        additionalImageCount = Int(element.firstChild(tag: "additionalImageCount")?.stringValue ?? "0")
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

