//
//  HomeViewController.swift
//  JEFusion
//
//  Created by Tan Tan on 6/29/22.
//

import UIKit
import SnapKit

class HomeViewController: UITableViewController {
    let viewModel: HomeViewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        tableView.register(CityCell.self, forCellReuseIdentifier: "CityCell")

        setTableViewDatasource()
    }
    
    private func setTableViewDatasource() {
        var snapshot = NSDiffableDataSourceSnapshot<Int,CityCellController>()
        snapshot.appendSections([0])
        snapshot.appendItems(viewModel.cities.map { CityCellController(title: $0.title) }, toSection: 0)
        self.datasource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - TableView Datasource/Delegate
    
    lazy var datasource = UITableViewDiffableDataSource<Int, CityCellController>(tableView: tableView) { [weak self] tableView, indexPath, city in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell") as? CityCell else { return UITableViewCell() }
        let city = city
        cell.titleLabel.text = city.title
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
