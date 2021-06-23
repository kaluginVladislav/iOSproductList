//
//  PLTableView.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 30.10.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import UIKit

class PLTableView: UITableView {

    private weak var wrapperView: UIView?

    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)

        if wrapperView == nil, subview.describingName == "UITableViewWrapperView" {
            wrapperView = subview
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        wrapperView?.subviews.forEach({ subview in
            if subview.describingName == "UIShadowView" {
                subview.isHidden = true
            }
        })
    }
}
