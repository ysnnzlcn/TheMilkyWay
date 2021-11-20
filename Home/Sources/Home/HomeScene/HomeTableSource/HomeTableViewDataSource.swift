//
//  HomeTableViewDataSource.swift
//  
//
//  Created by Yasin Nazlican on 19.11.2021.
//

import CoreUI
import UIKit

final class HomeTableViewDataSource: BaseDiffableDataSource<HomeCellType> {

    // MARK: Private Variables

    private let viewModel: HomeViewModel

    // MARK: Life-Cycle

    init(_ tableView: UITableView, _ viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(tableView: tableView) { tableView, indexPath, item -> UITableViewCell? in
            switch item.cell {
            case .imageCell(let cellViewModel):
                let imageCell = tableView.dequeueReusableCell(withIdentifier: ImageTableViewCell.reuseIdentifier, for: indexPath) as? ImageTableViewCell
                imageCell?.cellViewModel = cellViewModel
                return imageCell
            }
        }
    }
}

enum HomeCellType {

    case imageCell(_ cellViewModel: ImageTableCellViewModel)
}
