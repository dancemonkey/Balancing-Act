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
  var creation: Date
  var reconciled: Bool
  var cleared: Bool
  var simpleDate: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd/yyyy"
    return formatter.string(from: creation)
  }
  
  init(payee: String, amount: Double, key: String = "") {
    self.ref = nil
    self.payee = payee
    self.amount = amount
    self.key = key
    self.creation = Date()
    self.reconciled = false
    self.cleared = false
  }
  
  init?(snapshot: DataSnapshot) {
    guard
      let value = snapshot.value as? [String: AnyObject],
      let payee = value["payee"] as? String,
      let amount = value["amount"] as? Double,
      let creation = value["creation"] as? String,
      let reconciled = value["reconciled"] as? Bool,
      let cleared = value["cleared"] as? Bool
      else {
        print("failing out of Transaction guard")
        return nil }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    self.creation = formatter.date(from: creation)!
    
    self.ref = snapshot.ref
    self.key = snapshot.key
    self.payee = payee
    self.amount = amount
    self.reconciled = reconciled
    self.cleared = cleared
  }
  
  func toAnyObject() -> Any {
    return [
      "payee": payee,
      "amount": amount,
      "creation": creation.description,
      "reconciled": reconciled,
      "cleared": cleared
    ]
  }
  
}
