//
//  CurrencyTableViewCell.swift
//  CurrencyApp
//
//  Created by Leonardo Reis on 06/04/19.
//  Copyright © 2019 Leonardo Reis. All rights reserved.
//

import UIKit

class CurrencyTableViewCell: UITableViewCell {
    var currency: Currency?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

extension CurrencyTableViewCell {
    func setupCell(_ currency: Currency) {
        nameLabel.text = currency.name
        priceTextField.text = "\(currency.value)"
    }
}
