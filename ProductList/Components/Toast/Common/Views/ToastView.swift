//
//  ToastView.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 01.10.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import UIKit

protocol ToastViewTouchDelegate: AnyObject {

    func toastViewDidBeginTouch(_ toastView: ToastView)
    func toastViewDidCancelTouch(_ toastView: ToastView)
    func toastViewDidEndTouch(_ toastView: ToastView)

}

extension ToastViewTouchDelegate {

    func toastViewDidBeginTouch(_ toastView: ToastView) { }
    func toastViewDidCancelTouch(_ toastView: ToastView) { }
    func toastViewDidEndTouch(_ toastView: ToastView) { }

}

/// The `ToastManager` class provides foundation for custom view overriding.
class ToastView: UIView {

    /// The content toast view that used if view should have some insets.
    public var contentToastView: UIView? { return nil }

    /// The indicator that current view is showed above other toast.
    public var isCurrent: Bool = true

    /// The indicator that current view should transform when current focus set false.
    public var isStackTransformEnabled: Bool = false

    /// The indicator that current view is on move.
    public var isMoved: Bool = false

    /// The indicator that current view is bounced.
    public var isBounced: Bool = true

    /// The setting for uses a safe area.
    public var isRelativeToSafeArea: Bool = true

    /// The touch delegate for toast manager.
    internal weak var touchDelegate: ToastViewTouchDelegate?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        touchDelegate?.toastViewDidBeginTouch(self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        touchDelegate?.toastViewDidEndTouch(self)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        touchDelegate?.toastViewDidCancelTouch(self)
    }
}
