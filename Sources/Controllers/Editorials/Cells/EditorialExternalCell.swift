////
///  EditorialExternalCell.swift
//

class EditorialExternalCell: EditorialTitledCell {

    override func style() {
        super.style()
    }

    override func bindActions() {
        super.bindActions()
    }

    override func updateConfig() {
        super.updateConfig()
    }

    override func arrange() {
        super.arrange()

        subtitleWebView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(editorialContentView).inset(Size.defaultMargin)
            subtitleHeightConstraint = make.height.equalTo(0).constraint
        }
    }
}