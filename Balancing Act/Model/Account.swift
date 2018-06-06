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
      let nickname = value["nickname"] as? String,
      let balance = value["startingBalance"] as? Double
      else
    { print("failing out of account snap guard")
      return nil }
    
    self.ref = snapshot.ref
    self.key = snapshot.key
    self.nickname = nickname
    self.startingBalance = balance
    self.creation = value["creation"] as! String
    self.currentBalance = value["currentBalance"] as? Double
    self.reconciledBalance = value["reconciledBalance"] as? Double
  }
  
  func toAnyObject() -> Any {
    return [
      "nickname": nickname,
      "startingBalance": startingBalance,
      "creation": creation,
      "currentBalance": currentBalance as Any,
      "reconciledBalance": reconciledBalance as Any
    ]
  }
  
  func setCurrentBalance(_ completion: ((Double)->())?) {
    let trxRef = self.ref?.child("transactions")
    trxRef?.observeSingleEvent(of: .value, with: { (snapshot) in
      var total: Double = self.startingBalance
      for child in snapshot.children {
        if let child = child as? DataSnapshot, let trx = Transaction(snapshot: child) {
          total = trx.isDeposit! ? (total + trx.amount) : (total - trx.amount)
        }
      }
      self.currentBalance = total
      self.ref?.updateChildValues(["currentBalance" : self.currentBalance as Any])
      guard let action = completion else { return }
      action(total)
    })
  }
  
  func setReconciledBalance() {
    let trxRef = self.ref?.child("transactions")
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
      self.ref?.updateChildValues(["reconciledBalance" : self.reconciledBalance as Any])
    })
  }
  
  func setClearedTotal(_ completion: @escaping (Double)->()) {
    let trxRef = self.ref?.child("transactions")
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
    let trxRef = self.ref?.child("transactions")
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
