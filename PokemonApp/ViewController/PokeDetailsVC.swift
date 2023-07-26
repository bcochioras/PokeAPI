//
//  PokeDetailsVC.swift
//  PokemonApp
//
//  Created by Cochioras Bogdan Ionut on 4/2/22.
//

import Foundation
import UIKit
import Combine
import AnyCodable
import Kingfisher


final class PokeDetailsVC: UIViewController {
    
    private let imageView: UIImageView = {
        let temp = UIImageView()
        temp.contentMode = .scaleAspectFit
        temp.kf.indicatorType = .activity
        return temp
    }()
    private var cancellables = Set<AnyCancellable>()
    private let scrollView = UIScrollView()
    private let scrollWrapper = UIView()
    private let detailsStack: UIStackView = {
        let temp = UIStackView(axis: .vertical)
        temp.spacing = 8
        return temp
    }()
    private let activityIndicator: UIActivityIndicatorView = {
        let temp = UIActivityIndicatorView()
        temp.hidesWhenStopped = true
        return temp
    }()
    
    private let viewModel: PokeDetailsVM
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
        
        setupView()
    }

    private func setupObservables() {
        viewModel.isLoadingObservable
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] isLoading in
                isLoading ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
            }.store(in: &cancellables)

        viewModel.pokemonObservable
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pokemon in
                guard let self = self,
                      let detailed = pokemon.detailed else {
                    return
                }
                self.title = pokemon.name
                self.imageView.kf.setImage(with: detailed.sprites?.frontDefault)
                self.detailsStack.arrangedSubviews.forEach({$0.removeFromSuperview()})
                pokemon.detailed?.dictionary?.forEach({ (key, value) in
                    switch value {
                    case is [Any]: break
                    case let value as [AnyHashable: Any]:
                        value.forEach { (key, value) in
                            if let key = key as? String {
                                let stack = TitleValueStack(title: key, value: String(describing: value))
                                self.detailsStack.addArrangedSubview(stack)
                            }
                        }
                        break
                    default:
                        let stack = TitleValueStack(title: key, value: String(describing: value))
                        self.detailsStack.addArrangedSubview(stack)
                    }
                })
            }.store(in: &cancellables)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupObservables()
        viewModel.loadDetails()
    }
}


// MARK: - UI Setup

private extension PokeDetailsVC {
    func setupView() {
        view.backgroundColor = .white
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

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
            make.height.width.equalTo(200).priority(999)
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
}
