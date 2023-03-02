//
//  LocalStorage.swift
//  TemplateOfDealsViewer
//
//  Created by Maksimilian  on 01.03.2023.
//

import Foundation

class LocalStorage {
    static let shared = LocalStorage()
    
    private var model: [Deal] = []
    private var dealCellsCount = 0
    
    var sortDerection: SortDerection = .first
    var currentSortType: SortType = .date
    let arraySortsType = [SortType.date, SortType.instrument, SortType.price, SortType.amount, SortType.side]
    
    func getDealsInStorage() -> [Deal]  {
        return model
    }
    
    func addCells() {
        dealCellsCount += 30
    }
    
    func getDealCellsCount() -> Int {
        return dealCellsCount
    }
    
    func saveDeals(deals:[Deal]) {
        model += deals
    }
    
    func sortModel(completion: @escaping () -> ()) {
        switch currentSortType {
        case .date:
            sortDerection == .first ? model.sort(by: {$0.dateModifier > $1.dateModifier}) : model.sort(by: {$0.dateModifier < $1.dateModifier})
        case .instrument:
            sortDerection == .first ? model.sort(by: {$0.instrumentName < $1.instrumentName}) : model.sort(by: {$0.instrumentName > $1.instrumentName})
        case .price:
            sortDerection == .first ? model.sort(by: {$0.price < $1.price}) : model.sort(by: {$0.price > $1.price})
        case .amount:
            sortDerection == .first ? model.sort(by: {$0.amount < $1.amount}) : model.sort(by: {$0.amount > $1.amount})
        case .side:
            let buy = model.filter({$0.side == .buy})
            let sell = model.filter({$0.side == .sell})
            model.removeAll()
            model += sortDerection == .first ? buy : sell
            model += sortDerection == .first ? sell : buy
        }
        completion()
    }
    
}

