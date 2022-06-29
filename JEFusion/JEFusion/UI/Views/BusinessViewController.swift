//
//  BusinessViewController.swift
//  JEFusion
//
//  Created by Tan Tan on 6/29/22.
//

import UIKit
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
            .sink { error in
                debugPrint("Failed \(error)")
            } receiveValue: { items in
                print("items \(items)")
                self.businesses = items
            }.store(in: &cancellables)
    }
}

class BusinessViewController: UIViewController {
    private var viewModel: BusinessViewModel?
    
    convenience init(viewModel: BusinessViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        viewModel?.loadBusinesses()
    }
}
