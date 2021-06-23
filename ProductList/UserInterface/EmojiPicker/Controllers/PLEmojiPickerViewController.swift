//
//  PLEmojiPickerViewController.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 26.08.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import UIKit

protocol PLEmojiPickerViewControllerDelegate: AnyObject {

    func emojiPickerDidCancel(_ emojiPicker: PLEmojiPickerViewController)

    func emojiPicker(_ emojiPicker: PLEmojiPickerViewController, didSelect emoji: String)

}

extension PLEmojiPickerViewControllerDelegate {

    func emojiPickerDidCancel(_ emojiPicker: PLEmojiPickerViewController) {
        emojiPicker.dismiss(animated: true, completion: nil)
    }
}

class PLEmojiPickerViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionViewLayout: UICollectionViewFlowLayout!

    private let categories = PLEmojiCategory.allCases

    public weak var delegate: PLEmojiPickerViewControllerDelegate?

    public var selectedEmoji: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()

        Log.debug("PLEmojiPickerViewController view did load")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        layoutCollectionView()
    }

    private func layoutCollectionView() {
        collectionView.contentInset.left = view.directionalLayoutMargins.leading
        collectionView.contentInset.right = view.directionalLayoutMargins.trailing

        let sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)

        collectionViewLayout.sectionInset = sectionInset
        collectionViewLayout.invalidateLayout()

        Log.debug("PLEmojiPickerViewController view did layout collection view")
    }

    private func configureView() {
        collectionView.performBatchUpdates(nil) { [weak self] (finished) in
            guard let self = self else { return }

            self.configureDefaultSelection()
            self.configureCategoryTitle()

            Log.debug("PLEmojiPickerViewController did configure view")
        }
    }

    private func configureDefaultSelection() {
        if let selectedEmoji = selectedEmoji {
            for (section, category) in categories.enumerated() {
                if let item = category.emojies.firstIndex(where: { $0 == selectedEmoji }) {
                    let indexPath = IndexPath(item: item, section: section)

                    collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
                    collectionView.layoutIfNeeded()

                    Log.debug("PLEmojiPickerViewController did select default item at \(indexPath)")

                    return
                }
            }
        }
    }

    private func configureCategoryTitle() {
        if let indexPath = collectionView.indexPathsForVisibleItems.sorted(by: { $0 < $1 }).first {
            let categoryTitle = categories[indexPath.section].name

            if title != categoryTitle {
                title = categoryTitle

                Log.debug("PLEmojiPickerViewController did set category title \"\(categoryTitle)\" at \(indexPath)")
            }
        }
    }

    @IBAction private func cancelButtonAction(_ sender: UIBarButtonItem) {
        delegate?.emojiPickerDidCancel(self)

        Log.debug("PLEmojiPickerViewController did cancel button push")
    }
}

extension PLEmojiPickerViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        configureCategoryTitle()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories[section].emojies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PLEmojiPickerCollectionViewCell", for: indexPath) as! PLEmojiPickerCollectionViewCell
        let emoji = categories[indexPath.section].emojies[indexPath.item]

        cell.setContent(emoji)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let collectionViewLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }

        let columnsCount: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 8 : 5
        let contentInsetsLenght = collectionView.contentInset.left + collectionView.contentInset.right
        let sectionInsetsLength = collectionViewLayout.sectionInset.left + collectionViewLayout.sectionInset.right
        let lineSpacingLenght = collectionViewLayout.minimumLineSpacing * (columnsCount - 1)
        let contentLenght = collectionView.frame.width - sectionInsetsLength - contentInsetsLenght - lineSpacingLenght
        let sideLenght: CGFloat = (contentLenght / columnsCount).rounded(.down)

        return CGSize(width: sideLenght, height: sideLenght)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let emoji = categories[indexPath.section].emojies[indexPath.item]

        delegate?.emojiPicker(self, didSelect: emoji)

        Log.debug("PLEmojiPickerViewController did select emoji \(emoji), at \(indexPath)")

        return false
    }
}
