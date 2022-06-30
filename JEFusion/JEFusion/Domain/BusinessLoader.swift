//
//  BusinessLoader.swift
//  JEFusion
//
//  Created by Tan Tan on 6/29/22.
//

import Foundation
import Combine

protocol BusinessLoader {
    func fetchBusinesses(by location: String) -> AnyPublisher<[BusinessModel], Error>
}


class BusinessModel: Decodable {
    let id: String
    let name: String
    let rating: Double
    let displayAddress: [String]
    let categories: [String]
    let isLiked: Bool?
    
    required init(from decoder: Decoder) throws {
        let remoteItem = try RemoteItem(from: decoder)
        self.id = remoteItem.id
        self.name = remoteItem.name
        self.rating = remoteItem.rating ?? 0.0
        self.displayAddress = remoteItem.location.display_address
        self.categories = remoteItem.categories.map { $0.title }
        self.isLiked = false
    }
}

fileprivate struct RemoteItem: Decodable {
    let id: String
    let name: String
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
