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

        var snapshot = NSDiffableDataSourceSnapshot<Int,City>()
        snapshot.appendSections([0])
        snapshot.appendItems(viewModel.cities, toSection: 0)
        self.datasource.apply(snapshot, animatingDifferences: false)
        
    }
    
    lazy var datasource = UITableViewDiffableDataSource<Int, City>(tableView: tableView) { [weak self] tableView, indexPath, city in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell") as? CityCell else { return UITableViewCell() }
        let city = city
        cell.titleLabel.text = city.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

}

class CityCell: UITableViewCell {
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
        }
    }
}
