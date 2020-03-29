//
//  CurrencyConverterViewModel.swift
//  CurrencyConverter
//
//  Created by MithranN on 29/03/20.
//  Copyright © 2020 MithranN. All rights reserved.
//

import Foundation

protocol CurrencyConverterViewModelDelegate: class {
    func reloadData()
    func apiCallInProgress()
    func apiCallCompleted()
}

protocol CurrencyConverterDS: class {
    var noOfExchangeRates: Int { get }
    var exchangeRates: [String: Double] { get }
    var currencyListToSelect: [String] { get }
    func getCurrencyAt(_ index: Int) -> String?
    func didUserChangeAmount(amount: String?)
    func didUserSelectedCurrenct(at index: Int)
    func getCurrencyExchangeRates()
}

class CurrencyConverterViewModel {
    
    let networkManager = CurrencyConverterDataManager()
    
    var exchangeRateResponse: CurrencyExchangeResponse?
    
    var userEnteredAmount: String? {
        didSet {
            delegate?.reloadData()
        }
    }
    
    var userSelectedCurrency: String? {
        didSet {
            delegate?.reloadData()
        }
    }
    
    weak var delegate: CurrencyConverterViewModelDelegate?
    
    init() {
        
    }
    
    func getCurrencyExchangeRates() {
        if UserDefaults.shouldFetchExchangeRates == false {
            self.exchangeRateResponse = UserDefaults.exchangeRateReponse
            return
        }
        delegate?.apiCallInProgress()
        networkManager.getCurrencyExchangeRates { result in
            switch result {
            case .success(let response):
                guard let response = response else {
                    return
                }
                self.exchangeRateResponse = response
                UserDefaults.set(exchangeRateReponse: response)
            case .failure(_):
                break
            }
            self.delegate?.apiCallCompleted()
            self.delegate?.reloadData()
        }
    }
}

extension CurrencyConverterViewModel: CurrencyConverterDS {
    
    var currencyListToSelect: [String] {
        var currenyArray: [String] = []
        currenyArray.append("USD")
        for text in Array(exchangeRates.keys).sorted() {
            currenyArray.append(text.replacingOccurrences(of: "USD", with: ""))
        }
        return currenyArray
    }
    
    var noOfExchangeRates: Int {
        return exchangeRateResponse?.quotes?.count ?? 0
    }
    
    var exchangeRates: [String: Double] {
        return exchangeRateResponse?.quotes ?? [:]
    }
    
    
    var currencyList: [String] {
        var currenyArray = Array(exchangeRates.keys).sorted()
        currenyArray.insert("USD", at: 0)
        return currenyArray
    }
    
    func getCurrencyAt(_ index: Int) -> String? {
        guard let currencyName =  currencyList[safeIndex: index] else {
            return nil
        }
        var currencyToDisplay = currencyName
        if currencyToDisplay != "USD" {
            currencyToDisplay = currencyName.replacingOccurrences(of: "USD", with: "")
        }
        
        guard let userSelectedCurrency = userSelectedCurrency, let userEnteredAmount = userEnteredAmount else{
            return currencyToDisplay
        }
        if userSelectedCurrency == "USD" {
            if let currencyRate = exchangeRates[currencyName], let userAmount = Double(userEnteredAmount) {
                let exchangeRate = (userAmount * currencyRate).rounded(toPlaces: 2)
                return "\(exchangeRate) \(currencyToDisplay)"
            }
        }else if currencyName == "USD" {
            if let userAmount = Double(userEnteredAmount), let currencyRate = exchangeRates[userSelectedCurrency] {
                return "\((userAmount/currencyRate).rounded(toPlaces: 2)) \(currencyToDisplay)"
            }
        } else if let selectedCurrencyRate = exchangeRates[userSelectedCurrency] {
            if let userAmount = Double(userEnteredAmount), let currencyRate = exchangeRates[currencyName] {
                let exchangeRate = (userAmount/selectedCurrencyRate * currencyRate).rounded(toPlaces: 2)
                return "\(exchangeRate) \(currencyToDisplay)"
            }
        }
        return currencyToDisplay
    }
    
    func didUserChangeAmount(amount: String?) {
        self.userEnteredAmount = amount
    }
    
    func didUserSelectedCurrenct(at index: Int) {
        self.userSelectedCurrency = currencyList[safeIndex: index]
        checkAndFetchExchangeRatesIfNeeded()
    }
    
    func checkAndFetchExchangeRatesIfNeeded() {
        if UserDefaults.shouldFetchExchangeRates {
            getCurrencyExchangeRates()
        }
    }
    
}


extension UserDefaults {
    
    private struct Keys {
        
        // MARK: - Constants
        
        static let lastFetchTimeOfExchangeRates = "lastFetchTimeOfExchangeRates"
        
        static let exchangeRatesResponse = "exchangeRatesResponse"
        
    }
    
    class var exchangeRateReponse: CurrencyExchangeResponse? {
        guard let storedValue = UserDefaults.standard.data(forKey: UserDefaults.Keys.exchangeRatesResponse) else {
            return nil
        }
        do {
            let jsonDecoder = JSONDecoder()
            return try jsonDecoder.decode(CurrencyExchangeResponse.self, from: storedValue)
        }
        catch {
            // catch the error
        }
        return nil
    }
    
    class func set(exchangeRateReponse: CurrencyExchangeResponse) {
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(exchangeRateReponse)
            UserDefaults.standard.set(jsonData, forKey: UserDefaults.Keys.exchangeRatesResponse)
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: UserDefaults.Keys.lastFetchTimeOfExchangeRates)
        }
        catch {
            // catch the error
        }
    }
    
    class var shouldFetchExchangeRates: Bool {
        let storedValue = UserDefaults.standard.double(forKey: UserDefaults.Keys.lastFetchTimeOfExchangeRates)
        if Date().timeIntervalSince1970 - storedValue > 1800 || self.exchangeRateReponse == nil {
            return true
        }
        return false
    }
    
    
}
