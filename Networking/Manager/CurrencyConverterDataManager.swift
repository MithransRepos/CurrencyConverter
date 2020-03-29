//
//  CurrencyConverterDataManager.swift
//  CurrencyConverter
//
//  Created by MithranN on 29/03/20.
//  Copyright © 2020 MithranN. All rights reserved.
//

import Foundation
class CurrencyConverterDataManager {
    private let router = Router<CurrencyConverterApi>()

    func getCurrencyExchangeRates(completion: @escaping (Result<CurrencyExchangeResponse?, APIError>) -> Void) {
        var params: [String: Any] = [:]
        params["access_key"] = NetworkConstants.ApiKey
        params["format"] = 1
        router.fetch(.getCurrency(params: params), decode: { json -> CurrencyExchangeResponse? in
            json as? CurrencyExchangeResponse
        }, completion: completion)
    }

}
