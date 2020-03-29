//
//  CurrencyConverterApi.swift
//  CurrencyConverter
//
//  Created by MithranN on 29/03/20.
//  Copyright © 2020 MithranN. All rights reserved.
//

import Foundation
public enum CurrencyConverterApi {
    case getCurrency(params: [String: Any]?)
}

extension CurrencyConverterApi: EndPointType {
    var baseURL: URL {
        guard let url = URL(string: NetworkConstants.BaseURL) else {
            fatalError("baseURL could not be configured.")
        }
        return url
    }

    var path: String {
        switch self {
        case .getCurrency:
            return "/live"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .getCurrency:
            return .get
        }
    }

    var task: HTTPTask {
        switch self {
        case .getCurrency(let params):
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: params)
        }
    }

    var headers: HTTPHeaders? {
        return nil
    }
}
