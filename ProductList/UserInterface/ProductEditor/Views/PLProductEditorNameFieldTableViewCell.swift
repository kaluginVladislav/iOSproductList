//
//  PLProductEditorNameFieldTableViewCell.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 22.08.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import UIKit

protocol PLProductEditorNameFieldTableViewCellDataSource: AnyObject {
    func nameFieldTableViewCellSearchResultView(_ nameFieldTableViewCell: PLProductEditorNameFieldTableViewCell) -> PLProducteditorResultCollectionView?
}

protocol PLProductEditorNameTableViewCellDelegate: AnyObject {

    func nameFieldTableViewCell(_ nameFieldTableViewCell: PLProductEditorNameFieldTableViewCell, didChangeName name: String)

    func avatarViewTableViewCellDidSelectAvatar(_ avatarViewTableViewCell: PLProductEditorNameFieldTableViewCell)
}

class PLProductEditorNameFieldTableViewCell: UITableViewCell {

    @IBOutlet private weak var contextView: UIView!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var avatarView: UIView!
    @IBOutlet private weak var avatarLabel: UILabel!

    public weak var delegate: PLProductEditorNameTableViewCellDelegate?
    public weak var dataSource: PLProductEditorNameFieldTableViewCellDataSource?

    override func awakeFromNib() {
        super.awakeFromNib()

        configure()
    }

    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }

    private func configure() {
        separatorInset.left = avatarView.frame.origin.x
        avatarView.layer.cornerRadius = avatarView.bounds.height / 2
        textField.placeholder = "product.editor.name.text.field.placeholder".localized
    }

    public func setContent(_ avatar: String, _ name: String) {
        avatarLabel.text = avatar
        textField.text = name

        Log.debug("PLProductEditorAvatarFieldTableViewCell did set content \(avatar)")
        Log.debug("PLProductEditorNameFieldTableViewCell did set content \(name)")
    }

    public func setHints() {
        textField.inputAccessoryView = dataSource?.nameFieldTableViewCellSearchResultView(self)
    }

    @IBAction private func avatarViewAction(_ sender: UIView) {
        delegate?.avatarViewTableViewCellDidSelectAvatar(self)
    }
}

extension PLProductEditorNameFieldTableViewCell: UITextFieldDelegate {

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""

        delegate?.nameFieldTableViewCell(self, didChangeName: "")

        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)

            if updatedText.count <= 40, updatedText.first?.isWhitespace != true {
                delegate?.nameFieldTableViewCell(self, didChangeName: updatedText)

                return true
            } else {
                textField.animateWithShake()

                return false
            }
        } else {
            return true
        }
    }
}
