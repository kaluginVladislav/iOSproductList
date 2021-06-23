//
//  PLProductBasketViewController.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 15.08.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import UIKit
import CoreData

protocol PLProductBasketViewControllerDelegate: AnyObject {

    func productBasketDidCancel(_ productBasket: PLProductBasketViewController)

}

extension PLProductBasketViewControllerDelegate {

    func productBasketDidCancel(_ productBasket: PLProductBasketViewController) {
        productBasket.dismiss(animated: true, completion: nil)
    }
}

class PLProductBasketViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!

    private let managedObjectContext = CoreDataManager.shared.productPackageManagedObjectContext
    private var packageFetchedResultsController: NSFetchedResultsController<PLProductPackageManagedObject>!

    public weak var delegate: PLProductBasketViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureFetchResultController()

        Log.debug("PLProductBasketViewController view did load")
    }

    private func configureView() {
        title = "product.basket.title".localized

        Log.debug("PLProductBasketViewController did configure view")
    }

    private func configureFetchResultController() {
        let fetchRequest: NSFetchRequest<PLProductPackageManagedObject> = PLProductPackageManagedObject.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        let visibilityPredicate = NSPredicate(format: "visibility == %@", PLProductPackage.Visibility.basket.rawValue)
        fetchRequest.predicate = visibilityPredicate

        packageFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        packageFetchedResultsController.delegate = self

        do {
            try packageFetchedResultsController.performFetch()

            updateFetchedObjectsCover()

            Log.debug("PLProductBasketViewController did configure fetch result controller")
        } catch let error {
            showCover(preset: .criticalError(error))

            Log.fault("PLProductBasketViewController packageFetchedResultsController did performFetch with error: \(error.localizedDescription)")
        }
    }

    private func updateFetchedObjectsCover() {
        if let fetchedObjects = packageFetchedResultsController.fetchedObjects {
            if !fetchedObjects.isEmpty {
                hideCover()
            } else {
                showCover(preset: .empty, title: "product.basket.cover.empty.title".localized, subtitle: "product.basket.cover.empty.subtitle".localized)
            }
        } else {
            showCover(preset: .criticalError(nil))
        }
    }

    @IBAction private func deleteBusketActionButton(_ sender: UIBarButtonItem) {
        if let packages = packageFetchedResultsController.fetchedObjects {
            managedObjectContext.delete(at: packages, completion: { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success:
                    self.showToast(preset: .success, title: "product.basket.toast.success.delete.objects".localized, position: .top)

                    Log.debug("PLProductBasketViewController did delete all objects")
                case .failure(let error):
                    self.showToast(preset: .error, title: error.localizedDescription, position: .top)

                    Log.fault("PLProductBasketViewController did delete basket with error: \(error.localizedDescription)")
                }
            })
        }
    }

    private func deleteObject(at indexPath: IndexPath) {
        let object = packageFetchedResultsController.object(at: indexPath)

        managedObjectContext.delete(at: object, completion: { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                Log.debug("PLProductBasketViewController did delete object \(object), at \(indexPath)")
            case .failure(let error):
                self.showToast(preset: .error, title: error.localizedDescription, position: .top)

                Log.fault("PLProductBasketViewController did delete object in basket with error: \(error.localizedDescription)")
            }
        })
    }

    private func moveObject(to visibility: PLProductPackage.Visibility, at indexPath: IndexPath) {
        let object = packageFetchedResultsController.object(at: indexPath)

        object.index = managedObjectContext.count(of: visibility)
        object.visibility = visibility.rawValue

        managedObjectContext.save(completion: { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                Log.debug("PLProductBasketViewController did move to lest object \(object), at \(indexPath)")
            case .failure(let error):
                self.showToast(preset: .error, title: error.localizedDescription, position: .top)

                Log.fault("PLProductBasketViewController did move object at basket to list with error: \(error.localizedDescription)")
            }
        })
    }

    @IBAction private func cancelActionHandler(_ sender: UIBarItem) {
        delegate?.productBasketDidCancel(self)
    }
}

extension PLProductBasketViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fetchedObjects = packageFetchedResultsController.fetchedObjects {
            return fetchedObjects.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PLProductBasketTableViewCell") as! PLProductBasketTableViewCell
        let package = PLProductPackage(managedObject: packageFetchedResultsController.object(at: indexPath))

        cell.setContent(package)

        return cell
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

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let objectId = packageFetchedResultsController.object(at: indexPath).objectID

        let configuration = UIContextMenuConfiguration(identifier: objectId, previewProvider: nil) { actions -> UIMenu? in

            let toListAction = UIAction(title: "product.basket.context.menu.to.list".localized, image: nil, identifier: nil) { [weak self] action in
                guard let self = self else { return }

                self.moveObject(to: .list, at: indexPath)
            }

            let deleteAction = UIAction(title: "product.basket.context.menu.delete".localized, image: UIImage(systemName: "trash.fill"), attributes: .destructive) { [weak self] action in
                guard let self = self else { return }

                self.deleteObject(at: indexPath)
            }

            return UIMenu(children: [toListAction, deleteAction])
        }

        return configuration
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "product.basket.table.view.leading.swipe.action.delete.title".localized) { [weak self] (action, view, bool) in
            guard let self = self else { return }

            self.deleteObject(at: indexPath)
        }

        return UISwipeActionsConfiguration(actions: [delete])
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let basketAction = UIContextualAction(style: .destructive, title: "product.basket.table.view.trailing.swipe.action.list.title".localized) { [weak self] (action, view, bool) in
            guard let self = self else { return }

            self.moveObject(to: .list, at: indexPath)
        }

        basketAction.backgroundColor = .applicationTint

        return UISwipeActionsConfiguration(actions: [basketAction])
    }
}

extension PLProductBasketViewController: NSFetchedResultsControllerDelegate {

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
