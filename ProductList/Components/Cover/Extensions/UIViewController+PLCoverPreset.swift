//
//  UIViewController+PLCoverPreset.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 17.10.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import UIKit

extension UIViewController {

    @discardableResult func showCover(preset: PLCoverPreset, attributedTitle: NSAttributedString?, attributedSubtitle: NSAttributedString? = nil, attributedFootnote: NSAttributedString? = nil, image: UIImage? = nil, actions: [PLCoverView.Action] = []) -> PLCoverView {
        return view.showCover(preset: preset, attributedTitle: attributedTitle, attributedSubtitle: attributedSubtitle, attributedFootnote: attributedFootnote, image: image, actions: actions)
    }

    @discardableResult func showCover(preset: PLCoverPreset, title: String? = nil, subtitle: String? = nil, footnote: String? = nil, image: UIImage? = nil, actions: [PLCoverView.Action] = []) -> PLCoverView {
        return view.showCover(preset: preset, title: title, subtitle: subtitle, footnote: footnote, image: image, actions: actions)
    }
}
