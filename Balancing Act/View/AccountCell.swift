//
//  AccountCell.swift
//  Balancing Act
//
//  Created by Drew Lanning on 5/18/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import UIKit

class AccountCell: UITableViewCell {
  
  @IBOutlet weak var accountName: UILabel!
  @IBOutlet weak var accountBalance: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  func configure(with account: Account) {
    self.accountName.text = account.nickname
    account.getCurrentBalance { (total) in
      DispatchQueue.main.async {
        self.accountBalance.text = Money.format(amount: total)
      }
    }
  }
  
}
