//
//  ViewController.swift
//  PokemonApp
//
//  Created by Cochioras Bogdan Ionut on 4/1/22.
//

import UIKit
import SnapKit
import Combine

final class PokeFeedVC: UIViewController {

    private var cancellables = Set<AnyCancellable>()
    private let viewModel = PokeFeedVM()
    
    private lazy var tableView : UITableView = { [unowned self] in
        let temp = UITableView(frame: .zero, style: .grouped)
        temp.rowHeight = UITableView.automaticDimension
        temp.estimatedRowHeight = 44
        temp.delegate = self
        temp.dataSource = self
        return temp
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let temp = UIActivityIndicatorView()
        temp.hidesWhenStopped = true
        return temp
    }()


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

        viewModel.listDataObservable
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                self.tableView.reloadData()
        }.store(in: &cancellables)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        setupObservables()
        viewModel.loadMore(isRefresh: true)
    }
}


extension PokeFeedVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRow
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PokeFeedCell.className, for: indexPath) as! PokeFeedCell
        return cell
    }
}


extension PokeFeedVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let pokemon = viewModel.data(at: indexPath) else {
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(PokeDetailsVC(pokemon: pokemon), animated: true)
    }


    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? PokeFeedCell,
              let pokemon = viewModel.data(at: indexPath) else {
            return
        }
        cell.configure(from: pokemon)
        viewModel.logPokemonViewed(pokemon)
        viewModel.loadMoreIfNeeded(for: indexPath)
    }
}



// MARK: - UI Setup

private extension PokeFeedVC {
    func setupView() {
        title = "Pokemons"

        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.register(cellType: PokeFeedCell.self)
    }
}
