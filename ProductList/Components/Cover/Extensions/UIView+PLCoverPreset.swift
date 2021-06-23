//
//  UIView+PLCoverPreset.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 17.10.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import UIKit

extension UIView {

    @discardableResult func showCover(preset: PLCoverPreset, attributedTitle: NSAttributedString?, attributedSubtitle: NSAttributedString? = nil, attributedFootnote: NSAttributedString? = nil, image: UIImage? = nil, actions: [PLCoverView.Action] = []) -> PLCoverView {
        var presetAttributedTitle: NSAttributedString?
        var presetAttributedSubtitle: NSAttributedString?
        var presetAttributedFootnote: NSAttributedString?

        switch preset {
        case .empty:
            presetAttributedTitle = NSAttributedString(string: "cover.preset.empty.title".localized, attributes: [.font: UIFont.TextStyle.headline, .foregroundColor: UIColor.applicationLabel])
            presetAttributedSubtitle = NSAttributedString(string: "cover.preset.empty.subtitle".localized, attributes: [.font: UIFont.TextStyle.subheadline, .foregroundColor: UIColor.applicationSecondaryLabel])
        case .error(let error):
            presetAttributedTitle = NSAttributedString(string: "cover.preset.error.title".localized, attributes: [.font: UIFont.TextStyle.headline, .foregroundColor: UIColor.applicationLabel])
            presetAttributedSubtitle = NSAttributedString(string: "cover.preset.error.subtitle".localized, attributes: [.font: UIFont.TextStyle.subheadline, .foregroundColor: UIColor.applicationSecondaryLabel])

            if let error = error {
                presetAttributedFootnote = NSAttributedString(string: error.localizedDescription, attributes: [.font: UIFont.TextStyle.footnote, .foregroundColor: UIColor.applicationTertiaryLabel])
            }
        case .criticalError(let error):
            presetAttributedTitle = NSAttributedString(string: "cover.preset.error.critical.title".localized, attributes: [.font: UIFont.TextStyle.headline, .foregroundColor: UIColor.applicationLabel])
            presetAttributedSubtitle = NSAttributedString(string: "cover.preset.error.critical.subtitle".localized, attributes: [.font: UIFont.TextStyle.subheadline, .foregroundColor: UIColor.applicationSecondaryLabel])

            if let error = error {
                presetAttributedFootnote = NSAttributedString(string: error.localizedDescription, attributes: [.font: UIFont.TextStyle.footnote, .foregroundColor: UIColor.applicationTertiaryLabel])
            }
        }

        let coverView = PLCoverView(attributedTitle: attributedTitle ?? presetAttributedTitle, attributedSubtitle: attributedSubtitle ?? presetAttributedSubtitle, attributedFootnote: attributedFootnote ?? presetAttributedFootnote, image: image, actions: actions)

        return showCover(coverView: coverView)
    }

    @discardableResult func showCover(preset: PLCoverPreset, title: String? = nil, subtitle: String? = nil, footnote: String? = nil, image: UIImage? = nil, actions: [PLCoverView.Action] = []) -> PLCoverView {
        var presetTitle: String?
        var presetSubtitle: String?
        var presetFootnote: String?

        switch preset {
        case .empty:
            presetTitle = "cover.preset.empty.title".localized
            presetSubtitle = "cover.preset.empty.subtitle".localized
        case .error(let error):
            presetTitle = "cover.preset.error.title".localized
            presetSubtitle = "cover.preset.error.subtitle".localized

            if let error = error {
                presetFootnote = error.localizedDescription
            }
        case .criticalError(let error):
            presetTitle = "cover.preset.error.critical.title".localized
            presetSubtitle = "cover.preset.error.critical.subtitle".localized

            if let error = error {
                presetFootnote = error.localizedDescription
            }
        }

        let coverView = PLCoverView(title: title ?? presetTitle, subtitle: subtitle ?? presetSubtitle, footnote: footnote ?? presetFootnote, image: image, actions: actions)

        return showCover(coverView: coverView)
    }
}
