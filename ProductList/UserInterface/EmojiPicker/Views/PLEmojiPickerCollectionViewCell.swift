//
//  PLEmojiPickerCollectionViewCell.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 28.08.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import UIKit

class PLEmojiPickerCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var contextView: UIView!
    @IBOutlet private weak var emojiLabel: UILabel!

    override var isSelected: Bool {
        didSet { contextView.backgroundColor = isSelected ? .applicationSecondaryTint : .applicationSecondaryGroupedBackground }
    }

    override var isHighlighted: Bool {
        didSet { contextView.alpha = isHighlighted ? 0.5 : 1 }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layoutView()
    }

    private func layoutView() {
        contextView.layer.cornerRadius = frame.size.width / 2
    }

    public func setContent(_ emoji: String) {
        emojiLabel.text = emoji

        Log.debug("PLEmojiPickerCollectionViewCell did set content \(emoji)")
    }
}
