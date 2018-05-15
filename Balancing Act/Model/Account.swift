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
  var bank: String?
  var acctNumber: String?
  var nickname: String
  var startingBalance: Double
  var creation: String
  var currentBalance: Double {
    get {
      // calculate running total, return startingBalance for now
      return startingBalance
    }
  }
  
  init(bank: String?, acctNumber: String?, nickname: String, key: String = "", balance: Double) {
    self.ref = nil
    self.key = key
    self.bank = bank
    self.acctNumber = acctNumber
    self.nickname = nickname
    self.startingBalance = balance
    self.creation = Date().description
  }
  
  init?(snapshot: DataSnapshot) {
    guard
      let value = snapshot.value as? [String: AnyObject],
      let nickname = value["nickname"] as? String,
      let balance = value["startingBalance"] as? Double
      else
    { return nil }
    
    self.ref = snapshot.ref
    self.key = snapshot.key
    self.nickname = nickname
    self.bank = value["bank"] as? String
    self.acctNumber = value["acctNumber"] as? String
    self.startingBalance = balance
    self.creation = value["creation"] as! String
  }
  
  func toAnyObject() -> Any {
    return [
      "bank": bank,
      "acctNumber": acctNumber,
      "nickname": nickname,
      "startingBalance": startingBalance,
      "creation": creation
    ]
  }
}
