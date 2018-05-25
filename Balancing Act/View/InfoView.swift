//
//  InfoView.swift
//  Balancing Act
//
//  Created by Drew Lanning on 5/24/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import UIKit

class InfoView: UIView {

  @IBOutlet weak var recBalanceLbl: UILabel!
  @IBOutlet weak var totalBalance: UILabel!
  
  func updateCleared(with amount: Double) {
    let amt = Money.currencyFormat(amount: amount)
    recBalanceLbl.text = "Cleared Balance: \(amt)"
  }
  
  func updateBalance(with amount: Double) {
    let amt = Money.currencyFormat(amount: amount)
    totalBalance.text = "Balance: \(amt)"
  }

}
