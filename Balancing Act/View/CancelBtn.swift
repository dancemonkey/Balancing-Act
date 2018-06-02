//
//  AccountsBtn.swift
//  Balancing Act
//
//  Created by Drew Lanning on 6/1/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import UIKit

class CancelBtn: UIButton {
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    layer.cornerRadius = 4.0
    backgroundColor = .gray
    setTitleColor(.white, for: .normal)
    self.titleLabel?.font = UIFont.systemFont(ofSize: 22.0)
    
  }
  
}
