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
    setLabelStyle(for: [payee, amount, date], isDeposit: deposit)
    self.date.text = trx.simpleDate
    if trx.cleared && !trx.reconciled {
      self.backgroundColor = UIColor(named: Constants.Colors.accentSuccess.rawValue)
    } else {
      self.backgroundColor = trx.reconciled ? UIColor(named: Constants.Colors.accentSuccess.rawValue) : UIColor.white
    }
  }
  
  private func setLabelStyle(for labels: [UILabel], isDeposit: Bool) {
    for label in labels {
      if isDeposit {
        let traits = label.font.withTraits(traits: .traitBold)
        label.font = traits
        label.textColor = UIColor(named: Constants.Colors.accentWarning.rawValue)
      } else {
        let font = UIFont.systemFont(ofSize: label.font.pointSize)
        label.font = font
        label.textColor = UIColor(named: Constants.Colors.altBlack.rawValue)
      }
    }
  }
  
}
