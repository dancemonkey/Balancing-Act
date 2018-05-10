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
  
  init(bank: String?, acctNumber: String?, nickname: String, key: String = "") {
    self.ref = nil
    self.key = key
    self.bank = bank
    self.acctNumber = acctNumber
    self.nickname = nickname
  }
  
  init?(snapshot: DataSnapshot) {
    guard
      let value = snapshot.value as? [String: AnyObject],
      let nickname = value["nickname"] as? String
      else
    { return nil }
    
    self.ref = snapshot.ref
    self.key = snapshot.key
    self.nickname = nickname
    self.bank = value["bank"] as? String
    self.acctNumber = value["acctNumber"] as? String
  }
  
  func toAnyObject() -> Any {
    return [
      "bank": bank,
      "acctNumber": acctNumber,
      "nickname": nickname
    ]
  }
}
