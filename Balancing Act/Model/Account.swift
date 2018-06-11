//
//  Account.swift
//  Balancing Act
//
//  Created by Drew Lanning on 5/9/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import Foundation
import Firebase

class Account {
  let ref: DatabaseReference?
  let key: String
  var nickname: String
  var startingBalance: Double
  var creation: String
  var currentBalance: Double?
  var reconciledBalance: Double?
  var clearedTotal: Double = 0.0
  
  init(nickname: String, key: String = "", balance: Double) {
    self.ref = nil
    self.key = key
    self.nickname = nickname
    self.startingBalance = balance
    self.currentBalance = balance
    self.reconciledBalance = balance
    self.creation = Date().description
  }
  
  init?(snapshot: DataSnapshot) {
    guard
      let value = snapshot.value as? [String: AnyObject],
      let nickname = value[Constants.AccountKeys.nickname.rawValue] as? String,
      let balance = value[Constants.AccountKeys.startingBalance.rawValue] as? Double
      else
    { print("failing out of account snap guard")
      return nil }
    
    self.ref = snapshot.ref
    self.key = snapshot.key
    self.nickname = nickname
    self.startingBalance = balance
    self.creation = value[Constants.AccountKeys.startingBalance.rawValue] as! String
    self.currentBalance = value[Constants.AccountKeys.currentBalance.rawValue] as? Double
    self.reconciledBalance = value[Constants.AccountKeys.reconciledBalance.rawValue] as? Double
  }
  
  func toAnyObject() -> Any {
    return [
      Constants.AccountKeys.nickname.rawValue: nickname,
      Constants.AccountKeys.startingBalance.rawValue: startingBalance,
      Constants.AccountKeys.creation.rawValue: creation,
      Constants.AccountKeys.currentBalance.rawValue: currentBalance as Any,
      Constants.AccountKeys.reconciledBalance.rawValue: reconciledBalance as Any
    ]
  }
  
  func setCurrentBalance(_ completion: ((Double)->())?) {
    let trxRef = self.ref?.child(Constants.FBPaths.transactions.rawValue)
    trxRef?.observeSingleEvent(of: .value, with: { (snapshot) in
      var total: Double = self.startingBalance
      for child in snapshot.children {
        if let child = child as? DataSnapshot, let trx = Transaction(snapshot: child) {
          total = trx.isDeposit! ? (total + trx.amount) : (total - trx.amount)
        }
      }
      self.currentBalance = total
      self.ref?.updateChildValues([Constants.AccountKeys.currentBalance.rawValue : self.currentBalance as Any])
      guard let action = completion else { return }
      action(total)
    })
  }
  
  func setReconciledBalance() {
    let trxRef = self.ref?.child(Constants.FBPaths.transactions.rawValue)
    trxRef?.observeSingleEvent(of: .value, with: { (snapshot) in
      var total: Double = self.startingBalance
      for child in snapshot.children {
        if let child = child as? DataSnapshot, let trx = Transaction(snapshot: child) {
          if trx.reconciled {
            total = trx.isDeposit! ? (total + trx.amount) : (total - trx.amount)
          }
        }
      }
      self.reconciledBalance = total
      self.ref?.updateChildValues([Constants.AccountKeys.reconciledBalance.rawValue : self.reconciledBalance as Any])
    })
  }
  
  func setClearedTotal(_ completion: @escaping (Double)->()) {
    let trxRef = self.ref?.child(Constants.FBPaths.transactions.rawValue)
    trxRef?.observeSingleEvent(of: .value, with: { (snapshot) in
      var total: Double = 0.0
      for child in snapshot.children {
        if let child = child as? DataSnapshot, let trx = Transaction(snapshot: child) {
          if trx.cleared && !trx.reconciled {
            total = trx.isDeposit! ? (total + trx.amount) : (total-trx.amount)
          }
        }
      }
      self.clearedTotal = total
      completion(total)
    })
  }
  
  func resetCleared() {
    self.clearedTotal = 0.0
    let trxRef = self.ref?.child(Constants.FBPaths.transactions.rawValue)
    trxRef?.observeSingleEvent(of: .value, with: { (snapshot) in
      for child in snapshot.children {
        if let child = child as? DataSnapshot, let trx = Transaction(snapshot: child) {
          if trx.cleared && !trx.reconciled {
            trx.setCleared(to: false)
          }
        }
      }
    })
  }
  
}
