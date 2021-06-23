//
//  PLProductEditorViewController.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 22.08.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import UIKit
import CoreData
import Foundation

protocol PLProductEditorViewControllerDelegate: AnyObject {

    func productEditorDidCancel(_ productEditor: PLProductEditorViewController)

    func productEditorDidDone(_ productEditor: PLProductEditorViewController, withPackage package: PLProductPackage)

}

extension PLProductEditorViewControllerDelegate {

    func productEditorDidCancel(_ productEditor: PLProductEditorViewController) {
        productEditor.dismiss(animated: true, completion: nil)
    }
}

class PLProductEditorViewController: UIViewController {

    enum Mode {

        case `default`

        case editing(objectId: NSManagedObjectID)

    }

    @IBOutlet private weak var doneButton: UIBarButtonItem!
    @IBOutlet private weak var tableView: UITableView!

    private let managedObjectContext = CoreDataManager.shared.productManagedObjectContext
    private var searchObjects: [PLProductManagedObject] = []
    private var searchTimer: Timer?

    public weak var delegate: PLProductEditorViewControllerDelegate?

    public lazy var package: PLProductPackage = {
        let product = PLProduct(emoji: "🛒", name: "", origin: "user")

        return PLProductPackage(index: 0, count: 1, creationDate: Date(), visibility: .list, product: product, volume: nil, note: nil)
    }()

    public var mode: Mode = .default

    private var customView: PLProducteditorResultCollectionView?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        customView?.delegate = self

        Log.debug("PLProductEditorViewController view did load")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.cellForRow(at: IndexPath(item: 0, section: 0))?.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "PLEmojiPickerViewController":
            if let navigationController = segue.destination as? UINavigationController,
                let avatarEditorViewController = navigationController.viewControllers.first as? PLEmojiPickerViewController {

                avatarEditorViewController.delegate = self
                avatarEditorViewController.selectedEmoji = package.product.emoji

                Log.debug("PLProductEditorViewController send to PLEmojiPickerViewController")
            }
        default:
            break
        }
    }

    private func configureView() {
        switch mode {
        case .default:
            title = "product.editor.add.title".localized
        case .editing:
            title = "product.editor.edit.title".localized

            updateSearchObjects(at: package.product.name)
        }

        doneButton.isEnabled = package.product.name.count > 0

        if let customView = Bundle.main.loadNibNamed("PLProducteditorResultCollectionView", owner: self, options: nil)?.first as? PLProducteditorResultCollectionView {
            self.customView = customView
        }

        Log.debug("PLProductEditorViewController did configure view")
    }

    private func searchObjects(at keyPath: String) -> [PLProductManagedObject] {
        let fetchRequest: NSFetchRequest<PLProductManagedObject> = PLProductManagedObject.fetchRequest()
        let resultPredicate = NSPredicate(format: "(name contains[cd] %@) AND (name != %@ OR emoji != %@)", argumentArray: [keyPath, keyPath, package.product.emoji])

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.predicate = resultPredicate
        fetchRequest.fetchLimit = 10

        do {
            let objects = try managedObjectContext.fetch(fetchRequest)

            Log.debug("PLProductEditorViewController did configure fetch result controller")

            return objects
        } catch let error {
            Log.fault("PLProductEditorViewController productFetchedResultsController did performFetch with error: \(error.localizedDescription)")

            return []
        }
    }

    private func updateSearchObjects(at keyPath: String) {
        let searchedObjects = searchObjects(at: keyPath)
        let differences = searchedObjects.difference(from: searchObjects)

        searchObjects = searchedObjects
        customView?.searchObjects = searchObjects

        customView?.collectionView.performBatchUpdates({
            for difference in differences {
                switch difference {
                case .insert(let offset, _, _):
                    let indexPath = IndexPath(row: offset, section: 0)
                    customView?.collectionView.insertItems(at: [indexPath])

                case .remove(let offset, _, _):
                    let indexPath = IndexPath(row: offset, section: 0)
                    customView?.collectionView.deleteItems(at: [indexPath])
                }
            }
        }, completion: nil)

        customView?.collectionView.reloadData()
    }

    private func updateSearchObjectsWithTimeInterval(at keyPath: String) {
        searchTimer?.invalidate()

        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { [weak self] (timer) in
            guard let self = self else { return }

            self.updateSearchObjects(at: keyPath)
        })
    }

    private func deleteObject(at indexPath: IndexPath, completion: ((Result<Void, Error>) -> Void)? = nil) {
        let object = searchObjects[indexPath.row]
        managedObjectContext.delete(at: object, completion: { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                self.searchObjects.remove(at: indexPath.row)
                self.customView?.searchObjects.remove(at: indexPath.row)
                self.customView?.collectionView.deleteItems(at: [indexPath])

                completion?(.success(()))

                Log.debug("PLProductEditorViewController did delete object \(object), at \(indexPath)")
            case .failure(let error):
                let error = error as NSError

                if error.code == 1570 {
                    self.showToast(preset: .error, title: "error.cocoa.delete.object.required.value.description".localized, position: .top)
                } else {
                    self.showToast(preset: .error, title: error.localizedDescription, position: .top)
                }

                completion?((.failure(error)))

                Log.fault("PLProductEditorViewController did failure delete object with error: \(error.localizedDescription)")
            }
        })
    }

    private func chooseProduct(at indexPath: IndexPath) {
        let product = PLProduct(managedObject: searchObjects[indexPath.row])

        package.product = product

        let indexPathForCell: IndexPath = IndexPath(row: 0, section: 0)

        if let cell = tableView.cellForRow(at: indexPathForCell) as? PLProductEditorNameFieldTableViewCell {
            UIView.transition(with: cell, duration: 0.3, options: .transitionCrossDissolve, animations: {
                cell.setContent(product.emoji, product.name)
            })
        }

        customView?.collectionView.reloadItems(at: [indexPath])
        updateSearchObjects(at: product.name)

        Log.debug("PLProductEditorViewController did choose product \(product), at \(indexPath)")
    }

    @IBAction private func cancelAction(_ sender: UIBarButtonItem) {
        delegate?.productEditorDidCancel(self)

        Log.debug("PLProductEditorViewController did cancel button push")
    }

    @IBAction private func doneAction(_ sender: UIBarButtonItem) {
        delegate?.productEditorDidDone(self, withPackage: package)

        Log.debug("PLProductEditorViewController did done button push")
    }

}

extension PLProductEditorViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0, indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PLProductEditorNameFieldTableViewCell") as! PLProductEditorNameFieldTableViewCell

            cell.dataSource = self
            cell.delegate = self
            cell.setHints()
            customView?.searchObjects = searchObjects
            customView?.collectionView.reloadData()
            cell.setContent(package.product.emoji, package.product.name)

            return cell
        } else if indexPath.section == 1, indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PLProductEditorCountFieldTableViewCell") as! PLProductEditorCountFieldTableViewCell

            cell.delegate = self
            cell.setContent(package.count)

            return cell
        } else if indexPath.section == 1, indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PLProductEditorVolumeFieldTableViewCell") as! PLProductEditorVolumeFieldTableViewCell

            cell.delegate = self
            cell.setContent(package.volume)

            return cell
        } else if indexPath.section == 1, indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PLProductEditorNoteFieldTableViewCell") as! PLProductEditorNoteFieldTableViewCell

            cell.delegate = self
            cell.setContent(package.note)

            return cell
        } else {
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
}

extension PLProductEditorViewController: PLEmojiPickerViewControllerDelegate {

    func emojiPicker(_ emojiPicker: PLEmojiPickerViewController, didSelect emoji: String) {
        emojiPicker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }

            self.package.product.emoji = emoji
            self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)

            self.updateSearchObjects(at: self.package.product.name)
            self.tableView.cellForRow(at: IndexPath(item: 0, section: 0))?.becomeFirstResponder()

            Log.debug("PLProductEditorViewController did set emoji \(emoji)")
        }
    }
}

extension PLProductEditorViewController: PLProductEditorNameTableViewCellDelegate {

    func nameFieldTableViewCell(_ nameFieldTableViewCell: PLProductEditorNameFieldTableViewCell, didChangeName name: String) {
        package.product.name = name
        doneButton.isEnabled = name.count > 0
        updateSearchObjectsWithTimeInterval(at: name)

        Log.debug("PLProductEditorViewController did change name \(name)")
    }

    func avatarViewTableViewCellDidSelectAvatar(_ avatarViewTableViewCell: PLProductEditorNameFieldTableViewCell) {
        performSegue(withIdentifier: "PLEmojiPickerViewController", sender: nil)

        Log.debug("PLProductEditorViewController did select avatar control")
    }
}

extension PLProductEditorViewController: PLProductEditorCountTableViewCellDelegate {

    func countFieldTableViewCell(_ countFieldTableViewCell: PLProductEditorCountFieldTableViewCell, didChangeCount count: Int) {
        package.count = count

        Log.debug("PLProductEditorViewController did change count \(count)")
    }
}

extension PLProductEditorViewController: PLProductEditorVolumeFieldTableViewCellDelegate {

    func volumeFieldTableViewCell(_ volumeFieldTableViewCell: PLProductEditorVolumeFieldTableViewCell, didChangeVolume volume: PLProductPackage.Volume?) {
        if let volume = volume {
            package.volume = volume
            print(package.volume, "!!!!3333")

            Log.debug("PLProductEditorViewController did change volume \(volume)")
        } else {
            print(package.volume, "!!!!!444")
            package.volume = nil
            print(package.volume, "!!!!!444")

            Log.debug("PLProductEditorViewController did clear volume")
        }
    }
}

extension PLProductEditorViewController: PLProductEditorNoteFieldTableViewCellDelegate {

    func noteFieldTableViewCell(_ noteFieldTableViewCell: PLProductEditorNoteFieldTableViewCell, didChangeNote note: String?) {
        if let note = note {
            package.note = note

            Log.debug("PLProductEditorViewController did change note \(note)")
        } else {
            package.note = nil

            Log.debug("PLProductEditorViewController did clear note")
        }

        tableView.performBatchUpdates(nil)
    }
}

extension PLProductEditorViewController: PLProductEditorNameFieldTableViewCellDataSource {

    func nameFieldTableViewCellSearchResultView(_ nameFieldTableViewCell: PLProductEditorNameFieldTableViewCell) -> PLProducteditorResultCollectionView? {
        return customView
    }
}

extension PLProductEditorViewController: PLProducteditorResultCollectionViewDelegate {
    func productEditorCVCellDelete(_ productEditorResultController: PLProducteditorResultCollectionView, at indexPath: IndexPath) {
        deleteObject(at: indexPath)
    }

    func productEditorCVCellChoose(_ productEditorResultController: PLProducteditorResultCollectionView, at indexPath: IndexPath) {
        chooseProduct(at: indexPath)
    }
}
