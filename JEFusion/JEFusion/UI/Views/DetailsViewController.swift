//
//  DetailsViewController.swift
//  JEFusion
//
//  Created by Tan Tan on 6/29/22.
//

import Foundation
import UIKit
import Combine

class DetailsViewModel {
    private var loader: BusinessLoader
    var business: BusinessModel
    @Published var reviews: [Review] = []
    private var cancellables = Set<AnyCancellable>()
    
    init(loader: BusinessLoader, business: BusinessModel) {
        self.loader = loader
        self.business = business
    }
    
    func fetchReviews() {
        loader.fetchBusinessReviews(with: business.id)
            .receive(on: DispatchQueue.main, options: .none)
            .sink(receiveCompletion: { _ in }) { [weak self] reviews in
                self?.reviews = Array(reviews.prefix(3))
            }.store(in: &cancellables)
    }
    
}

class DetailsViewController: UIViewController {
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var backdropImageView: UIImageView = {
        let imgv = UIImageView()
        imgv.translatesAutoresizingMaskIntoConstraints = false
        imgv.contentMode = .scaleAspectFill
        imgv.clipsToBounds = true
        imgv.backgroundColor = .white
        return imgv
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    lazy var overviewLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    lazy var reviewLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    private var viewModel: DetailsViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    convenience init(_ viewModel: DetailsViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        self.navigationItem.title = "Details"
        view.backgroundColor = .white
        setupUI()
        
        self.viewModel?.fetchReviews()
        setValue()
    }
    
    private func setupUI() {
        setupScrollView()
        setupContainerView()
        setupBackdrop()
        setupTitle()
        setupOverviewLabel()
        setupReviewsLabel()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
    }
    
    private func setupContainerView() {
        scrollView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
            make.width.equalTo(view.snp.width)
        }
    }
    
    private func setupBackdrop() {
        containerView.addSubview(backdropImageView)
        backdropImageView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(view.snp.height).multipliedBy(0.5)
        }
    }
    
    private func setupTitle() {
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.top.equalTo(backdropImageView.snp.bottom).offset(30)
        }
    }
    
    private func setupOverviewLabel() {
        containerView.addSubview(overviewLabel)
        overviewLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
        }
    }
    
    private func setupReviewsLabel() {
        containerView.addSubview(reviewLabel)
        reviewLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleLabel)
            make.top.equalTo(overviewLabel.snp.bottom).offset(20)
            make.bottom.equalToSuperview().offset(-60)
        }
    }
    
    private func setValue() {
        guard let vm = viewModel else { return }
        
        DispatchQueue.global().async {
            let url = URL(string: vm.business.imageURL)!
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    self.backdropImageView.image = UIImage(data: data)
                }
            }
        }
        titleLabel.text = vm.business.name
        overviewLabel.text = "Rating: \(vm.business.rating) \n\nAddress: \(vm.business.displayAddress.joined(separator: ",")) \n\nCategories: \n\(vm.business.categories.joined(separator: "-"))"
        
        vm.$reviews.sink { [weak self] reviews in
            
            let text = reviews.map { "(\($0.user.name))" + ": " + $0.text }
            self?.reviewLabel.text = "Reviews: \n" + text.joined(separator: "\n\n")
        }.store(in: &cancellables)
    }
}
