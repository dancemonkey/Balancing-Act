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
  
  func update(with amount: Double) {
    let amt = Money.currencyFormat(amount: amount)
    recBalanceLbl.text = "Cleared Balance: \(amt)"
  }

}
