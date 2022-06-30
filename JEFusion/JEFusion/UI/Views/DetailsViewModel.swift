//
//  DetailsViewModel.swift
//  JEFusion
//
//  Created by Tan Tan on 6/30/22.
//

import Foundation
import Combine

class DetailsViewModel {
    private var loader: BusinessLoader
    private var store: BusinessStore
    var business: BusinessModel
    @Published var reviews: [Review] = []
    private var cancellables = Set<AnyCancellable>()
    
    init(loader: BusinessLoader, store: BusinessStore, business: BusinessModel) {
        self.loader = loader
        self.store = store
        self.business = business
    }
    
    func fetchReviews() {
        loader.fetchBusinessReviews(with: business.id)
            .receive(on: DispatchQueue.main, options: .none)
            .sink(receiveCompletion: { _ in }) { [weak self] reviews in
                self?.reviews = Array(reviews.prefix(3))
            }.store(in: &cancellables)
    }
    
    func updateLikeModel() {
        guard let isLiked = business.isLiked else { return }
        self.store.updateLikeModel(business.id, isLiked: isLiked)
            .sink(receiveCompletion: { _ in }, receiveValue: { success in
                print("Like updating... \(success)")
            }).store(in: &cancellables)
    }
}
