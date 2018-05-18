//
//  AccountCell.swift
//  Balancing Act
//
//  Created by Drew Lanning on 5/18/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import UIKit
import Firebase

class AccountCell: UITableViewCell {
  
  @IBOutlet weak var accountName: UILabel!
  @IBOutlet weak var accountBalance: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  func configure(with account: Account) {
    self.accountName.text = account.nickname
    account.ref?.observe(.value, with: { (snapshot) in
      for child in snapshot.children {
        if let child = child as? DataSnapshot {
          if child.key == "currentBalance", let total = child.value as? Double {
            DispatchQueue.main.async {
              self.accountBalance.text = Money.format(amount: total)
            }
          }
        }
      }
    })
  }
  
}
