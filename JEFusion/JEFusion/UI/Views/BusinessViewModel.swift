//
//  BusinessViewModel.swift
//  JEFusion
//
//  Created by Tan Tan on 6/29/22.
//

import Foundation
import Combine

class BusinessViewModel {
    private let loader: BusinessLoader?
    private var cancellables = Set<AnyCancellable>()
    @Published var businesses: [BusinessModel] = []
    var location: String
    
    init(apiService: BusinessLoader, location: String) {
        self.loader = apiService
        self.location = location
    }
    
    func loadBusinesses() {
        guard let loader = loader else { return }
        loader.fetchBusinesses(by: location)
            .receive(on: DispatchQueue.main, options: .none)
            .sink { error in
            } receiveValue: { items in
                print("items \(items)")
                self.businesses = items
            }.store(in: &cancellables)
    }
}
