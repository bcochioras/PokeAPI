//
//  PokeFeedCell.swift
//  PokemonApp
//
//  Created by Cochioras Bogdan Ionut on 4/3/22.
//

import Foundation
import UIKit

final class PokeFeedCell: UITableViewCell {
    private let horizontalStack: UIStackView = {
        let temp = UIStackView(axis: .horizontal)
        temp.spacing = 8
        temp.distribution = .fill
        temp.alignment = .center
        return temp
    }()
    
    private let nameLabel: StackLabel = {
        let temp = StackLabel()
        return temp
    }()

    private let identifierLabel: StackLabel = {
        let temp = StackLabel()
        temp.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        temp.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        temp.setContentHuggingPriority(.required, for: .vertical)
        return temp
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(from pokemon: PokemonsResponse.Pokemon) {
        identifierLabel.text = pokemon.url?.lastPathComponent
        nameLabel.text = pokemon.name
    }
    
    private func setupLayout() {
        contentView.addSubview(horizontalStack)
        horizontalStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 8))
            make.height.equalTo(44).priority(999)
        }
        horizontalStack.addArrangedSubview(identifierLabel)
        horizontalStack.addArrangedSubview(nameLabel)
        accessoryType = .disclosureIndicator
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameLabel.text = nil
        identifierLabel.text = nil
    }
}
