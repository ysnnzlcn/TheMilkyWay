//
//  ImageDetailsTableDataSource.swift
//  
//
//  Created by Yasin Nazlican on 20.11.2021.
//

import Combine
import CoreUI
import UIKit

public final class ImageDetailsTableDataSource: BaseDiffableDataSource<ImageDetailsCellType> {

    // MARK: Private Variables

    private let viewModel: ImageDetailsViewModel
    private var cancellable: AnyCancellable?

    // MARK: Life-Cycle

    init(_ tableView: UITableView, _ viewModel: ImageDetailsViewModel) {
        self.viewModel = viewModel
        super.init(tableView: tableView) { tableView, indexPath, item -> UITableViewCell? in
            switch item.cell {
            case .imageHeaderCell(let url):
                let imageCell = tableView.dequeueReusableCell(withIdentifier: ImageHeaderTableViewCell.reuseIdentifier, for: indexPath) as? ImageHeaderTableViewCell
                imageCell?.url = url
                return imageCell

            case .plainTextCell(let text):
                let imageCell = tableView.dequeueReusableCell(withIdentifier: PlainTextTableViewCell.reuseIdentifier, for: indexPath) as? PlainTextTableViewCell
                imageCell?.labelText = text
                return imageCell
            }
        }
        bindViewModel()
    }

    // MARK: Private Methods

    private func bindViewModel() {
        cancellable = viewModel.$items
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] items in
                self?.update(items: items)
            })
    }
}

// MARK: Cell Types

/// The attributed text is never mutated after it's created.
public enum ImageDetailsCellType: Equatable, @unchecked Sendable {

    case imageHeaderCell(_ url: String?)
    case plainTextCell(_ text: NSAttributedString)
}
