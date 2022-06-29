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
    let isLiked: Bool
    
    init(id: String, name: String, isLiked: Bool) {
        self.id = id
        self.name = name
        self.isLiked = isLiked
    }
}
