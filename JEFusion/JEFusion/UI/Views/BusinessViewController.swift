//
//  BusinessViewController.swift
//  JEFusion
//
//  Created by Tan Tan on 6/29/22.
//

import UIKit
import Combine
import JECore

class BusinessViewController: UITableViewController, UISearchResultsUpdating {
    private var viewModel: BusinessViewModel?
    private var cancellables = Set<AnyCancellable>()
    var onSelected: ((Int) -> Void)?
    
    convenience init(viewModel: BusinessViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Typing to search...."
        navigationItem.searchController = searchController
        
        self.navigationItem.title = "Restaurants"
        view.backgroundColor = .white
        tableView.register(BusinessItemCell.self, forCellReuseIdentifier: "BusinessItemCell")
        
        binding()
        viewModel?.loadBusinesses()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel?.retrieveBusinessLikes()
    }
    
    private func binding() {
        self.viewModel?.$businesses.sink(receiveValue: { [weak self] items in
            let controllers = items.map { BusinessItemCellController(title: $0.name, isLiked: $0.isLiked ?? false) }
            self?.set(controllers)
        }).store(in: &cancellables)
        
    }
    
    private func set(_ items: [BusinessItemCellController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int,BusinessItemCellController>()
        snapshot.appendSections([0])
        snapshot.appendItems(items, toSection: 0)
        self.datasource.apply(snapshot, animatingDifferences: false)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else { return }
        search(with: text);
    }
    
    private var searchWorkItem: DispatchWorkItem?
    private func search(with keyword: String) {
        searchWorkItem?.cancel()
        let workItem: DispatchWorkItem = DispatchWorkItem {
            // Make calling search requests
            print("Call request with \(keyword)")
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                print("Search request success for \(keyword)")
            }
        }
        searchWorkItem = workItem
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1), execute: workItem)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelected?(indexPath.row)
    }
}
