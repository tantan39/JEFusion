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
    func fetchBusinessReviews(with id: String) -> AnyPublisher<[Review], Error>
}

struct Review: Decodable {
    let id: String
    let text: String
    let user: User
    
    struct User: Decodable {
        let id: String
        let name: String
    }
}
