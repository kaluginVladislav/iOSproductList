//
//  PLProductEditorNoteFieldTableViewCell.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 17.10.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import UIKit

protocol PLProductEditorNoteFieldTableViewCellDelegate: AnyObject {

    func noteFieldTableViewCell(_ noteFieldTableViewCell: PLProductEditorNoteFieldTableViewCell, didChangeNote note: String?)

}

class PLProductEditorNoteFieldTableViewCell: UITableViewCell {

    @IBOutlet private weak var contextView: UIView!
    @IBOutlet private weak var textView: PLTextView!
    @IBOutlet private weak var textViewHeightConstraint: NSLayoutConstraint!

    public weak var delegate: PLProductEditorNoteFieldTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        configureView()
    }

    private func configureView() {
        separatorInset.left = textView.frame.origin.x

        textView.placeholder = "product.editor.note.field.placeholder".localized

        if let font = textView.font {
            var verticalInset: CGFloat {
                if textView.frame.height > font.lineHeight {
                    return (textViewHeightConstraint.constant - font.lineHeight) / 2
                } else {
                    return 0
                }
            }

            textView.textContainerInset = UIEdgeInsets(top: verticalInset, left: 0, bottom: verticalInset, right: 0)
            textView.textContainer.lineFragmentPadding = 0
        }
    }

    public func setContent(_ note: String?) {
        if let note = note {
            textView.text = note

            Log.debug("PLProductEditorNoteFieldTableViewCell did set content \(note)")
        } else {
            textView.text = nil

            Log.debug("PLProductEditorNoteFieldTableViewCell did set empty content")
        }
    }
}

extension PLProductEditorNoteFieldTableViewCell: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        let optionalText = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : textView.text

        delegate?.noteFieldTableViewCell(self, didChangeNote: optionalText)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let currentText = textView.text,
            let textRange = Range(range, in: currentText) {
            let updatedText = currentText.replacingCharacters(in: textRange, with: text)

            if updatedText.count <= 140, updatedText.first?.isWhitespace != true, !updatedText.contains("\n") {
                return true
            } else {
                textView.animateWithShake()

                return false
            }
        } else {
            return true
        }
    }
}
