//
//  Toast.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 01.10.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import UIKit

/// The `Toast` struct of `ToastManager` toast object.
struct Toast {

    /// The position of toast in superview.
    enum Position {

        case top

        case bottom

    }

    let view: ToastView
    let superview: UIView
    let position: Toast.Position
    let deadline: TimeInterval?
    var timer: Timer?

}
