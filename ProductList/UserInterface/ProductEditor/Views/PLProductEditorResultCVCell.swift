//
//  CustomCell.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 28.01.2021.
//  Copyright © 2021 Vladislav Kalugin. All rights reserved.
//

import UIKit

protocol PLProductEditorResultCVCellDelegate: AnyObject {
    func productEditorCVCellDelete(_ productEditorCell: PLProductEditorResultCVCell, at indexPath: IndexPath)

    func productEditorCVCellChoose(_ productEditor: PLProductEditorViewController, at indexPath: IndexPath)
}

class PLProductEditorResultCVCell: UICollectionViewCell {

    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    public weak var delegate: PLProductEditorResultCVCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    private func configure() {
        cellBackgroundView.clipsToBounds = true
        cellBackgroundView.layer.cornerRadius = 8
        cellBackgroundView.layer.backgroundColor = UIColor(named: "Application CollectionViewCell Color")?.cgColor
        layer.cornerRadius = 8
    }

    public func setContent(_ product: PLProduct) {
        emojiLabel.text = product.emoji
        nameLabel.text = product.name

        Log.debug("PLProductEditorResultCVCell did set content: \(product)")
    }

}
