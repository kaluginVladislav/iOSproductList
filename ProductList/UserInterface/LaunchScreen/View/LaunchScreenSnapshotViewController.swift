//
//  LaunchScreenSnapshotViewController.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 23.10.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import UIKit

class LaunchScreenSnapshotViewController: UIViewController {

    @IBOutlet private weak var applicationReleaseStackView: UIStackView!
    @IBOutlet private weak var applicationReleaseTitleLabel: UILabel!
    @IBOutlet private weak var applicationReleaseInfoLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureApplicationReleaseLabel()
        configureLaunchTimer()
    }

    private func configureApplicationReleaseLabel() {
        if let releaseVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let releaseVersionNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
           let infoPath = Bundle.main.path(forResource: "Info", ofType: "plist"),
           let infoAttributes = try? FileManager.default.attributesOfItem(atPath: infoPath),
           let infoModificationDate = infoAttributes[.modificationDate] as? Date {

            let dateFormater = DateFormatter()
            dateFormater.dateFormat = "dd.MM.yyyy"

            let releaseVersionString = "\(releaseVersion).\(releaseVersionNumber)"
            let releaseVersionDateString = dateFormater.string(from: infoModificationDate)

            applicationReleaseTitleLabel.text = "launch.screen.release.title".localized
            applicationReleaseInfoLabel.text = "launch.screen.release.info".localized(releaseVersionString, releaseVersionDateString)
        } else {
            applicationReleaseStackView.isHidden = true
        }
    }

    private func configureLaunchTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] (timer) in
            guard let self = self else { return }

            self.reconfigureRootViewController()
        }
    }

    private func reconfigureRootViewController() {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!

        viewController.reconfigureToRootViewController(animated: true)

        Log.info("LaunchScreenSnapshotViewController did set root view controller with name: \(viewController.describingName)")
    }
}
