//
//  Currency.swift
//  CurrencyApp
//
//  Created by Leonardo Reis on 06/04/19.
//  Copyright © 2019 Leonardo Reis. All rights reserved.
//

import UIKit

struct Currency: Decodable {
    let name: String
    let value: CGFloat
    
    private enum CodingKeys: String, CodingKey {
        case name
        case value
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        value = try values.decode(CGFloat.self, forKey: .value)
    }
}
