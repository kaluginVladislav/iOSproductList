//
//  ToastManager+PLToastPreset.swift
//  ProductList
//
//  Created by Spitsin Sergey on 02.10.2020.
//

import UIKit

extension ToastManager {

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
    @discardableResult func show(preset: PLToastPreset, title: String, image: UIImage? = nil, backgroundColor: UIColor? = nil, tintColor: UIColor? = nil, position: Toast.Position, deadline: TimeInterval? = nil, action: ((PLToastView) -> Void)? = nil, completion: ((Toast) -> Void)? = nil) -> Toast? {
        if let lastPresentedWindow = ToastManager.lastPresentedWindow {
            return show(preset: preset, title: title, image: image, backgroundColor: backgroundColor, tintColor: tintColor, superview: lastPresentedWindow, position: position, deadline: deadline, action: action, completion: completion)
        } else {
            return nil
        }
    }

    ///     Showing view in the form of toasts above current view controller.
    ///
    ///     - parameters:
    ///        - preset: The toast preset.
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
    @discardableResult func show(preset: PLToastPreset, title: String, image: UIImage? = nil, backgroundColor: UIColor? = nil, tintColor: UIColor? = nil, superview: UIView, position: Toast.Position, deadline: TimeInterval? = nil, action: ((PLToastView) -> Void)? = nil, completion: ((Toast) -> Void)? = nil) -> Toast {
        let presetDeadline: TimeInterval = 8
        let presetImage: UIImage
        let presetBackgroundColor: UIColor
        let presetTintColor: UIColor

        switch preset {
        case .info:
            presetImage = UIImage(systemName: "info.circle.fill")!
            presetBackgroundColor = UIColor(named: "Application Toast Info Background Color")!
            presetTintColor = UIColor(named: "Application Toast Tint Color")!
        case .warning:
            presetImage = UIImage(systemName: "exclamationmark.circle.fill")!
            presetBackgroundColor = UIColor(named: "Application Toast Warning Background Color")!
            presetTintColor = UIColor(named: "Application Toast Tint Color")!
        case .error:
            presetImage = UIImage(systemName: "xmark.circle.fill")!
            presetBackgroundColor = UIColor(named: "Application Toast Error Background Color")!
            presetTintColor = UIColor(named: "Application Toast Tint Color")!
        case .success:
            presetImage = UIImage(systemName: "checkmark.circle.fill")!
            presetBackgroundColor = UIColor(named: "Application Toast Success Background Color")!
            presetTintColor = UIColor(named: "Application Toast Tint Color")!
        }

        let toastView = PLToastView(title: title, image: image ?? presetImage, backgroundColor: backgroundColor ?? presetBackgroundColor, tintColor: tintColor ?? presetTintColor, action: action)
        return show(toastView: toastView, superview: superview, position: position, deadline: deadline ?? presetDeadline, completion: completion)
    }
}
