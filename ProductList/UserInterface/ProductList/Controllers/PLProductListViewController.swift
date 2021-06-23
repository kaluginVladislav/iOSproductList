//
//  PLProductListViewController.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 15.08.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import UIKit
import CoreData

class PLProductListViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var actionButton: UIButton!
    @IBOutlet private weak var editingToolbar: UIToolbar!

    @IBOutlet private var basketBarButtonItem: UIBarButtonItem!
    @IBOutlet private var editingSelectAllBarButtonItem: UIBarButtonItem!
    @IBOutlet private var editingDeselectAllBarButtonItem: UIBarButtonItem!
    @IBOutlet private var editingDoneBarButtonItem: UIBarButtonItem!
    @IBOutlet private var editingToBasketBarButtonItem: UIBarButtonItem!
    @IBOutlet private var editingRemoveBarButtonItem: UIBarButtonItem!
    @IBOutlet private var moreBarButtonItem: UIBarButtonItem!
    @IBOutlet private var toolbarVisibleTopConstraint: NSLayoutConstraint!

    private let managedObjectContext = CoreDataManager.shared.productPackageManagedObjectContext
    private var packageFetchedResultsController: NSFetchedResultsController<PLProductPackageManagedObject>!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureFetchResultController()
        configureView()

        Log.debug("PLProductListViewController view did load")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "PLProductEditorViewController":
            if let navigationController = segue.destination as? UINavigationController,
                let productEditorViewController = navigationController.viewControllers[0] as? PLProductEditorViewController {

                productEditorViewController.delegate = self

                if let productInfo = sender as? [String: Any], let object = productInfo["object"] as? PLProductPackageManagedObject {
                    productEditorViewController.mode = .editing(objectId: object.objectID)
                    productEditorViewController.package = PLProductPackage(managedObject: object)
                }

                Log.debug("PLProductListViewController send to PLProductEditorViewController" )
            }
        case "PLProductBasketViewController":
            if let navigationController = segue.destination as? UINavigationController,
                let productBasketViewController = navigationController.viewControllers[0] as? PLProductBasketViewController {

                productBasketViewController.delegate = self

                Log.debug("PLProductListViewController send to PLProductBasketViewController" )
            }

        case "PLMoreViewController":
            if let navigationController = segue.destination as? UINavigationController,
               let moreViewController = navigationController.viewControllers[0] as? PLMoreViewController {

                moreViewController.didCancelDelegate = self

                Log.debug("PLProductListViewController send to PLMoreViewController")
            }

        default:
            break
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        tableView.setEditing(editing, animated: animated)

        if editing {
            actionButton.isHidden = true

            navigationItem.rightBarButtonItem = editingDoneBarButtonItem
            navigationItem.leftBarButtonItem = editingSelectAllBarButtonItem

            toolbarVisibleTopConstraint.isActive = false
        } else {
            actionButton.isHidden = false

            navigationItem.leftBarButtonItem = moreBarButtonItem
            navigationItem.rightBarButtonItem = basketBarButtonItem

            toolbarVisibleTopConstraint.isActive = true
        }

        if let indexPathsForSelectedRows = tableView.indexPathsForSelectedRows {
            for indexPath in indexPathsForSelectedRows {
                tableView.deselectRow(at: indexPath, animated: animated)
            }
        }

        updateSelectedObjects()
    }

    private func configureView() {
        updateSelectedObjects()

        actionButton.layer.cornerRadius = actionButton.bounds.height / 2

        navigationItem.rightBarButtonItem = basketBarButtonItem
        navigationItem.leftBarButtonItem = moreBarButtonItem

        editingDoneBarButtonItem.title = "product.list.editing.navbar.done".localized
        editingSelectAllBarButtonItem.title = "product.list.editing.navbar.select.all".localized
        editingDeselectAllBarButtonItem.title = "product.list.editing.navbar.deselect.all".localized
        editingToBasketBarButtonItem.title = "product.list.editing.toolbar.to.basket".localized
        editingRemoveBarButtonItem.title = "product.list.editing.toolbar.delete".localized

        Log.debug("PLProductListViewController did configure view")
    }

    private func configureFetchResultController() {
        let fetchRequest: NSFetchRequest<PLProductPackageManagedObject> = PLProductPackageManagedObject.fetchRequest()
        let visibilityPredicare = NSPredicate(format: "visibility == %@", PLProductPackage.Visibility.list.rawValue)

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "index", ascending: false)]
        fetchRequest.predicate = visibilityPredicare

        packageFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        packageFetchedResultsController.delegate = self

        do {
            try packageFetchedResultsController.performFetch()

            updateFetchedObjectsCover()

            Log.debug("PLProductListViewController did configure fetch result controller")
        } catch let error {
            showCover(preset: .criticalError(error))

            Log.fault("PLProductListViewController packageFetchedResultsController did performFetch with error: \(error.localizedDescription)")
        }
    }

    private func updateFetchedObjectsCover() {
        if let fetchedObjects = packageFetchedResultsController.fetchedObjects {
            if fetchedObjects.isEmpty {
                showCover(preset: .empty, title: "product.list.cover.empty.title".localized, subtitle: "product.list.cover.empty.subtitle".localized)
                view.bringSubviewToFront(actionButton)
                view.bringSubviewToFront(editingToolbar)

                editingSelectAllBarButtonItem.isEnabled = false
                editingDeselectAllBarButtonItem.isEnabled = false
                editingToBasketBarButtonItem.isEnabled = false
                editingRemoveBarButtonItem.isEnabled = false
            } else {
                hideCover()

                editingSelectAllBarButtonItem.isEnabled = true
                editingDeselectAllBarButtonItem.isEnabled = true
                editingToBasketBarButtonItem.isEnabled = true
                editingRemoveBarButtonItem.isEnabled = true
            }
        } else {
            showCover(preset: .criticalError(nil))
        }

        if isEditing {
            updateSelectedObjects()
        }
    }

    private func updateSelectedObjects() {
        let numberOfSelectedRows = tableView.indexPathsForSelectedRows?.count ?? 0

        if isEditing, numberOfSelectedRows > 0 {
            title = "product.list.editing.selected.title".localized(numberOfSelectedRows)
        } else {
            title = "product.list.title".localized
        }

        if isEditing {
            let numberOfRows = tableView.numberOfRows(inSection: 0)

            if numberOfSelectedRows > 0, numberOfSelectedRows == numberOfRows {
                navigationItem.leftBarButtonItem = editingDeselectAllBarButtonItem
            } else {
                navigationItem.leftBarButtonItem = editingSelectAllBarButtonItem
            }
        }
    }

    private func deleteObjects(at indexPaths: [IndexPath]) {
        packageFetchedResultsController.delegate = nil

        var objects: [PLProductPackageManagedObject] = []

        for indexPath in indexPaths {
            let object = packageFetchedResultsController.object(at: indexPath)

            objects.append(object)
        }

        tableView.beginUpdates()

        do {
            managedObjectContext.delete(at: objects)

            try packageFetchedResultsController.performFetch()

            if let fetchedObjects = packageFetchedResultsController.fetchedObjects {
                for (index, object) in fetchedObjects.reversed().enumerated() {
                    object.index = index
                }
            }

            try managedObjectContext.safelySave()

            tableView.deleteRows(at: indexPaths, with: .fade)

            packageFetchedResultsController.delegate = self

            Log.debug("PLProductListViewController did delete objects \(objects), at \(indexPaths)")
        } catch let error {
            self.showToast(preset: .success, title: error.localizedDescription, position: .top)

            Log.debug("PLProductListViewController did failure delete objects with error: \(error.localizedDescription)")
        }

        tableView.endUpdates()

        updateFetchedObjectsCover()
    }

    private func moveObjects(to visibility: PLProductPackage.Visibility, at indexPaths: [IndexPath]) {
        packageFetchedResultsController.delegate = nil

        var objects: [PLProductPackageManagedObject] = []

        for indexPath in indexPaths {
            let object = packageFetchedResultsController.object(at: indexPath)

            object.index = managedObjectContext.count(of: visibility)
            object.visibility = visibility.rawValue

            objects.append(object)
        }

        tableView.beginUpdates()

        do {
            try packageFetchedResultsController.performFetch()

            if let fetchedObjects = packageFetchedResultsController.fetchedObjects {
                for (index, object) in fetchedObjects.reversed().enumerated() {
                    object.index = index
                }
            }

            try managedObjectContext.safelySave()

            tableView.deleteRows(at: indexPaths, with: .fade)

            packageFetchedResultsController.delegate = self

            Log.debug("PLProductListViewController did move to basket objects \(objects), at \(indexPaths)")
        } catch let error {
            self.showToast(preset: .success, title: error.localizedDescription, position: .top)

            Log.debug("PLProductListViewController did failure move to basket objects with error: \(error.localizedDescription)")
        }

        tableView.endUpdates()

        updateFetchedObjectsCover()
    }

    private func editObject(at indexPath: IndexPath) {
        let object = packageFetchedResultsController.object(at: indexPath)
        let productInfo: [String: Any] = ["object": object]

        performSegue(withIdentifier: "PLProductEditorViewController", sender: productInfo)

        Log.debug("PLEmojiPickerViewController did select object \(object), at \(indexPath)")
    }

    @IBAction func toBasketEditingActionHandler(_ sender: UIBarButtonItem) {
        if let indexPathsForSelectedRows = tableView.indexPathsForSelectedRows {
            moveObjects(to: .basket, at: indexPathsForSelectedRows)
        }
    }

    @IBAction func removeEditingActionHandler(_ sender: UIBarButtonItem) {
        if let indexPathsForSelectedRows = tableView.indexPathsForSelectedRows {
            deleteObjects(at: indexPathsForSelectedRows)
        }
    }

    @IBAction func selectAllEditingActionHandler(_ sender: UIBarButtonItem) {
        let numberOfRows = tableView.numberOfRows(inSection: 0)

        for row in 0..<numberOfRows {
            let indexPath = IndexPath(row: row, section: 0)

            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            updateSelectedObjects()
        }
    }

    @IBAction func deselectAllEditingActionHandler(_ sender: UIBarButtonItem) {
        let numberOfRows = tableView.numberOfRows(inSection: 0)

        for row in 0..<numberOfRows {
            let indexPath = IndexPath(row: row, section: 0)

            tableView.deselectRow(at: indexPath, animated: true)
            updateSelectedObjects()
        }
    }

    @IBAction func doneEditingActionHandler(_ sender: UIBarButtonItem) {
        setEditing(false, animated: true)

        packageFetchedResultsController.delegate = nil

        managedObjectContext.save { [weak self] (result) in
            guard let self = self else { return }

            self.packageFetchedResultsController.delegate = self
        }
    }
}

extension PLProductListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fetchedObjects = packageFetchedResultsController.fetchedObjects {
            return fetchedObjects.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PLProductListTableViewCell") as! PLProductListTableViewCell
        let package = PLProductPackage(managedObject: packageFetchedResultsController.object(at: indexPath))

        cell.setContent(package)
        print(cell.frame.height, "!!!!Height", indexPath.row, package.index, package.product.emoji, package.product.name, package.volume?.count ?? "nil", package.volume?.unit ?? "nil")
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditing {
            updateSelectedObjects()
        } else {
            tableView.deselectRow(at: indexPath, animated: false)

            editObject(at: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if isEditing {
            updateSelectedObjects()
        }
    }

    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        if let objectId = configuration.identifier as? NSManagedObjectID,
            let object = packageFetchedResultsController.fetchedObjects?.first(where: { $0.objectID == objectId }),
            let indexPath = packageFetchedResultsController.indexPath(forObject: object),
            let cell = tableView.cellForRow(at: indexPath) {
            let parameters = UIPreviewParameters()

            parameters.backgroundColor = cell.backgroundColor

            return UITargetedPreview(view: cell.contentView, parameters: parameters)
        } else {
            return nil
        }
    }
    ///Move cell method
//    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        if var objects = packageFetchedResultsController.fetchedObjects {
//            let object = objects[sourceIndexPath.row]
//            objects.remove(at: sourceIndexPath.row)
//            objects.insert(object, at: destinationIndexPath.row)
//
//            for (index, object) in objects.reversed().enumerated() {
//                object.index = index
//            }
//        }
//    }

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard !isEditing else { return nil }

        let objectId = packageFetchedResultsController.object(at: indexPath).objectID

        let configuration = UIContextMenuConfiguration(identifier: objectId, previewProvider: nil) { actions -> UIMenu? in
            let editAction = UIAction(title: "product.list.context.menu.edit".localized, image: nil, identifier: nil) { [weak self] action in
                guard let self = self else { return }

                self.editObject(at: indexPath)
            }

            let selectAction = UIAction(title: "product.list.context.menu.select".localized, image: nil, identifier: nil) { [weak self] action in
                guard let self = self else { return }

                self.setEditing(true, animated: true)
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
                self.updateSelectedObjects()
            }

            let moveAction = UIAction(title: "product.list.context.menu.move".localized, image: nil, identifier: nil) { [weak self] action in
                guard let self = self else { return }

                self.setEditing(true, animated: true)
            }

            let toBacketAction = UIAction(title: "product.list.context.menu.to.backet".localized, image: nil, identifier: nil) { [weak self] action in
                guard let self = self else { return }

                self.moveObjects(to: .basket, at: [indexPath])
            }

            let deleteAction = UIAction(title: "product.list.context.menu.delete".localized, image: UIImage(systemName: "trash.fill"), attributes: .destructive) { [weak self] action in
                guard let self = self else { return }

                self.deleteObjects(at: [indexPath])
            }

            return UIMenu(children: [editAction, selectAction, toBacketAction, deleteAction])
        }

        return configuration
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "product.list.table.view.trailing.swipe.action.delete.title".localized) { [weak self] (action, view, bool) in
            guard let self = self else { return }

            self.deleteObjects(at: [indexPath])
        }

        return UISwipeActionsConfiguration(actions: [delete])
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let basketAction = UIContextualAction(style: .destructive, title: "product.list.table.view.leading.swipe.action.basket.title".localized) { [weak self] (action, view, bool) in
            guard let self = self else { return }

            self.moveObjects(to: .basket, at: [indexPath])
        }

        basketAction.backgroundColor = .applicationTint

        return UISwipeActionsConfiguration(actions: [basketAction])
    }
}

extension PLProductListViewController: PLProductEditorViewControllerDelegate {

    func productEditorDidDone(_ productEditor: PLProductEditorViewController, withPackage package: PLProductPackage) {
        productEditor.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }

            switch productEditor.mode {
            case .default:
                self.managedObjectContext.createAndSave(with: package, completion: { result in
                    switch result {
                    case .success:
                        Log.debug("PLProductListViewController did create package \(package)")
                    case .failure(let error):
                        self.showToast(preset: .success, title: error.localizedDescription, position: .top)

                        Log.debug("PLProductListViewController did failure create package \(package) with error: \(error)")
                    }
                })
            case .editing(let objectId):
                self.managedObjectContext.updateAndSave(with: package, at: objectId, completion: { result in
                    switch result {
                    case .success:
                        Log.debug("PLProductListViewController did update package \(package)")
                    case .failure(let error):
                        self.showToast(preset: .success, title: error.localizedDescription, position: .top)

                        Log.debug("PLProductListViewController did failure update package \(package) with error: \(error)")
                    }
                })
            }
        }

        Log.debug("PLProductListViewController did done button push")
    }
}

extension PLProductListViewController: PLProductBasketViewControllerDelegate {

    func productBasketDidCancel(_ productBasket: PLProductBasketViewController) {
        productBasket.dismiss(animated: true, completion: nil)
    }
}

extension PLProductListViewController: PLMoreViewControllerDelegate {
    func moreDidCancel(_ moreController: PLMoreViewController) {
        moreController.dismiss(animated: true, completion: nil)
    }
}

extension PLProductListViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let newIndexPath = newIndexPath {
                tableView.reloadRows(at: [newIndexPath], with: .fade)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                tableView.moveRow(at: indexPath, to: newIndexPath)
            }
        @unknown default:
            break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()

        updateFetchedObjectsCover()
    }
}
