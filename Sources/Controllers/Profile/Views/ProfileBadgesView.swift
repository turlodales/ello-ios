////
///  ProfileBadgesView.swift
//

private let maxBadges = 3


class ProfileBadgesView: ProfileBaseView {
    struct Size {
        static let height: CGFloat = 60
        static let badgeSize = CGSize(width: 36, height: 44)
    }

    var badges: [ProfileBadge] = [] {
        didSet { updateBadgeViews() }
    }
    var badgeButtons: [UIButton] = []

    fileprivate let badgesContainer = UIView()
    fileprivate let moreBadgesButton = UIButton()

    override func bindActions() {
        moreBadgesButton.addTarget(self, action: #selector(moreBadgesTapped), for: .touchUpInside)
    }

    override func style() {
        backgroundColor = .white
    }

    override func arrange() {
        addSubview(moreBadgesButton)
        addSubview(badgesContainer)

        moreBadgesButton.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }

        badgesContainer.snp.makeConstraints { make in
            make.top.bottom.centerX.equalTo(self)
        }
    }

    fileprivate func updateBadgeViews() {
        for view in badgesContainer.subviews {
            view.removeFromSuperview()
        }

        badgeButtons = badges.safeRange(0 ..< maxBadges).map { (badge: ProfileBadge) -> UIButton in
            let button = UIButton()
            button.addTarget(self, action: #selector(badgeTapped(_:)), for: .touchUpInside)
            button.contentMode = .center
            button.setImage(badge.image, imageStyle: .normal, for: .normal)
            button.snp.makeConstraints { make in
                make.size.equalTo(Size.badgeSize)
            }
            return button
        }
        var badgeViews: [UIView] = badgeButtons

        if badges.count > maxBadges {
            let view = UILabel()
            let remaining = badges.count - maxBadges
            view.font = UIFont.defaultFont()
            view.text = "+\(remaining.numberToHuman())"
            view.textColor = .greyA()
            badgeViews.append(view)
        }

        var prevView: UIView?
        for view in badgeViews {
            badgesContainer.addSubview(view)

            view.snp.makeConstraints { make in
                make.centerY.equalTo(badgesContainer)

                if let prevView = prevView {
                    make.leading.equalTo(prevView.snp.trailing)
                }
                else {
                    make.leading.equalTo(badgesContainer)
                }
            }

            prevView = view
        }

        if let prevView = prevView {
            prevView.snp.makeConstraints { make in
                make.trailing.equalTo(badgesContainer)
            }
        }
    }

}

extension ProfileBadgesView {

    func badgeTapped(_ sender: UIButton) {
        guard
            let buttonIndex = badgeButtons.index(of: sender)
        else { return }

        let badge = badges[buttonIndex]
        let responder = target(forAction: #selector(ProfileHeaderResponder.onCategoryBadgeTapped), withSender: self) as? ProfileHeaderResponder
        if badge == .featured {
            responder?.onCategoryBadgeTapped()
        }
        else {
            responder?.onBadgeTapped(badge.rawValue)
        }
    }

    func moreBadgesTapped() {
        let responder = target(forAction: #selector(ProfileHeaderResponder.onMoreBadgesTapped), withSender: self) as? ProfileHeaderResponder
        responder?.onMoreBadgesTapped()
    }

}