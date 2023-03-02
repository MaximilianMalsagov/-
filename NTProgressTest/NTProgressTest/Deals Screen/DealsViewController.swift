//
//  DealsViewController.swift
//  TemplateOfDealsViewer
//
//  Created by Maksimilian  on 01.03.2023.
//

import Foundation
import UIKit

private let identifierDealCell = "dealCell"
private let identifierHeader = "header"

class DealsViewController: UIViewController {
    private let server = Server()
    
    private weak var passInfoToCell: PassInfoProtocol?
    
    private lazy var dealsTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.register(DealCustomCell.self, forCellReuseIdentifier: identifierDealCell)
        tableView.register(HeaderTableView.self, forHeaderFooterViewReuseIdentifier: identifierHeader)
        tableView.frame = CGRect(x: Constants.paddingSides, y: 0, width: view.frame.width - (2 * Constants.paddingSides), height: view.frame.height)
        return tableView
    }()
    
    private lazy var sortPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.layer.cornerRadius = Constants.cornerRadius
        pickerView.backgroundColor = .systemGray6
        pickerView.clipsToBounds = true
        pickerView.isHidden = true
        pickerView.frame = CGRect(x: Constants.paddingSides/2, y: 100, width: view.frame.width - Constants.paddingSides, height: 140)
        return pickerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setController()
        setNavigationBar()
        setGestureRecognizer()
        getDataFromNetwork()
    }
    
    private func getDataFromNetwork() {
        server.subscribeToDeals { deals in
            LocalStorage.shared.saveDeals(deals: deals)
            LocalStorage.shared.sortModel {
                self.dealsTableView.reloadData()
            }
            LocalStorage.shared.getDealsInStorage().count < 101 ? LocalStorage.shared.addCells() : nil
        }
    }
    
    private func setController() {
        view.addSubview(dealsTableView)
        view.addSubview(sortPickerView)
        view.backgroundColor = .white
        
    }
    
    private func setGestureRecognizer() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeSortButton)))
    }
    
    private func setNavigationBar() {
        navigationItem.title = "Deals"
        
        let sortButton = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .done, target: self, action: #selector(changeSortButton))
        navigationItem.leftBarButtonItem = sortButton
        
        let scrollUpButton =  UIBarButtonItem(image: UIImage(systemName: "arrow.up.to.line.circle"), style: .done, target: self, action: #selector(scrollUpButton))
        navigationItem.rightBarButtonItem = scrollUpButton
        
        let changeSortButton =  UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down.circle.fill"), style: .done, target: self, action: #selector(reverseSortButton))
        navigationItem.rightBarButtonItems = [changeSortButton, scrollUpButton]
        
        navigationController?.navigationBar.tintColor = .black
    }
    
    
    // открыть пикер для смены параметра сортировки
    @objc private func changeSortButton() {
        dealsTableView.isUserInteractionEnabled = !dealsTableView.isUserInteractionEnabled
        sortPickerView.isHidden = !sortPickerView.isHidden
    }
    
    // сменить направление сортировки
    @objc private func reverseSortButton() {
        LocalStorage.shared.sortDerection = LocalStorage.shared.sortDerection == .first ? SortDerection.last : SortDerection.first
        LocalStorage.shared.sortModel {
            self.dealsTableView.reloadData()
        }
    }
    
    // кнопка чтобы вернуться к первой ячейке
    @objc private func scrollUpButton() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.dealsTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
}


// MARK: UITableViewDataSource
extension DealsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifierDealCell, for: indexPath) as? DealCustomCell {
            let dealInfo = LocalStorage.shared.getDealsInStorage()[indexPath.row]
            passInfoToCell = cell
            passInfoToCell?.passInfo(dealInfo: dealInfo )
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        LocalStorage.shared.getDealCellsCount()
    }
}

// MARK: UITableViewDelegate
extension DealsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifierHeader) as? HeaderTableView {
            return header
        }
        return UITableViewHeaderFooterView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
}

// MARK: UIPickerViewDataSource
extension DealsViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        5
    }
}

// MARK: UIPickerViewDelegate
extension DealsViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "Sort by \(LocalStorage.shared.arraySortsType[row])"
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        35
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedSort = LocalStorage.shared.arraySortsType[row]
        LocalStorage.shared.currentSortType = selectedSort
        changeSortButton()
        LocalStorage.shared.sortModel {
            self.dealsTableView.reloadData()
        }
    }
}

// MARK: UITableViewDataSourcePrefetching
// подгрузка ячеек по мере прокрутки
extension DealsViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let maxCell = indexPaths.map({$0.row}).max() else { return }
        if maxCell > (LocalStorage.shared.getDealCellsCount() - 5) {
            LocalStorage.shared.addCells()
        }
    }
}
