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
  }
  
  func configure(with trx: Transaction) {
    self.payee.text = trx.payee
    let deposit: Bool = trx.isDeposit ?? false
    self.amount.text = deposit ? Money.currencyFormat(amount: trx.amount) : Money.currencyFormat(amount: -trx.amount)
    setColors(for: [payee, amount, date], isDeposit: deposit)
    self.date.text = trx.simpleDate
    if trx.cleared && !trx.reconciled {
      self.backgroundColor = UIColor.yellow
    } else {
      self.backgroundColor = trx.reconciled ? UIColor(named: "reconciledColor") : UIColor.white
    }
  }
  
  private func setColors(for labels: [UILabel], isDeposit: Bool) {
    for label in labels {
      label.textColor = isDeposit ? UIColor(named: "depositColor") : UIColor.darkText
    }
  }
  
}
