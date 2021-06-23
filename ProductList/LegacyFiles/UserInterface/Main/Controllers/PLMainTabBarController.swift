//
//  PLMainTabBarController.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 15.08.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import UIKit

class PLMainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewControllers()

        Log.debug("PLMainTabBarController view did load")
    }

    private func configureViewControllers() {
        guard let viewControllers = viewControllers else { return }

        for case let navigationController as UINavigationController in viewControllers {
            switch navigationController.viewControllers.first {
            case is PLProductListViewController:
                navigationController.tabBarItem.title = "main.product.list.title".localized
            case is PLProductBasketViewController:
                navigationController.tabBarItem.title = "main.product.basket.title".localized
            default:
                break
            }
        }

        Log.debug("PLMainTabBarController did configure view controllers")
    }
}
