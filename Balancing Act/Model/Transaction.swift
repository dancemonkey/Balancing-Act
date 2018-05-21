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
  private var _deposit: Bool!
  var isDeposit: Bool? {
    return _deposit ?? nil
  }
  private var accountLink: [String:Bool]?
  private var _reconciled: Bool
  var reconciled: Bool {
    return self._reconciled
  }
  private var _cleared: Bool
  var cleared: Bool {
    return self._cleared
  }
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
    self._reconciled = false
    self._cleared = false
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
        return nil
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    self.trxDate = formatter.date(from: trxDate)!
    
    self.ref = snapshot.ref
    self.key = snapshot.key
    self.payee = payee
    self.amount = amount
    self._reconciled = reconciled
    self._cleared = cleared
    self.category = category
    self.memo = memo
    self.accountLink = value["accountLink"] as? [String : Bool]
    self._deposit = value["deposit"] as? Bool
  }
  
  func toAnyObject() -> Any {
    return [
      "payee": payee,
      "amount": amount,
      "trxDate": trxDate.description,
      "reconciled": _reconciled,
      "cleared": _cleared,
      "memo": memo,
      "category": category,
      "accountLink": accountLink as Any,
      "deposit": _deposit as Any
    ]
  }
  
  func setReconciled(to value: Bool) {
    self._reconciled = value
    self.ref!.updateChildValues(["reconciled": self._reconciled])
  }
  
  func setCleared(to value: Bool) {
    self._cleared = value
    self.ref!.updateChildValues(["cleared": self._cleared])
  }
  
  func toggleCleared() {
    self._cleared = !self._cleared
    self.ref!.updateChildValues(["cleared": self._cleared])
  }
  
  func setAccount(account: Account) {
    accountLink = [account.key: true]
  }
  
  func setDeposit(to value: Bool) {
    self._deposit = value
  }
  
}
