//
//  CustomView.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 28.01.2021.
//  Copyright © 2021 Vladislav Kalugin. All rights reserved.
//

import UIKit
import CoreData

protocol PLProducteditorResultCollectionViewDelegate: AnyObject {
    func productEditorCVCellDelete(_ productEditorResultController: PLProducteditorResultCollectionView, at indexPath: IndexPath)

    func productEditorCVCellChoose(_ productEditorResultController: PLProducteditorResultCollectionView, at indexPath: IndexPath)
}

class PLProducteditorResultCollectionView: UIView {

    @IBOutlet weak var collectionView: UICollectionView!
    public var searchObjects: [PLProductManagedObject] = []

    public weak var delegate: PLProducteditorResultCollectionViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        configuration()
    }

    private func configuration() {
        collectionView.register(UINib(nibName: "PLProductEditorResultCVCell", bundle: nil), forCellWithReuseIdentifier: "PLProductEditorResultCVCell")
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.collectionViewLayout = createLayout()
    }

    private func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(44),heightDimension: .absolute(50))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(44),heightDimension: .absolute(50))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 8
            section.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: self.layoutMargins.left, bottom: 3, trailing: self.layoutMargins.right)

            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}

extension PLProducteditorResultCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchObjects.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PLProductEditorResultCVCell", for: indexPath) as! PLProductEditorResultCVCell
        let product = PLProduct(managedObject: searchObjects[indexPath.row])
        cell.setContent(product)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.productEditorCVCellChoose(self, at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

        let product = PLProduct(managedObject: searchObjects[indexPath.row])
        let objectId = searchObjects[indexPath.row].objectID
        let configuration = UIContextMenuConfiguration(identifier: objectId, previewProvider: nil) { actions -> UIMenu? in
            let deleteAction = UIAction(title: "product.editor.context.menu.delete".localized, image: UIImage(systemName: "trash.fill"), attributes: .destructive) { [weak self] action in
                guard let self = self else { return }
                self.delegate?.productEditorCVCellDelete(self, at: indexPath)
            }

            let chooseAction = UIAction(title: "product.editor.context.menu.choose".localized, image: nil, identifier: nil) { [weak self] action in
                guard let self = self else { return }
                self.delegate?.productEditorCVCellChoose(self, at: indexPath)

            }

            return UIMenu(children: [chooseAction, deleteAction])
        }

        return configuration
    }
}

