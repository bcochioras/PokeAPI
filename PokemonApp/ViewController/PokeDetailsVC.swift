//
//  PokeDetailsVC.swift
//  PokemonApp
//
//  Created by Cochioras Bogdan Ionut on 4/2/22.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import AnyCodable
import Kingfisher

fileprivate final class TitleValueStack: UIView {

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
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8,
                                                             left: 8,
                                                             bottom: 8,
                                                             right: 8))
        }
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(valueLabel)
    }
}

final class PokeDetailsVC: UIViewController {
    
    private let imageView: UIImageView = {
        let temp = UIImageView()
        temp.contentMode = .scaleAspectFit
        temp.kf.indicatorType = .activity
        return temp
    }()
    let disposeBag = DisposeBag()
    private let scrollView = UIScrollView()
    private let scrollWrapper = UIView()
    private let detailsStack: UIStackView = {
        let temp = UIStackView(axis: .vertical)
        temp.spacing = 8
        return temp
    }()
    
    let viewModel: PokeDetailsVM
    private let verticalStackView: UIStackView = {
        let temp = UIStackView()
        temp.translatesAutoresizingMaskIntoConstraints = false
        temp.axis = .vertical
        return temp
    }()
    
    required init(pokemon: PokemonsResponse.Pokemon) {
        viewModel = PokeDetailsVM(pokemon: pokemon)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(scrollWrapper)
        scrollWrapper.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
            make.height.greaterThanOrEqualTo(view)
        }
        
        scrollWrapper.addSubview(verticalStackView)
        verticalStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        verticalStackView.addArrangedSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(200)
        }
        
        let detailStackContainer = UIView()
        detailStackContainer.addSubview(detailsStack)
        detailsStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        verticalStackView.addArrangedSubview(detailStackContainer)
        // filler
        verticalStackView.addArrangedSubview(UIView())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.pokemonObservable
            .drive { [weak self] pokemon in
                guard let self = self,
                      let detailed = pokemon.detailed else {
                    return
                }
                self.title = pokemon.name?.capitalized
                self.imageView.kf.setImage(with: detailed.sprites?.frontDefault)
                self.detailsStack.arrangedSubviews.forEach({$0.removeFromSuperview()})
                pokemon.detailed?.dictionary?.forEach({ (key, value) in
                    switch value {
                    case is [Any]: fallthrough
                    case is [AnyHashable: Any]:
                        break
                    default:
                        let stack = TitleValueStack(title: key,
                                                value: String(describing: value))
                        self.detailsStack.addArrangedSubview(stack)
                    }
                })
            }.disposed(by: disposeBag)
        
        viewModel.loadDetails()
    }
}
