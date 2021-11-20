//
//  ImageTableCellViewModel.swift
//  
//
//  Created by Yasin Nazlican on 19.11.2021.
//

import Core
import Foundation
import UIKit

final class ImageTableCellViewModel {

    // MARK: Private Constants

    private let imageModel: NASAImage
    private let subtitleAttributes: [NSAttributedString.Key: Any]  = [
        .foregroundColor: UIColor.secondaryTextColor,
        .font: UIFont.appFont(size: 14, weight: .regular)
    ]

    // MARK: Public Variables

    var imageURL: URL? {
        URL(string: imageModel.links.first?.percentageEncodedHref ?? "")
    }

    var text: NSAttributedString {
        let text = NSMutableAttributedString()
        text.append(titleText)
        text.append(NSAttributedString(string: "\n"))
        text.append(photographerText)
        text.append(NSAttributedString(string: " | ", attributes: subtitleAttributes))
        text.append(dateText)
        return text
    }

    // MARK: Life-Cycle

    init(model: NASAImage) {
        imageModel = model
    }

    // MARK: Private Read-Onlys

    private var titleText: NSAttributedString {
        .init(
            string: imageModel.info.first?.title ?? "-",
            attributes: [
                .foregroundColor: UIColor.primaryTextColor,
                .font: UIFont.appFontBold(16)
            ]
        )
    }

    private var photographerText: NSAttributedString {
        .init(
            string: imageModel.info.first?.photographer ?? "-",
            attributes: subtitleAttributes
        )
    }

    private var dateText: NSAttributedString {
        let asDate = imageModel.info.first?.dateCreated.toDate()
        let beautifiedDate = asDate?.toString(format: "dd MMM, yyyy")
        return .init(
            string: beautifiedDate ?? "-",
            attributes: subtitleAttributes
        )
    }
}
