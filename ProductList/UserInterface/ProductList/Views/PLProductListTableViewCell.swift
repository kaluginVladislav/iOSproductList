//
//  PLProductListTableViewCell.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 20.08.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import UIKit

class PLProductListTableViewCell: UITableViewCell {

    @IBOutlet private weak var contentStackView: UIStackView!
    @IBOutlet private weak var infoStackView: UIStackView!
    @IBOutlet private weak var headerStackView: UIStackView!
    @IBOutlet private weak var emojiLabel: UILabel!
    @IBOutlet private weak var countView: UIView!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var volumeStackView: UIView!
    @IBOutlet private weak var volumeLabel: UILabel!
    @IBOutlet private weak var volumeUnitLabel: UILabel!
    @IBOutlet private weak var noteLabel: UILabel!
    let emojies = PLEmojiCategory.allCases

    override func awakeFromNib() {
        super.awakeFromNib()

        configureView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        configureContentSizeCategory()
    }

    private func configureView() {
        countView.layer.cornerRadius = countView.frame.height / 2

        let backgroundView = UIView()
        backgroundView.backgroundColor = backgroundColor
        selectedBackgroundView = backgroundView
    }

    private func configureContentSizeCategory() {
        if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
            contentStackView.alignment = .leading
            contentStackView.spacing = 8
            contentStackView.axis = .vertical

            headerStackView.alignment = .leading
            headerStackView.axis = .vertical

            separatorInset.left = contentView.frame.origin.x + contentStackView.frame.origin.x
        } else {
            contentStackView.alignment = .center
            contentStackView.spacing = 16
            contentStackView.axis = .horizontal

            headerStackView.alignment = .fill
            headerStackView.axis = .horizontal

            separatorInset.left = contentView.frame.origin.x + contentStackView.frame.origin.x + nameLabel.frame.origin.x
        }
    }

    public func setContent(_ package: PLProductPackage) {
        nameLabel.text = package.product.name
        emojiLabel.text = package.product.emoji

        if package.count > 1 {
            countLabel.text = String(package.count)
            countView.isHidden = false
        } else {
            countView.isHidden = true
        }

        if let volume = package.volume, volume.count > 0 {
            volumeLabel.text = String(volume.count)
            switch volume.unit {
            case .gr:
                volumeUnitLabel.text = "volume.unit.gr".localized
            case .kg:
                volumeUnitLabel.text = "volume.unit.kg".localized
            case .ml:
                volumeUnitLabel.text = "volume.unit.ml".localized
            case .l:
                volumeUnitLabel.text = "volume.unit.l".localized
            }

            volumeLabel.isHidden = false
            volumeUnitLabel.isHidden = false
            print(package.volume, "!!!!!5555")
        } else {
//            volumeLabel.isHidden = true
//            volumeUnitLabel.isHidden = true
            volumeLabel.text = ""
            volumeUnitLabel.text = ""
            print(package.volume, "!!!!!hidden")
        }

        if let note = package.note {
            noteLabel.text = note

            noteLabel.isHidden = false
        } else {
            noteLabel.isHidden = true
        }

        Log.debug("PLProductListTableViewCell did set content: \(package)")
    }
}
