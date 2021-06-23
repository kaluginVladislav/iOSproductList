//
//  UIViewController+Root.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 24.10.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import UIKit

extension UIViewController {

    func reconfigureToRootViewController(animated: Bool, completion: ((Bool) -> Void)? = nil) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }

        if animated, let snapshot = window.snapshotView(afterScreenUpdates: true) {
            view.addSubview(snapshot)

            window.rootViewController = self

            UIView.transition(with: window, duration: 0.25, options: .transitionCrossDissolve, animations: {
                snapshot.alpha = 0
            }, completion: { (finished) in
                snapshot.removeFromSuperview()
                completion?(finished)
            })
        } else {
            window.rootViewController = self
            completion?(true)
        }
    }
}
