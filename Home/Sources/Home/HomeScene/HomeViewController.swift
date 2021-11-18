//
//  HomeViewController.swift
//  
//
//  Created by Yasin Nazlican on 18.11.2021.
//

import CoreUI
import UIKit

public final class HomeViewController: UIViewController {

    // MARK: Private UI Variables

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = Constants.TableView.separatorStyle
        tableView.backgroundColor = Constants.TableView.backgroundColor
        tableView.alwaysBounceVertical = Constants.TableView.alwaysBounceVertical
        tableView.keyboardDismissMode = Constants.TableView.keyboardDismissMode
        return tableView
    }()

    // MARK: Private Variables

    private let viewModel: HomeViewModel

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
        viewModel.didLoad()
    }

    // MARK: Setup Views

    private func setupViews() {
        /// Setup main
        title = Constants.MainView.title
        view.backgroundColor = Constants.MainView.backgroundColor

        /// Setup table view

        /// Setup sub views
        view.addSubview(tableView)
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
