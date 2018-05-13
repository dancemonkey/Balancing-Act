//
//  TrxStorageManager.swift
//  Balancing Act
//
//  Created by Drew Lanning on 4/19/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import UIKit
import Firebase

class Store {
  
  private var allAccountsRef: DatabaseReference!
  private var accountRef: DatabaseReference!
  
  init() {
    allAccountsRef = Database.database().reference(withPath: "accounts")
  }
  
  func addNew(transaction trx: Transaction, to account: Account) {
    accountRef = allAccountsRef.child(account.key)
    let trxRef = accountRef.child("transactions")
    let newTrx = trxRef.child("\(trx.trxDate)")
    newTrx.setValue(trx.toAnyObject())    
  }
  
  func addNew(account: Account) {
    accountRef = allAccountsRef.child(account.nickname.lowercased())
    accountRef.setValue(account.toAnyObject())
  }
  
  func getUnreconciledTrx(from account: Account) -> [Transaction] {
    accountRef = allAccountsRef.child(account.key)
    return [Transaction]()
  }
  
  func removeTransaction(_: Transaction) {
    
  }
  
  func removeAccount(_: Account) {
    
  }
  
  func find(transaction trx: Transaction, with searchString: String) -> [Transaction] {
    return [Transaction]()
  }
  
}
