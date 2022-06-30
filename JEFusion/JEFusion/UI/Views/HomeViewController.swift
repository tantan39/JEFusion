//
//  HomeViewController.swift
//  JEFusion
//
//  Created by Tan Tan on 6/29/22.
//

import UIKit
import SnapKit

class HomeViewController: UITableViewController {
    var viewModel: HomeViewModel?
    var onSelected: ((Int) -> Void)?
    
    convenience init(_ viewModel: HomeViewModel) {
        self.init()
        self.viewModel = viewModel
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = "Cities"
        view.backgroundColor = .white
        tableView.register(CityCell.self, forCellReuseIdentifier: "CityCell")

        setTableViewDatasource()
    }
    
    private func setTableViewDatasource() {
        guard let vm = viewModel else { return }
        var snapshot = NSDiffableDataSourceSnapshot<Int,CityCellController>()
        snapshot.appendSections([0])
        snapshot.appendItems(vm.cities.map { CityCellController(title: $0.title) }, toSection: 0)
        self.datasource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - TableView Datasource/Delegate
    
    lazy var datasource = UITableViewDiffableDataSource<Int, CityCellController>(tableView: tableView) { [weak self] tableView, indexPath, controller in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell") as? CityCell else { return UITableViewCell() }
        cell.setValue(controller)
        cell.separatorInset = UIEdgeInsets(top: 0, left: -1000, bottom: 0, right: 0)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.onSelected?(indexPath.row)
    }
}
