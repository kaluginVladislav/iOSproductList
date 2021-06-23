//
//  PLMoreViewController.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 16.11.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import UIKit
import MessageUI

protocol PLMoreViewControllerDelegate: AnyObject {
    func moreDidCancel(_ moreController: PLMoreViewController)
}

extension PLMoreViewControllerDelegate {
    func moreDidCancel(_ moreController: PLMoreViewController) {
        moreController.dismiss(animated: true)
    }
}

class PLMoreViewController: UIViewController {

    public weak var didCancelDelegate: PLMoreViewControllerDelegate?
    weak var delegate: MFMailComposeViewControllerDelegate?
    let to: String = "incoming+kaluginvladislav-productlist-ios-20541956-issue-@incoming.gitlab.com"

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "more.title".localized
    }

    func openMailApp() {
        let composer = MFMailComposeViewController()

        if MFMailComposeViewController.canSendMail() {
            composer.mailComposeDelegate = self
            composer.setToRecipients([to])
            composer.setSubject("To support")
            if let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
                composer.setMessageBody("\(appVersion) Hello, ", isHTML: false)
            } else {
                composer.setMessageBody("Version Error: Hello, ", isHTML: false)
            }

            present(composer, animated: true, completion: nil)
        }
    }

    @IBAction func cancelButtonHandler(_ sender: UIBarButtonItem) {
        didCancelDelegate?.moreDidCancel(self)
        print("Cancel button push !!!!")
    }


}

extension PLMoreViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0, indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PLMoreTableViewCell") as! PLMoreTableViewCell
            cell.setContent("more.cell.feedback.title".localized)
            return cell
        } else if indexPath.section == 0, indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PLMoreTableViewCell") as! PLMoreTableViewCell
            cell.setContent("more.cell.about.application.title".localized)
            return cell
        } else {
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0 :
            if MFMailComposeViewController.canSendMail() {
                openMailApp()
            } else {
                showToast(preset: .warning, title: "more.toast.mail.service.error".localized, position: .bottom)
                print("Mail services are not available")
                return
            }
        case 1:
            performSegue(withIdentifier: "PLMoreAboutViewController", sender: nil)
        default:
            break
        }
    }
}

extension PLMoreViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
