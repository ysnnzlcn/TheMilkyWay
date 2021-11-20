//
//  ImageTableViewCell.swift
//  
//
//  Created by Yasin Nazlican on 19.11.2021.
//

import CoreUI
import UIKit

final class ImageTableViewCell: UITableViewCell, Reusable {

    @IBOutlet private var nasaImageView: AsyncImageView!
    @IBOutlet private var nasaLabel: UILabel!

    public var cellViewModel: ImageTableCellViewModel? {
        didSet {
            if let imageURL = cellViewModel?.imageURL {
                nasaImageView.load(url: imageURL, cache: .shared)
            }
            nasaLabel.attributedText = cellViewModel?.text
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nasaImageView.image = nil
    }
}
