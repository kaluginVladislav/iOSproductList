//
//  UIView+Toast.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 01.10.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import UIKit

extension UIView {

    ///     Showing view in the form of toasts above current view.
    ///
    ///     - parameters:
    ///        - toastView: The view to be shown as the toast.
    ///        - position: The position of toast on superview.
    ///        - deadline: The time period when the toast should be hidden.
    ///        - completion: A block object to be executed when the toast showing animation sequence ends.
    ///
    ///     - returns: Toast object.
    ///
    @discardableResult func showToast(toastView: ToastView, position: Toast.Position, deadline: TimeInterval? = nil, completion: ((Toast) -> Void)? = nil) -> Toast {
        return ToastManager.shared.show(toastView: toastView, superview: self, position: position, deadline: deadline, completion: completion)
    }

    ///     Hides view in the form of toasts.
    ///
    ///     - parameters:
    ///        - toast: The toast object with view showed as the toast.
    ///        - completion: A block object to be executed when the toast hidding animation sequence ends.
    ///
    func hideToast(toast: Toast, completion: (() -> Void)? = nil) {
        ToastManager.shared.hide(toastView: toast.view, completion: completion)
    }

    ///     Hides view in the form of toasts.
    ///
    ///     - parameters:
    ///        - view: The view showed as the toast.
    ///        - completion: A block object to be executed when the toast hidding animation sequence ends.
    ///
    func hideToast(toastView: ToastView, completion: (() -> Void)? = nil) {
        ToastManager.shared.hide(toastView: toastView, completion: completion)
    }

    ///     Hides first showed view in the form of toasts.
    ///
    ///     - parameters:
    ///        - completion: A block object to be executed when the toast hidding animation sequence ends.
    ///
    func hideFirstToast(completion: (() -> Void)? = nil) {
        ToastManager.shared.hideFirstToast(completion: completion)
    }

    ///     Hides last showed view in the form of toasts.
    ///
    ///     - parameters:
    ///        - completion: A block object to be executed when the toast hidding animation sequence ends.
    ///
    func hideLastToast(completion: (() -> Void)? = nil) {
        ToastManager.shared.hideLastToast(completion: completion)
    }
}
