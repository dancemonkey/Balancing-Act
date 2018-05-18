//
//  TransactionCell.swift
//  Balancing Act
//
//  Created by Drew Lanning on 5/18/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import UIKit

class TransactionCell: UITableViewCell {
  
  @IBOutlet weak var payee: UILabel!
  @IBOutlet weak var amount: UILabel!
  @IBOutlet weak var date: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  func configure(with trx: Transaction) {
    self.payee.text = trx.payee
    self.amount.text = Money.format(amount: trx.amount)
    self.date.text = trx.simpleDate
    self.backgroundColor = trx.reconciled ? UIColor.gray : UIColor.white
  }
  
}
