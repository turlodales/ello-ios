////
///  OmnibarTextCell.swift
//

open class OmnibarTextCell: UITableViewCell {
    static let reuseIdentifier = "OmnibarTextCell"
    struct Size {
        static let textMargins = UIEdgeInsets(top: 11, left: 15, bottom: 11, right: 15)
        static let minHeight = CGFloat(44)
        static let maxEditingHeight = CGFloat(77)
    }

    open let textView: UITextView
    open var isFirst = false {
        didSet {
            if isFirst && attributedText.string.characters.count == 0 {
                textView.attributedText = ElloAttributedString.style(InterfaceString.Omnibar.SayEllo, [NSForegroundColorAttributeName: UIColor.black])
            }
        }
    }

    class func generateTextView() -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.textColor = .black
        textView.tintColor = .black
        textView.font = UIFont.editorFont()
        textView.textContainerInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        textView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        textView.scrollsToTop = false
        textView.isScrollEnabled = false
        textView.showsHorizontalScrollIndicator = false
        textView.showsVerticalScrollIndicator = false
        textView.keyboardAppearance = .dark
        textView.keyboardType = .twitter
        return textView
    }

    open var attributedText: NSAttributedString {
        didSet {
            if attributedText.string.characters.count > 0 {
                textView.attributedText = attributedText
            }
            else if isFirst {
                textView.attributedText = ElloAttributedString.style(InterfaceString.Omnibar.SayEllo, [NSForegroundColorAttributeName: UIColor.black])
            }
            else {
                textView.attributedText = ElloAttributedString.style(InterfaceString.Omnibar.AddMoreText, [NSForegroundColorAttributeName: UIColor.black])
            }
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        textView = OmnibarTextCell.generateTextView()
        attributedText = NSAttributedString(string: "")
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        textView.isUserInteractionEnabled = false
        textView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        let backgroundView = UIView()
        backgroundView.backgroundColor = .white
        self.backgroundView = backgroundView

        contentView.addSubview(textView)
    }

    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        textView.frame = OmnibarTextCell.boundsForTextView(contentView.bounds)
    }

    open class func boundsForTextView(_ frame: CGRect) -> CGRect {
        return frame.inset(Size.textMargins)
    }

    open class func heightForText(_ attributedText: NSAttributedString, tableWidth: CGFloat, editing: Bool) -> CGFloat {
        var textWidth = tableWidth - (Size.textMargins.left + Size.textMargins.right)
        if editing {
            textWidth -= 80
        }

        let tv = generateTextView()
        tv.attributedText = attributedText
        let tvSize = tv.sizeThatFits(CGSize(width: textWidth, height: .greatestFiniteMagnitude))
        // adding a magic 1, for rare "off by 1" height calculations.
        let heightPadding = Size.textMargins.top + Size.textMargins.bottom + 1
        let textHeight = heightPadding + ceil(tvSize.height)

        let reasonableHeight = max(Size.minHeight, textHeight)
        if editing {
            return min(Size.maxEditingHeight, reasonableHeight)
        }
        return reasonableHeight
    }

}
