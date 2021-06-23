//
//  ToastManager+PLToastView.swift
//  ProductList
//
//  Created by Spitsin Sergey on 01.10.2020.
//

import UIKit

extension ToastManager {

    ///     Showing view in the form of toasts above current view controller.
    ///
    ///     - parameters:
    ///        - title: The toast title.
    ///        - image: The toast right icon image.
    ///        - backgroundColor: The toast context  background color.
    ///        - tintColor: The toast tint color.
    ///        - position: The position of toast on superview.
    ///        - deadline: The time period when the toast should be hidden.
    ///        - completion: A block object to be executed when the toast showing animation sequence ends.
    ///
    ///     - returns: Toast object.
    ///
    @discardableResult func show(title: String, image: UIImage?, backgroundColor: UIColor?, tintColor: UIColor?, position: Toast.Position, deadline: TimeInterval? = nil, action: ((PLToastView) -> Void)? = nil, completion: ((Toast) -> Void)? = nil) -> Toast? {
        if let lastPresentedWindow = ToastManager.lastPresentedWindow {
            return show(title: title, image: image, backgroundColor: backgroundColor, tintColor: tintColor, superview: lastPresentedWindow, position: position, deadline: deadline, action: action, completion: completion)
        } else {
            return nil
        }
    }

    ///     Showing view in the form of toasts above current view controller.
    ///
    ///     - parameters:
    ///        - title: The toast title.
    ///        - image: The toast right icon image.
    ///        - backgroundColor: The toast context  background color.
    ///        - tintColor: The toast tint color.
    ///        - superview: The view to be showing the toast.
    ///        - position: The position of toast on superview.
    ///        - deadline: The time period when the toast should be hidden.
    ///        - completion: A block object to be executed when the toast showing animation sequence ends.
    ///
    ///     - returns: Toast object.
    ///
    @discardableResult func show(title: String, image: UIImage?, backgroundColor: UIColor?, tintColor: UIColor?, superview: UIView, position: Toast.Position, deadline: TimeInterval? = nil, action: ((PLToastView) -> Void)? = nil, completion: ((Toast) -> Void)? = nil) -> Toast {
        let toastView = PLToastView(title: title, image: image, backgroundColor: backgroundColor, tintColor: tintColor, action: action)
        return show(toastView: toastView, superview: superview, position: position, deadline: deadline, completion: completion)
    }
}
