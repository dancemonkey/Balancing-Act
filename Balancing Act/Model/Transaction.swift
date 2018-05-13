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
  var trxDate: Date
  var category: String
  var memo: String
  var reconciled: Bool
  var cleared: Bool
  var simpleDate: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd/yyyy"
    return formatter.string(from: trxDate)
  }
  
  init(payee: String, amount: Double, key: String = "", category: String?, memo: String?, date: Date?) {
    self.ref = nil
    self.payee = payee
    self.amount = amount
    self.key = key
    self.trxDate = date ?? Date()
    self.reconciled = false
    self.cleared = false
    self.memo = memo ?? ""
    self.category = category ?? ""
  }
  
  init?(snapshot: DataSnapshot) {
    guard
      let value = snapshot.value as? [String: AnyObject],
      let payee = value["payee"] as? String,
      let amount = value["amount"] as? Double,
      let trxDate = value["trxDate"] as? String,
      let reconciled = value["reconciled"] as? Bool,
      let memo = value["memo"] as? String,
      let category = value["category"] as? String,
      let cleared = value["cleared"] as? Bool
      else {
        print("failing out of Transaction guard")
        return nil }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    self.trxDate = formatter.date(from: trxDate)!
    
    self.ref = snapshot.ref
    self.key = snapshot.key
    self.payee = payee
    self.amount = amount
    self.reconciled = reconciled
    self.cleared = cleared
    self.category = category
    self.memo = memo
  }
  
  func toAnyObject() -> Any {
    return [
      "payee": payee,
      "amount": amount,
      "trxDate": trxDate.description,
      "reconciled": reconciled,
      "cleared": cleared,
      "memo": memo,
      "category": category
    ]
  }
  
}
