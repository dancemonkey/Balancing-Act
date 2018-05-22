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
  
  private var _allAccountsRef: DatabaseReference!
  var allAccountsRef: DatabaseReference {
    return _allAccountsRef
  }
  private var _allTransactionsRef: DatabaseReference!
  var allTransactionRef: DatabaseReference {
    return _allTransactionsRef
  }
  private var _accountRef: DatabaseReference!

  init() {
    _allAccountsRef = Database.database().reference(withPath: "accounts")
    _allTransactionsRef = Database.database().reference(withPath: "transactions")
  }
    
  func addNew(transaction trx: Transaction, to account: Account) {
    guard let accountRef = account.ref else { return }
    trx.setAccount(account: account)
    
    let newTrx = accountRef.child("transactions").child("\(trx.trxDate)")
    newTrx.setValue(trx.toAnyObject())
    account.setCurrentBalance()
    
    let newRootTrx = _allTransactionsRef.child("\(trx.trxDate)")
    newRootTrx.setValue(trx.toAnyObject())
  }
  
  func update(values: Any?, in trx: Transaction, for account: Account) {
    let trxRef = trx.ref!
    trxRef.setValue(values)
    _allTransactionsRef.child(trx.key).setValue(values) 
    account.setCurrentBalance()
  }
  
  func addNew(account: Account) {
    _allAccountsRef.child(account.creation).setValue(account.toAnyObject())
  }
  
  func remove(transaction: Transaction) {
    transaction.ref?.removeValue()
  }
  
  func remove(account: Account) {
    account.ref?.removeValue()
  }
  
  func find(transaction trx: Transaction, with searchString: String) -> [Transaction] {
    // search across all transactions in app
    // -- save trx twice: once under acct and again under separate trx child under root
    // probably can't return values because async, accept array and populate instead
    return [Transaction]()
  }
  
}
