//
//  ViewController.swift
//  PokemonApp
//
//  Created by Cochioras Bogdan Ionut on 4/1/22.
//

import UIKit
import SnapKit
import RxSwift

final class PokeFeedVC: UIViewController {

    let disposeBag = DisposeBag()
    let viewModel = PokeFeedVM()
    
    private lazy var tableView : UITableView = {
        let temp = UITableView(frame: .zero, style: .grouped)
        temp.rowHeight = UITableView.automaticDimension
        temp.estimatedRowHeight = 44
        return temp
    }()
    
    override func loadView() {
        super.loadView()
        title = "Pokemons"
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.register(cellType: PokeFeedCell.self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.listDataObservable
            .bind(to: tableView.rx.items(cellIdentifier: PokeFeedCell.className,
                                         cellType: PokeFeedCell.self)){ row, pokemon, cell in
                
            }.disposed(by: disposeBag)
        
        tableView.rx.willDisplayCell
            .subscribe { [weak self] (cell: UITableViewCell, at: IndexPath) in
                guard let self = self else {
                    return
                }
                switch cell {
                case let cell as PokeFeedCell:
                    guard let pokemon = self.viewModel.data(at: at) else {
                        return
                    }
                    cell.configureFrom(pokemon: pokemon)
                default:
                    assertionFailure("Unhandled type")
                    break
                }
                // preload before last 4 items
                if at.row >= self.tableView.numberOfRows(inSection: 0) - 4 {
                    self.viewModel.loadMore(isRefresh: false)
                }
            }.disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
                guard let pokemon = self.viewModel.data(at: indexPath) else {
                    return
                }
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.navigationController?.pushViewController(PokeDetailsVC(pokemon: pokemon),
                                                              animated: true)
            }).disposed(by: disposeBag)
        
        viewModel.loadMore(isRefresh: true)
    }
}

