//
//  HomeViewController.swift
//  
//
//  Created by Yasin Nazlican on 18.11.2021.
//

import Combine
import CoreUI
import UIKit

public final class HomeViewController: UIViewController {

    // MARK: Private UI Variables

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = Constants.TableView.separatorStyle
        tableView.backgroundColor = Constants.TableView.backgroundColor
        tableView.alwaysBounceVertical = Constants.TableView.alwaysBounceVertical
        tableView.keyboardDismissMode = Constants.TableView.keyboardDismissMode
        tableView.register(
            UINib(nibName: ImageTableViewCell.reuseIdentifier, bundle: .module),
            forCellReuseIdentifier: ImageTableViewCell.reuseIdentifier
        )
        return tableView
    }()

    // MARK: Private Variables

    private let viewModel: HomeViewModel
    private var cancellables = Set<AnyCancellable>()
    private lazy var tableDataSource = HomeTableViewDataSource(tableView, viewModel)
    private lazy var tableDelegate = HomeTableViewDelegate(viewModel)

    // MARK: Life-Cycle

    public init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupViewModel()
        viewModel.didLoad()
    }

    // MARK: Setup Views

    private func setupViews() {
        /// Setup main
        title = Constants.MainView.title
        view.backgroundColor = Constants.MainView.backgroundColor
        navigationController?.navigationBar.prefersLargeTitles = true

        /// Setup table view
        tableView.dataSource = tableDataSource
        tableView.delegate = tableDelegate

        /// Setup sub views
        view.addSubview(tableView)

        /// Add Constraints
        NSLayoutConstraint.activate(
            [
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
                tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ]
        )
    }

    // MARK: Setup ViewModel

    private func setupViewModel() {
        viewModel.$items
            .receive(on: RunLoop.main)
            .map { $0.map { HomeTableViewDataSource.Item(cell: .imageCell($0)) } }
            .sink(receiveValue: { [weak self] items in
                self?.tableDataSource.update(items: items)
            })
            .store(in: &cancellables)
    }
}

extension HomeViewController {

    private enum Constants {

        static let margins: CGFloat = 0.0

        enum MainView {

            static let title = "The Milky Way"
            static let backgroundColor: UIColor = .backgroundColor
        }

        enum TableView {

            static let keyboardDismissMode: UIScrollView.KeyboardDismissMode = .onDrag
            static let separatorStyle: UITableViewCell.SeparatorStyle = .none
            static let backgroundColor: UIColor = .backgroundColor
            static let alwaysBounceVertical = true
        }
    }
}
