//
//  PLMoreAboutViewController.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 17.11.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import UIKit

class PLMoreAboutViewController: UIViewController {

    @IBOutlet private weak var applicationReleaseStackView: UIStackView!
    @IBOutlet private weak var applicationReleaseTitleLabel: UILabel!
    @IBOutlet private weak var applicationReleaseInfoLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureApplicationReleaseLabel()
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
}
