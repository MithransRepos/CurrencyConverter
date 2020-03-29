//
//  CurrencyExchangeResponse.swift
//  CurrencyConverter
//
//  Created by MithranN on 29/03/20.
//  Copyright © 2020 MithranN. All rights reserved.
//

import Foundation
// MARK: - CurrencyExchangeResponse
class CurrencyExchangeResponse: Codable {
    let success: Bool?
    let terms, privacy: String?
    let timestamp: Int?
    let source: String?
    let quotes: [String: Double]?

    init(success: Bool?, terms: String?, privacy: String?, timestamp: Int?, source: String?, quotes: [String: Double]?) {
        self.success = success
        self.terms = terms
        self.privacy = privacy
        self.timestamp = timestamp
        self.source = source
        self.quotes = quotes
    }
}
