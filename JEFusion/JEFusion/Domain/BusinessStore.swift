//
//  BusinessStore.swift
//  JEFusion
//
//  Created by Tan Tan on 6/30/22.
//

import Combine

protocol BusinessStore {
    func insertLikeModel(_ model: LikeModel) -> AnyPublisher<Bool, Error>
    func retrieveBusinessLike() -> AnyPublisher<[LikeModel], Error>
    func updateLikeModel(_ id: String, isLiked: Bool) -> AnyPublisher<Bool, Error>
}
