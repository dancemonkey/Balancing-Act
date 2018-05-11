//
//  Transaction.swift
//  Balancing Act
//
//  Created by Drew Lanning on 5/9/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import Foundation
import Firebase

class Transaction {
  let ref: DatabaseReference?
  let key: String
  var payee: String
  var amount: Double
  var date: Date
  
  init(payee: String, amount: Double, key: String = "") {
    self.ref = nil
    self.payee = payee
    self.amount = amount
    self.key = key
    self.date = Date()
  }
  
  init?(snapshot: DataSnapshot) {
    guard
      let value = snapshot.value as? [String: AnyObject],
      let payee = value["payee"] as? String,
      let amount = value["amount"] as? Double
      else { return nil }
    
    self.ref = snapshot.ref
    self.key = snapshot.key
    self.payee = payee
    self.amount = amount
    self.date = Date()
  }
  
  func toAnyObject() -> Any {
    return [
      "payee": payee,
      "amount": amount,
    ]
  }
  
}
