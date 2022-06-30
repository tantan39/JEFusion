//
//  BusinessViewModel.swift
//  JEFusion
//
//  Created by Tan Tan on 6/29/22.
//

import Foundation
import Combine

class BusinessViewModel: ObservableObject {
    private let loader: BusinessLoader?
    private let store: BusinessStore?
    
    private var cancellables = Set<AnyCancellable>()
    @Published var businesses: [BusinessModel] = []
    var location: String
    
    init(apiService: BusinessLoader, store: BusinessStore, location: String) {
        self.loader = apiService
        self.store = store
        self.location = location
        
    }
    
    func retrieveBusinessLikes() {
        store?.retrieveBusinessLike()
            .receive(on: DispatchQueue.main, options: .none)
            .sink(receiveCompletion: { _ in }, receiveValue: { models in
                print("likes \(models)")
                self.businesses = self.businesses.map({ business in
                    let model = models.first(where: { $0.businessId == business.id })
                    business.isLiked = model?.isLiked
                    return business
                })
            }).store(in: &cancellables)
    }
    
    func loadBusinesses() {
        guard let loader = loader else { return }
        loader.fetchBusinesses(by: location)
            .receive(on: DispatchQueue.main, options: .none)
            .sink { _ in
            } receiveValue: { items in
                self.businesses = items
                self.retrieveBusinessLikes()
            }.store(in: &cancellables)
    }
}
