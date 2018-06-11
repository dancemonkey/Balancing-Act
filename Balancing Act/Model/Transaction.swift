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
      let payee = value[Constants.TrxKeys.payee.rawValue] as? String,
      let amount = value[Constants.TrxKeys.amount.rawValue] as? Double,
      let trxDate = value[Constants.TrxKeys.trxDate.rawValue] as? String,
      let reconciled = value[Constants.TrxKeys.reconciled.rawValue] as? Bool,
      let memo = value[Constants.TrxKeys.memo.rawValue] as? String,
      let category = value[Constants.TrxKeys.category.rawValue] as? String,
      let cleared = value[Constants.TrxKeys.cleared.rawValue] as? Bool
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
    self.accountLink = value[Constants.TrxKeys.accountLink.rawValue] as? [String : Bool]
    self._deposit = value[Constants.TrxKeys.deposit.rawValue] as? Bool
  }
  
  func toAnyObject() -> Any {
    return [
      Constants.TrxKeys.payee.rawValue: payee,
      Constants.TrxKeys.amount.rawValue: amount,
      Constants.TrxKeys.trxDate.rawValue: trxDate.description,
      Constants.TrxKeys.reconciled.rawValue: _reconciled,
      Constants.TrxKeys.cleared.rawValue: _cleared,
      Constants.TrxKeys.memo.rawValue: memo,
      Constants.TrxKeys.category.rawValue: category,
      Constants.TrxKeys.accountLink.rawValue: accountLink as Any,
      Constants.TrxKeys.deposit.rawValue: _deposit as Any
    ]
  }
  
  func setReconciled(to value: Bool) {
    self._reconciled = value
    self.ref!.updateChildValues([Constants.TrxKeys.reconciled.rawValue: self._reconciled])
  }
  
  func setCleared(to value: Bool) {
    self._cleared = value
    self.ref!.updateChildValues([Constants.TrxKeys.cleared.rawValue: self._cleared])
  }
  
  func toggleCleared() {
    self._cleared = !self._cleared
    self.ref!.updateChildValues([Constants.TrxKeys.cleared.rawValue: self._cleared])
  }
  
  func setAccount(account: Account) {
    accountLink = [account.key: true]
  }
  
  func setDeposit(to value: Bool) {
    self._deposit = value
  }
  
  func getAccountLink() -> [String: Bool]? {
    if let acct = self.accountLink {
      return acct
    } else {
      return nil
    }
  }
  
}
