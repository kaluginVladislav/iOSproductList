//
//  UIView+PLToastView.swift
//  ProductList
//
//  Created by Spitsin Sergey on 01.10.2020.
//

import UIKit

extension UIView {

    ///     Showing view in the form of toasts above current view.
    ///
    ///     - parameters:
    ///        - title: The toast title.
    ///        - image: The toast right icon image.
    ///        - backgroundColor: The toast context background color.
    ///        - tintColor: The toast tint color.
    ///        - position: The position of toast on superview.
    ///        - deadline: The time period when the toast should be hidden.
    ///        - completion: A block object to be executed when the toast showing animation sequence ends.
    ///
    ///     - returns: Toast object.
    ///
    @discardableResult func showToast(title: String, image: UIImage?, backgroundColor: UIColor?, tintColor: UIColor?, position: Toast.Position, deadline: TimeInterval? = nil, action: ((PLToastView) -> Void)? = nil, completion: ((Toast) -> Void)? = nil) -> Toast {
        return ToastManager.shared.show(title: title, image: image, backgroundColor: backgroundColor, tintColor: tintColor, superview: self, position: position, deadline: deadline, action: action, completion: completion)
    }
}
