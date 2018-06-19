//
//  HighlightTextField.swift
//  Balancing Act
//
//  Created by Drew Lanning on 6/19/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import UIKit

extension UITextField {
  func highlight() {
    self.borderStyle = .roundedRect
    self.layer.borderColor = UIColor.green.cgColor
    self.layer.borderWidth = 1.0
  }
  
  func removeHighlight() {
    self.layer.borderColor = UIColor.clear.cgColor
  }
}
