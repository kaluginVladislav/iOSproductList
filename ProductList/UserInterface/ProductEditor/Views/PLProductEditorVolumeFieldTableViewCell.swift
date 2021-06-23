//
//  PLProductEditorVolumeFieldTableViewCell.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 17.10.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import UIKit

protocol PLProductEditorVolumeFieldTableViewCellDelegate: AnyObject {

    func volumeFieldTableViewCell(_ volumeFieldTableViewCell: PLProductEditorVolumeFieldTableViewCell, didChangeVolume volume: PLProductPackage.Volume?)

}

class PLProductEditorVolumeFieldTableViewCell: UITableViewCell {

    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!

    public weak var delegate: PLProductEditorVolumeFieldTableViewCellDelegate?

    private let units: [PLProductPackage.Volume.Unit] = [.gr, .kg, .ml, .l]

    override func awakeFromNib() {
        super.awakeFromNib()

        configureView()
    }

    private func configureView() {
        separatorInset.left = textField.frame.origin.x
        textField.placeholder = "product.editor.volume.text.field.placeholder".localized
        segmentedControl.removeAllSegments()

        for unit in units {
            switch unit {
            case .gr:
                segmentedControl.insertSegment(withTitle: "volume.unit.gr".localized, at: segmentedControl.numberOfSegments, animated: false)
            case .kg:
                segmentedControl.insertSegment(withTitle: "volume.unit.kg".localized, at: segmentedControl.numberOfSegments, animated: false)
            case .ml:
                segmentedControl.insertSegment(withTitle: "volume.unit.ml".localized, at: segmentedControl.numberOfSegments, animated: false)
            case .l:
                segmentedControl.insertSegment(withTitle: "volume.unit.l".localized, at: segmentedControl.numberOfSegments, animated: false)
            }
        }
    }

    public func setContent(_ volume: PLProductPackage.Volume?) {
        if let volume = volume, volume.count != 0 {
            print(volume.count, "!!!!222")
            textField.text = String(volume.count)

            if let firstIndex = units.firstIndex(of: volume.unit) {
                segmentedControl.selectedSegmentIndex = firstIndex
            }

            Log.debug("PLProductEditorVolumeFieldTableViewCell did set content \(volume)")
        } else {
            textField.text = nil
            segmentedControl.selectedSegmentIndex = 0

            Log.debug("PLProductEditorVolumeFieldTableViewCell did set empty content")
        }
    }

    @IBAction func tapOnSegmentAction(_ sender: UISegmentedControl) {
        if let text = textField.text, let intValue = Int(text), intValue > 0, intValue < 10000 {
            let volume = PLProductPackage.Volume(unit: units[segmentedControl.selectedSegmentIndex], count: intValue)

            delegate?.volumeFieldTableViewCell(self, didChangeVolume: volume)
        } else if textField.text == nil {
            let volume = PLProductPackage.Volume(unit: .kg, count: 0)
            delegate?.volumeFieldTableViewCell(self, didChangeVolume: volume)
        }
    }
}

extension PLProductEditorVolumeFieldTableViewCell: UITextFieldDelegate {

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = nil
        let volume = PLProductPackage.Volume(unit: .kg, count: 0)
        delegate?.volumeFieldTableViewCell(self, didChangeVolume: volume)

        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)

            if let intValue = Int(updatedText), intValue > 0, intValue < 10000 {
                let volume = PLProductPackage.Volume(unit: units[segmentedControl.selectedSegmentIndex], count: intValue)

                delegate?.volumeFieldTableViewCell(self, didChangeVolume: volume)

                return true
            } else if updatedText == "" {
                let volume = PLProductPackage.Volume(unit: .kg, count: 0)
                delegate?.volumeFieldTableViewCell(self, didChangeVolume: volume)
                self.textField.text = nil

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
