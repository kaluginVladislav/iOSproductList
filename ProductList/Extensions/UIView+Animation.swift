//
//  UIView+Animation.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 20.09.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import UIKit

extension UIView {

    func animateWithShake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.5
        animation.values = [-8.0, 8.0, -8.0, 8.0, -4.0, 4.0, -2.0, 2.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}
