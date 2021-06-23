//
//  ToastManager.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 01.10.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import UIKit

/// The `ToastManager` class provides showing view in the form of toasts.
final class ToastManager: NSObject {

    public private(set) var toasts: [Toast] = []

    public static var shared = ToastManager()

    public static var lastPresentedWindow: UIView? {
        return UIApplication.shared.windows.last
    }

    public var animateDuration: TimeInterval = 0.25
    public var prefersAutoInsets = true

    private override init() { }

    ///     Showing view in the form of toasts above root view controller.
    ///
    ///     - parameters:
    ///        - view: The view to be shown as the toast.
    ///        - deadline: The time period when the toast should be hidden.
    ///        - position: The position of toast on superview.
    ///        - completion: A block object to be executed when the toast showing animation sequence ends.
    ///
    ///     - returns: Toast object.
    ///
    @discardableResult public func show(toastView: ToastView, position: Toast.Position, deadline: TimeInterval? = nil, completion: ((Toast) -> Void)? = nil) -> Toast? {
        if let lastPresentedWindow = ToastManager.lastPresentedWindow {
            return show(toastView: toastView, superview: lastPresentedWindow, position: position, deadline: deadline, completion: completion)
        } else {
            return nil
        }
    }

    ///     Showing view in the form of toasts above superview.
    ///
    ///     - parameters:
    ///        - view: The view to be shown as the toast.
    ///        - superview: The view to be showing the toast.
    ///        - deadline: The time period when the toast should be hidden.
    ///        - position: The position of toast on superview.
    ///        - completion: A block object to be executed when the toast showing animation sequence ends.
    ///
    ///     - returns: Toast object.
    ///
    @discardableResult public func show(toastView view: ToastView, superview: UIView, position: Toast.Position, deadline: TimeInterval? = nil, completion: ((Toast) -> Void)? = nil) -> Toast {
        for (index, toast) in toasts.enumerated() where (toast.view.isStackTransformEnabled && toast.superview == superview && toast.position == position) {
            toast.view.isCurrent = false

            UIView.animate(withDuration: animateDuration, delay: 0, options: .curveEaseInOut, animations: {
                if self.toasts.count > 1, index != self.toasts.count - 1 {
                    toast.view.isHidden = true
                }

                toast.timer?.invalidate()

                switch toast.position {
                case .top:
                    var transform = CGAffineTransform.identity
                    transform = transform.translatedBy(x: 0, y: -10)

                    if view.isStackTransformEnabled {
                        let scale = (toast.view.frame.width - 20) / toast.view.frame.width
                        transform = transform.scaledBy(x: scale, y: scale)
                    }

                    toast.view.transform = transform
                case .bottom:
                    var transform = CGAffineTransform.identity
                    transform = transform.translatedBy(x: 0, y: 10)

                    if view.isStackTransformEnabled {
                        let scale = (toast.view.frame.width - 20) / toast.view.frame.width
                        transform = transform.scaledBy(x: scale, y: scale)
                    }

                    toast.view.transform = transform
                }
            })
        }

        superview.addSubview(view)

        setupConstraints(from: view, to: superview, position: position)

        view.touchDelegate = self
        view.preservesSuperviewLayoutMargins = true
        view.layoutIfNeeded()

        let gestureRecognize = UIPanGestureRecognizer(target: self, action: #selector(dragHandler))
        gestureRecognize.cancelsTouchesInView = false
        view.addGestureRecognizer(gestureRecognize)

        var timer: Timer?

        if let deadline = deadline {
            timer = Timer.scheduledTimer(timeInterval: animateDuration + deadline, target: self, selector: #selector(updateTimer(_:)), userInfo: nil, repeats: false)
        }

        let toast = Toast(view: view, superview: superview, position: position, deadline: deadline, timer: timer)

        toasts.append(toast)

        switch position {
        case .top:
            let inset = superview.safeAreaInsets.top + view.frame.height
            var transform = CGAffineTransform.identity
            transform = transform.translatedBy(x: 0, y: -inset)

            if view.isStackTransformEnabled {
                transform = transform.scaledBy(x: 1.1, y: 1.1)
            }

            view.transform = transform
        case .bottom:
            let inset = superview.safeAreaInsets.bottom + view.frame.height
            var transform = CGAffineTransform.identity
            transform = transform.translatedBy(x: 0, y: inset)

            if view.isStackTransformEnabled {
                transform = transform.scaledBy(x: 1.1, y: 1.1)
            }

            view.transform = transform
        }

        UIView.animate(withDuration: animateDuration, delay: 0, options: .curveEaseInOut, animations: {
            view.transform = .identity
        }, completion: { _ in
            completion?(toast)
        })

        return toast
    }

    ///     Hides view in the form of toasts.
    ///
    ///     - parameters:
    ///        - view: The view showed as the toast.
    ///        - completion: A block object to be executed when the toast hidding animation sequence ends.
    ///
    public func hide(toastView view: ToastView, completion: (() -> Void)? = nil) {
        guard let index = toasts.firstIndex(where: { $0.view == view }) else {
            return
        }

        let toast = toasts.remove(at: index)
        let superview = view.superview

        UIView.animate(withDuration: animateDuration, delay: 0, options: .curveEaseInOut, animations: {
            switch toast.position {
            case .top:
                let inset = view.superview!.safeAreaInsets.top + view.frame.height
                var transform = CGAffineTransform.identity
                transform = transform.translatedBy(x: 0, y: -inset)

                if view.isStackTransformEnabled {
                    transform = transform.scaledBy(x: 0.8, y: 0.8)
                }

                view.transform = transform
            case .bottom:
                let inset = view.superview!.safeAreaInsets.bottom + view.frame.height
                var transform = CGAffineTransform.identity
                transform = transform.translatedBy(x: 0, y: inset)

                if view.isStackTransformEnabled {
                    transform = transform.scaledBy(x: 0.8, y: 0.8)
                }

                view.transform = transform
            }

            view.alpha = 0.5
        }, completion: { _ in
            view.removeFromSuperview()

            completion?()
        })

        if let toast = toasts.last(where: { $0.view.isStackTransformEnabled && $0.superview == superview && $0.position == toast.position }) {
            toast.view.isCurrent = true

            var preToast: Toast? {
                return toasts.dropLast().last
            }

            if let deadline = toast.deadline, let index = toasts.firstIndex(where: { $0.view == toast.view }) {
                toasts[index].timer = Timer.scheduledTimer(timeInterval: animateDuration + deadline, target: self, selector: #selector(updateTimer(_:)), userInfo: nil, repeats: false)
            }

            UIView.animate(withDuration: animateDuration, delay: 0, options: .curveEaseInOut, animations: {
                preToast?.view.isHidden = false
                toast.view.transform = .identity
            })
        }
    }

    ///     Hides view in the form of toasts.
    ///
    ///     - parameters:
    ///        - toast: The toast object with view showed as the toast.
    ///        - completion: A block object to be executed when the toast hidding animation sequence ends.
    ///
    public func hideToast(_ toast: Toast, completion: (() -> Void)? = nil) {
        hide(toastView: toast.view, completion: completion)
    }

    ///     Hides first showed view in the form of toasts.
    ///
    ///     - parameters:
    ///        - completion: A block object to be executed when the toast hidding animation sequence ends.
    ///
    public func hideFirstToast(completion: (() -> Void)? = nil) {
        if let presentedToast = toasts.first {
            hide(toastView: presentedToast.view, completion: completion)
        }
    }

    ///     Hides last showed view in the form of toasts.
    ///
    ///     - parameters:
    ///        - completion: A block object to be executed when the toast hidding animation sequence ends.
    ///
    public func hideLastToast(completion: (() -> Void)? = nil) {
        if let presentedToast = toasts.last {
            hide(toastView: presentedToast.view, completion: completion)
        }
    }

    private func setupConstraints(from view: ToastView, to superview: UIView, position: Toast.Position) {
        var constraints: [NSLayoutConstraint] = []

        view.translatesAutoresizingMaskIntoConstraints = false

        switch position {
        case .top:
            if view.isRelativeToSafeArea {
                constraints += [
                    view.topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor),
                    view.leftAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leftAnchor),
                    view.rightAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.rightAnchor)
                ]
            } else {
                constraints += [
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.leftAnchor.constraint(equalTo: superview.leftAnchor),
                    view.rightAnchor.constraint(equalTo: superview.rightAnchor)
                ]
            }
        case .bottom:
            if view.isRelativeToSafeArea {
                constraints += [
                    view.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor),
                    view.leftAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leftAnchor),
                    view.rightAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.rightAnchor)
                ]
            } else {
                constraints += [
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                    view.leftAnchor.constraint(equalTo: superview.leftAnchor),
                    view.rightAnchor.constraint(equalTo: superview.rightAnchor)
                ]
            }
        }

        NSLayoutConstraint.activate(constraints)
    }

    @objc private func updateTimer(_ sender: Timer) {
        if let view = toasts.first(where: { $0.timer == sender })?.view {
            hide(toastView: view)
        }
        sender.invalidate()
    }

    @objc private func dragHandler(_ sender: UIPanGestureRecognizer) {
        guard let view = sender.view as? ToastView, let toast = toasts.first(where: { $0.view == view }) else { return }

        if let contentToastView = view.contentToastView, !toast.view.isMoved, !contentToastView.frame.contains(sender.location(in: contentToastView)) {
            return
        } else if sender.state == .began {
            toast.timer?.invalidate()
        }

        let translation = sender.translation(in: view)

        switch sender.state {
        case .began:
            toast.view.isMoved = true
        case .changed:
            switch toast.position {
            case .top:
                let transfrom = CGAffineTransform(translationX: 0, y: translation.y < 0 ? translation.y / 1.5 : translation.y / 3)

                if !view.isBounced, transfrom.ty > 0 {
                    view.transform = .identity
                    break
                }

                view.transform = transfrom
            case .bottom:
                let transform = CGAffineTransform(translationX: 0, y: translation.y > 0 ? translation.y / 1.5 : translation.y / 3)

                if !view.isBounced, transform.ty < 0 {
                    view.transform = .identity
                    break
                }

                view.transform = transform
            }
        case .ended:
            toast.view.isMoved = false
            switch toast.position {
            case .top:
                if translation.y < -view.frame.size.height / 2 {
                    hide(toastView: view)
                } else {
                    UIView.animate(withDuration: animateDuration) {
                        view.transform = .identity
                    }
                }
            case .bottom:
                if translation.y > view.frame.size.height / 2 {
                    hide(toastView: view)
                } else {
                    UIView.animate(withDuration: animateDuration) {
                        view.transform = .identity
                    }
                }
            }
        default:
            break
        }
    }
}


extension ToastManager: ToastViewTouchDelegate {

    func toastViewDidBeginTouch(_ toastView: ToastView) {
        guard let toast = toasts.first(where: { $0.view == toastView }) else { return }

        toast.timer?.invalidate()
    }
}
