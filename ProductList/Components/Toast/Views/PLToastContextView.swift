//
//  PLToastContextView.swift
//  ProductList
//
//  Created by Spitsin Sergey on 01.10.2020.
//

import UIKit

class PLToastContextView: UIControl {

    override var isHighlighted: Bool {
        didSet { subviews.forEach({ $0.alpha = isHighlighted ? 0.5 : 1 }) }
    }
}
