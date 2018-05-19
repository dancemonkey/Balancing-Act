//
//  Money.swift
//  Balancing Act
//
//  Created by Drew Lanning on 5/18/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import Foundation

enum Money {
  
  static func format(amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.usesGroupingSeparator = true
    formatter.numberStyle = .currency
    formatter.locale = Locale.current
    
    return formatter.string(from: NSNumber(value: amount))!
  }
  
}
