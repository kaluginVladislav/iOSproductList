//
//  UIViewController+PLToastPreset.swift
//  ProductList
//
//  Created by Spitsin Sergey on 02.10.2020.
//

import UIKit

extension UIViewController {

    ///     Showing view in the form of toasts above current view controller.
    ///
    ///     - parameters:
    ///        - preset: The toast preset.
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
    @discardableResult func showToast(preset: PLToastPreset, title: String, image: UIImage? = nil, backgroundColor: UIColor? = nil, tintColor: UIColor? = nil, position: Toast.Position, deadline: TimeInterval? = nil, action: ((PLToastView) -> Void)? = nil, completion: ((Toast) -> Void)? = nil) -> Toast {
        var superview: UIView {
            if let navigationController = navigationController, navigationController.navigationBar.prefersLargeTitles, ToastManager.shared.prefersAutoInsets {
                return navigationController.view
            } else {
                return view
            }
        }

        return superview.showToast(preset: preset, title: title, image: image, backgroundColor: backgroundColor, tintColor: tintColor, position: position, deadline: deadline, action: action, completion: completion)
    }
}
