//
//  PLCoverView.swift
//  ProductList
//
//  Created by Vladislav Kalugin on 16.10.2020.
//  Copyright © 2020 Vladislav Kalugin. All rights reserved.
//

import UIKit

class PLCoverView: UIView {

    enum ImageSize {

        case small

        case normal

        case big

        case custom(CGSize)

        public var width: CGFloat {
            return size.width
        }

        public var height: CGFloat {
            return size.height
        }

        public var size: CGSize {
            switch self {
            case .small:
                return CGSize(width: 60, height: 60)
            case .normal:
                return CGSize(width: 110, height: 110)
            case .big:
                return CGSize(width: 160, height: 160)
            case .custom(let size):
                return size
            }
        }

        init(size: CGSize) {
            switch size {
            case ImageSize.small.size:
                self = .small
            case ImageSize.normal.size:
                self = .normal
            case ImageSize.big.size:
                self = .big
            default:
                self = .custom(size)
            }
        }
    }

    enum ContentPosition {

        case top

        case lowerTop

        case upperCenter

        case center

        case lowerCenter

        case upperBottom

        case bottom

        case custom(CGFloat)

        public var multiplier: CGFloat {
            switch self {
            case .top:
                return 0
            case .lowerTop:
                return 0.5
            case .upperCenter:
                return 0.75
            case .center:
                return 1
            case .lowerCenter:
                return 1.25
            case .upperBottom:
                return 1.75
            case .bottom:
                return 2
            case .custom(let multiplier):
                return multiplier
            }
        }

        init(multiplier: CGFloat) {
            switch multiplier {
            case ContentPosition.top.multiplier:
                self = .top
            case ContentPosition.lowerTop.multiplier:
                self = .lowerTop
            case ContentPosition.upperCenter.multiplier:
                self = .upperCenter
            case ContentPosition.center.multiplier:
                self = .center
            case ContentPosition.lowerCenter.multiplier:
                self = .lowerCenter
            case ContentPosition.upperBottom.multiplier:
                self = .upperBottom
            case ContentPosition.bottom.multiplier:
                self = .bottom
            default:
                self = .custom(multiplier)
            }
        }
    }

    enum Action {

        class AutoRecall {

            public var timer: Timer

            init(timeInterval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Void) {
                self.timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: repeats, block: block)
            }
        }

        case autoRecall(AutoRecall)

        case custom(UIView)

    }

    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var contextScrollView: UIScrollView!
    @IBOutlet private weak var contextView: UIView!
    @IBOutlet private weak var contextStackView: UIStackView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var infoStackView: UIStackView!
    @IBOutlet private weak var infoTitleLabel: UILabel!
    @IBOutlet private weak var infoSubtitleLabel: UILabel!
    @IBOutlet private weak var infoFootnoteLabel: UILabel!
    @IBOutlet private weak var actionStackView: UIStackView!
    @IBOutlet private weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var contextStackViewCenterVerticalConstraint: NSLayoutConstraint!

    private var storedActions: [Action] = []

    public var title: String? {
        get {
            return infoTitleLabel.text
        }

        set {
            if let title = newValue {
                infoTitleLabel.text = title
                infoTitleLabel.isHidden = false
            } else {
                infoTitleLabel.text = nil
                infoTitleLabel.isHidden = true
            }
        }
    }

    public var subtitle: String? {
        get {
            return infoSubtitleLabel.text
        }

        set {
            if let subtitle = newValue {
                infoSubtitleLabel.text = subtitle
                infoSubtitleLabel.isHidden = false
            } else {
                infoSubtitleLabel.text = nil
                infoSubtitleLabel.isHidden = true
            }
        }
    }

    public var footnote: String? {
        get {
            return infoFootnoteLabel.text
        }

        set {
            if let footnote = newValue {
                infoFootnoteLabel.text = footnote
                infoFootnoteLabel.isHidden = false
            } else {
                infoFootnoteLabel.text = nil
                infoFootnoteLabel.isHidden = true
            }
        }
    }

    public var titleColor: UIColor? {
        get {
            return infoTitleLabel.textColor
        }

        set {
            if let titleColor = newValue {
                infoTitleLabel.textColor = titleColor
            } else {
                infoTitleLabel.textColor = nil
            }
        }
    }

    public var subtitleColor: UIColor? {
        get {
            return infoSubtitleLabel.textColor
        }

        set {
            if let subtitleColor = newValue {
                infoSubtitleLabel.textColor = subtitleColor
            } else {
                infoSubtitleLabel.textColor = nil
            }
        }
    }

    public var footnoteColor: UIColor? {
        get {
            return infoFootnoteLabel.textColor
        }

        set {
            if let footnoteColor = newValue {
                infoFootnoteLabel.textColor = footnoteColor
            } else {
                infoFootnoteLabel.textColor = nil
            }
        }
    }

    public var attributedTitle: NSAttributedString? {
        get {
            return infoTitleLabel.attributedText
        }

        set {
            if let attributedTitle = newValue {
                infoTitleLabel.attributedText = attributedTitle
                infoTitleLabel.isHidden = false
            } else {
                infoTitleLabel.attributedText = nil
                infoTitleLabel.isHidden = true
            }
        }
    }

    public var attributedSubtitle: NSAttributedString? {
        get {
            return infoSubtitleLabel.attributedText
        }

        set {
            if let attributedSubtitle = newValue {
                infoSubtitleLabel.attributedText = attributedSubtitle
                infoSubtitleLabel.isHidden = false
            } else {
                infoSubtitleLabel.attributedText = nil
                infoSubtitleLabel.isHidden = true
            }
        }
    }

    public var attributedFootnote: NSAttributedString? {
        get {
            return infoFootnoteLabel.attributedText
        }

        set {
            if let attributedFootnote = newValue {
                infoFootnoteLabel.attributedText = attributedFootnote
                infoFootnoteLabel.isHidden = false
            } else {
                infoFootnoteLabel.attributedText = nil
                infoFootnoteLabel.isHidden = true
            }
        }
    }

    public var image: UIImage? {
        get {
            return imageView.image
        }

        set {
            if let image = newValue {
                imageView.image = image
                imageView.isHidden = false
            } else {
                imageView.image = nil
                imageView.isHidden = true
            }
        }
    }

    public var refreshControl: UIRefreshControl? {
        get {
            return contextScrollView.refreshControl
        }

        set {
            contextScrollView.refreshControl = newValue
        }
    }

    public var actions: [Action] {
        get {
            return storedActions
        }

        set {
            for action in storedActions {
                switch action {
                case .custom(let action):
                    actionStackView.removeArrangedSubview(action)
                case .autoRecall(let action):
                    action.timer.invalidate()
                }
            }

            storedActions = newValue

            for action in newValue {
                switch action {
                case .custom(let action):
                    actionStackView.addArrangedSubview(action)
                default:
                    break
                }
            }

            if actionStackView.arrangedSubviews.count > 0 {
                actionStackView.isHidden = false
            } else {
                actionStackView.isHidden = true
            }
        }
    }

    public var imageSize: ImageSize {
        get {
            let width = imageViewWidthConstraint.constant
            let height = imageViewHeightConstraint.constant
            let size = CGSize(width: width, height: height)

            return ImageSize(size: size)
        }

        set {
            imageViewWidthConstraint.constant = newValue.width
            imageViewHeightConstraint.constant = newValue.height
        }
    }

    public var contentPosition: ContentPosition {
        get {
            let multiplier = contextStackViewCenterVerticalConstraint.multiplier

            return ContentPosition(multiplier: multiplier)
        }

        set {
            updateMultiplier(for: &contextStackViewCenterVerticalConstraint, multiplier: newValue.multiplier)
        }
    }

    public var actionAxis: NSLayoutConstraint.Axis {
        get {
            return actionStackView.axis
        }

        set {
            actionStackView.axis = newValue
        }
    }

    override var backgroundColor: UIColor? {
        get {
            return contextView.backgroundColor
        }

        set {
            contextScrollView.backgroundColor = newValue
            contextView.backgroundColor = newValue
        }
    }

    override var tintColor: UIColor! {
        get {
            contextView.tintColor
        }

        set {
            contextScrollView.tintColor = newValue
            contextView.tintColor = newValue
            contextStackView.tintColor = newValue
            imageView.tintColor = newValue
            infoStackView.tintColor = newValue
            infoTitleLabel.tintColor = newValue
            infoSubtitleLabel.tintColor = newValue
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

    init(title: String?, subtitle: String? = nil, footnote: String? = nil, image: UIImage? = nil, actions: [Action] = []) {
        super.init(frame: .zero)

        nibInit()

        self.title = title
        self.subtitle = subtitle
        self.footnote = footnote
        self.image = image
        self.actions = actions
    }

    init(attributedTitle: NSAttributedString?, attributedSubtitle: NSAttributedString? = nil, attributedFootnote: NSAttributedString? = nil, image: UIImage? = nil, actions: [Action] = []) {
        super.init(frame: .zero)

        nibInit()

        self.attributedTitle = attributedTitle
        self.attributedSubtitle = attributedSubtitle
        self.attributedFootnote = attributedFootnote
        self.image = image
        self.actions = actions
    }

    deinit {
        for action in storedActions {
            switch action {
            case .autoRecall(let action):
                action.timer.invalidate()
            default:
                break
            }
        }
    }

    private func nibInit() {
        Bundle.main.loadNibNamed("PLCoverView", owner: self, options: nil)

        addSubview(contentView)

        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    private func updateMultiplier(for constraint: inout NSLayoutConstraint, multiplier: CGFloat) {
        let newConstraint = NSLayoutConstraint(item: constraint.firstItem!, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: constraint.secondItem, attribute: constraint.secondAttribute, multiplier: multiplier, constant: constraint.constant)

        newConstraint.priority = constraint.priority
        newConstraint.shouldBeArchived = constraint.shouldBeArchived
        newConstraint.identifier = constraint.identifier

        NSLayoutConstraint.deactivate([constraint])
        NSLayoutConstraint.activate([newConstraint])

        constraint = newConstraint
    }
}
