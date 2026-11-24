//
//  ImageTableCellViewModel.swift
//  
//
//  Created by Yasin Nazlican on 19.11.2021.
//

import CoreBase
import UIKit

public final class ImageTableCellViewModel: Sendable {

    // MARK: Public Variables

    public let imageModel: NASAImageDTO

    var imageURL: URL? {
        imageModel.thumbnailURL
    }

    public var text: NSAttributedString {
        let text = NSMutableAttributedString()
        text.append(titleText)
        text.append(NSAttributedString(string: "\n"))
        text.append(photographerText)
        text.append(NSAttributedString(string: " | ", attributes: subtitleAttributes))
        text.append(dateText)
        return text
    }

    // MARK: Life-Cycle

    public init(imageModel: NASAImageDTO) {
        self.imageModel = imageModel
    }

    // MARK: Private Read-Only

    private var subtitleAttributes: [NSAttributedString.Key: Any] {
        [
            .foregroundColor: UIColor.secondaryTextColor,
            .font: UIFont.appFont(size: 14, weight: .regular),
        ]
    }

    private var titleText: NSAttributedString {
        .init(
            string: imageModel.title,
            attributes: [
                .foregroundColor: UIColor.primaryTextColor,
                .font: UIFont.appFontBold(16)
            ]
        )
    }

    private var photographerText: NSAttributedString {
        .init(
            string: imageModel.credit ?? "-",
            attributes: subtitleAttributes
        )
    }

    private var dateText: NSAttributedString {
        .init(
            string: imageModel.dateCreated.map { GlobalDateFormatter.date($0) } ?? "-",
            attributes: subtitleAttributes
        )
    }
}
