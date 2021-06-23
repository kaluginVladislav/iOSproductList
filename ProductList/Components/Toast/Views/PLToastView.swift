//
//  PLToastView.swift
//  ProductList
//
//  Created by Spitsin Sergey on 01.10.2020.
//

import UIKit

class PLToastView: ToastView {

    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var contextView: PLToastContextView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!

    private var contextViewTapGestureRecognizerHandler: ((PLToastView) -> Void)?

    private var storedBackgroundColor: UIColor?
    private var storedTintColor: UIColor?

    public var formerBackgroundColor: UIColor? = UIColor(named: "Application Toast Former Background Color")
    public var formerTintColor: UIColor? = UIColor(named: "Application Toast Former Tint Color")

    public var title: String? {
        get {
            return titleLabel.text
        }

        set {
            titleLabel.text = newValue
        }
    }

    public var image: UIImage? {
        get {
            return imageView.image
        }

        set {
            imageView.image = newValue
            imageView.isHidden = newValue == nil
        }
    }

    override var backgroundColor: UIColor? {
        get {
            return contextView.backgroundColor
        }

        set {
            contextView.backgroundColor = newValue
        }
    }

    override var tintColor: UIColor! {
        get {
            contextView.tintColor
        }

        set {
            contextView.tintColor = newValue
            titleLabel.textColor = newValue
            imageView.tintColor = newValue
        }
    }

    override var isCurrent: Bool {
        didSet {
            if isCurrent {
                titleLabel.numberOfLines = 0

                UIView.animate(withDuration: ToastManager.shared.animateDuration) {
                    self.layoutIfNeeded()
                    self.backgroundColor = self.storedBackgroundColor
                    self.tintColor = self.storedTintColor
                }
            } else {
                titleLabel.numberOfLines = 2

                UIView.animate(withDuration: ToastManager.shared.animateDuration) {
                    self.layoutIfNeeded()
                    self.backgroundColor = self.formerBackgroundColor
                    self.tintColor = self.formerTintColor
                }
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        nibInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        nibInit()
    }

    init(title: String, image: UIImage?, backgroundColor: UIColor?, tintColor: UIColor?, action: ((PLToastView) -> Void)? = nil) {
        super.init(frame: .zero)

        nibInit()

        storedTintColor = tintColor
        storedBackgroundColor = backgroundColor

        self.title = title
        self.image = image
        self.backgroundColor = backgroundColor
        self.tintColor = tintColor

        contextViewTapGestureRecognizerHandler = action
    }

    private func nibInit() {
        Bundle.main.loadNibNamed("PLToastView", owner: self, options: nil)

        addSubview(contentView)

        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        configureView()
    }

    private func configureView() {
        isStackTransformEnabled = true

        contextView.layer.cornerRadius = 10
    }

    @IBAction private func contextViewTapGestureRecognizerHandler(_ sender: UITapGestureRecognizer) {
        contextViewTapGestureRecognizerHandler?(self)
    }
}
