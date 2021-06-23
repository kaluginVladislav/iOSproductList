//
//  PLProductEditorCountFieldTableViewCell.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 22.08.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import UIKit

protocol PLProductEditorCountTableViewCellDelegate: AnyObject {

    func countFieldTableViewCell(_ countFieldTableViewCell: PLProductEditorCountFieldTableViewCell, didChangeCount count: Int)

}

class PLProductEditorCountFieldTableViewCell: UITableViewCell {

    @IBOutlet private weak var contextView: UIView!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var stepperView: UIStepper!

    public weak var delegate: PLProductEditorCountTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        configureStepper()
        configure()
    }

    private func configure() {
        separatorInset.left = textField.frame.origin.x
    }

    public func setContent(_ count: Int) {
        textField.text = String(count)
        stepperView.value = Double(count)

        Log.debug("PLProductEditorCountFieldTableViewCell did set content \(count)")
    }

    private func configureStepper() {
        stepperView.minimumValue = 1
        stepperView.maximumValue = 99
    }

    @IBAction private func stepperValueChengerHandler(_ sender: UIStepper) {
        let intValue = Int(sender.value)

        textField.text = String(intValue)

        delegate?.countFieldTableViewCell(self, didChangeCount: intValue)
    }
}

extension PLProductEditorCountFieldTableViewCell: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)

            if let intValue = Int(updatedText), intValue > 0, intValue < 100 {
                stepperView.value = Double(intValue)

                delegate?.countFieldTableViewCell(self, didChangeCount: intValue)

                return true
            } else if updatedText == "" {
                stepperView.value = Double(1)

                delegate?.countFieldTableViewCell(self, didChangeCount: 1)

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
