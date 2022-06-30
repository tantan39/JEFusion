//
//  BusinessItemCell.swift
//  JEFusion
//
//  Created by Tan Tan on 6/29/22.
//

import UIKit

struct BusinessItemCellController: Hashable {
    let title: String
    let isLiked: Bool
}

class BusinessItemCell: UITableViewCell {
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var likeIcon: UIImageView = {
        let imgv = UIImageView()
        imgv.translatesAutoresizingMaskIntoConstraints = false
        return imgv
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
        
        addSubview(likeIcon)
        likeIcon.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(25)
        }
    }
    
    func setValue(_ controller: BusinessItemCellController) {
        titleLabel.text = controller.title
        likeIcon.image = controller.isLiked ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
    }
}
