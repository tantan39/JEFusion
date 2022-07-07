//
//  BusinessModel.swift
//  JEFusion
//
//  Created by Tan Tan on 6/29/22.
//

import Foundation

public class BusinessModel: Decodable {
    public let id: String
    public let name: String
    public let rating: Double
    public let imageURL: String
    public let displayAddress: [String]
    public let categories: [String]
    public var isLiked: Bool?
    
    public required init(from decoder: Decoder) throws {
        let remoteItem = try RemoteItem(from: decoder)
        self.id = remoteItem.id
        self.name = remoteItem.name
        self.imageURL = remoteItem.image_url
        self.rating = remoteItem.rating ?? 0.0
        self.displayAddress = remoteItem.location.display_address
        self.categories = remoteItem.categories.map { $0.title }
        self.isLiked = false
    }
}

fileprivate struct RemoteItem: Decodable {
    let id: String
    let name: String
    let image_url: String
    let rating: Double?
    let categories: [Category]
    let location: Location
    
    struct Category: Decodable {
        let title: String
    }
    
    struct Location: Decodable {
        let display_address: [String]
    }
}
