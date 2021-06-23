//
//  UIViewController+PLCoverView.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 17.10.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import UIKit

extension UIViewController {

    @discardableResult func showCover(attributedTitle: NSAttributedString?, attributedSubtitle: NSAttributedString? = nil, attributedFootnote: NSAttributedString? = nil, image: UIImage? = nil, actions: [PLCoverView.Action] = []) -> PLCoverView {
        return view.showCover(attributedTitle: attributedTitle, attributedSubtitle: attributedSubtitle, attributedFootnote: attributedFootnote, image: image, actions: actions)
    }

    @discardableResult func showCover(title: String?, subtitle: String? = nil, footnote: String? = nil, image: UIImage? = nil, actions: [PLCoverView.Action] = []) -> PLCoverView {
        return view.showCover(title: title, subtitle: subtitle, footnote: footnote, image: image, actions: actions)
    }

    ///     Hides all  view in the form of cover from current controller view.
    ///
    func hideCover() {
        view.hideCover()
    }

    ///     Hides view in the form of cover from current controller view.
    ///
    ///     - parameters:
    ///        - coverView: The cover view.
    ///
    func hideCover(coverView: PLCoverView) {
        view.hideCover(coverView: coverView)
    }
}
