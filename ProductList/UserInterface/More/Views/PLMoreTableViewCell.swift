//
//  PLMoreTableViewCell.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 26.01.2021.
//  Copyright © 2021 Vladislav Kalugin. All rights reserved.
//

import UIKit

class PLMoreTableViewCell: UITableViewCell {

    @IBOutlet private weak var contextView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        configure()
    }

    public func setContent(_ title: String?) {
        titleLabel.text = title
    }

    private func configure() {
        separatorInset.left = titleLabel.frame.origin.x
    }
}
