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
            .receive(on: DispatchQueue.main, options: .none)
            .sink { error in
            } receiveValue: { items in
                print("items \(items)")
                self.businesses = items
            }.store(in: &cancellables)
    }
}

class BusinessViewController: UITableViewController {
    private var viewModel: BusinessViewModel?
    private var cancellables = Set<AnyCancellable>()
    convenience init(viewModel: BusinessViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        tableView.register(BusinessItemCell.self, forCellReuseIdentifier: "BusinessItemCell")
        
        binding()
        loadBusinesses()
    }
    
    private func binding() {
        self.viewModel?.$businesses.sink(receiveValue: { [weak self] items in
            let controllers = items.map { BusinessItemCellController(title: $0.name, isLiked: false) }
            self?.set(controllers)
        }).store(in: &cancellables)
    }
    
    private func loadBusinesses() {
        viewModel?.loadBusinesses()
    }
    
    private func set(_ items: [BusinessItemCellController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int,BusinessItemCellController>()
        snapshot.appendSections([0])
        snapshot.appendItems(items, toSection: 0)
        self.datasource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - TableView Datasource/Delegate
    
    lazy var datasource = UITableViewDiffableDataSource<Int, BusinessItemCellController>(tableView: tableView) { [weak self] tableView, indexPath, controller in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessItemCell") as? BusinessItemCell else { return UITableViewCell() }
        cell.setValue(controller)
        cell.separatorInset = UIEdgeInsets(top: 0, left: -1000, bottom: 0, right: 0)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
}
