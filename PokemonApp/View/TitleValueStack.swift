//
//  TitleValueStack.swift
//  PokemonApp
//
//  Created by Cochioras Bogdan-Ionut on 25.07.2023.
//

import UIKit


final class TitleValueStack: UIView {

    let titleLabel: StackLabel = {
        let temp = StackLabel()
        return temp
    }()
    let valueLabel: StackLabel = {
        let temp = StackLabel()
        temp.numberOfLines = 0
        return temp
    }()
    let stackView: UIStackView = {
        let temp = UIStackView(axis: .vertical)
        temp.spacing = 8
        temp.alignment = .leading
        return temp
    }()

    init(title: String?, value: String?) {
        super.init(frame: .zero)

        titleLabel.text = title?.capitalizingFirstLetter()
        valueLabel.text = value

        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        }

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(valueLabel)
    }
}
