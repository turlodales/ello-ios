////
///  SearchStreamCell.swift
//

open class SearchStreamCell: UICollectionViewCell {
    static let reuseIdentifier = "SearchStreamCell"
    struct Size {
        static let insets: CGFloat = 10
    }

    fileprivate var debounced: ThrottledBlock = debounce(0.8)
    fileprivate let searchField = SearchTextField()
    open weak var delegate: SearchStreamDelegate?

    open var placeholder: String? {
        get { return searchField.placeholder }
        set { searchField.placeholder = newValue }
    }
    open var search: String? {
        get { return searchField.text }
        set { searchField.text = newValue }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white

        style()
        arrange()

        searchField.delegate = self
        searchField.addTarget(self, action: #selector(searchFieldDidChange), for: .editingChanged)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func style() {
    }

    fileprivate func arrange() {
        contentView.addSubview(searchField)

        searchField.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView)
            make.leading.trailing.equalTo(contentView).inset(Size.insets)
        }
    }
}

extension SearchStreamCell: DismissableCell {
    public func didEndDisplay() {
        _ = searchField.resignFirstResponder()
    }
}

extension SearchStreamCell: UITextFieldDelegate {

    @objc
    public func searchFieldDidChange() {
        let text = searchField.text ?? ""
        if text.characters.count == 0 {
            clearSearch()
        }
        else {
            debounced { [unowned self] in
                self.searchForText()
            }
        }
    }

    @objc
    public func textFieldDidEndEditing(_ textField: UITextField) {
        textField.setNeedsLayout()
        textField.layoutIfNeeded()
    }

    @objc
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        _ = textField.resignFirstResponder()
        return true
    }

    fileprivate func searchForText() {
        guard let
            text = searchField.text,
            text.characters.count > 0
        else { return }

        self.delegate?.searchFieldChanged(text: text)
    }

    fileprivate func clearSearch() {
        delegate?.searchFieldChanged(text: "")
        debounced {}
    }
}
