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
    guard let userID = self.getUserID() else { return }
    _allAccountsRef = Database.database().reference(withPath: "\(userID)/accounts")
    _allTransactionsRef = Database.database().reference(withPath: "\(userID)/transactions")
  }
    
  func addNew(transaction trx: Transaction, to account: Account) {
    guard let accountRef = account.ref else { return }
    trx.setAccount(account: account)
    
    let newTrx = accountRef.child("transactions").child("\(trx.trxDate)")
    newTrx.setValue(trx.toAnyObject())
    
    let newRootTrx = _allTransactionsRef.child("\(trx.trxDate)")
    newRootTrx.setValue(trx.toAnyObject())
  }
  
  func update(values: Any?, in trx: Transaction, for account: Account) {
    let trxRef = trx.ref!
    trxRef.setValue(values)
    _allTransactionsRef.child(trx.key).setValue(values) 
  }
  
  func update(values: [AnyHashable: Any], in acct: Account) {
    _allAccountsRef.child(acct.key).updateChildValues(values)
  }
  
  func addNew(account: Account) {
    _allAccountsRef.child(account.creation).setValue(account.toAnyObject())
  }
  
  func remove(transaction: Transaction) {
    transaction.ref?.removeValue()
  }
  
  func remove(account: Account) {
    var transactionsToDelete: [Transaction] = []
    allTransactionRef.observe(.value) { (snapshot) in
      for child in snapshot.children {
        guard let trx = Transaction(snapshot: child as! DataSnapshot) else { return }
        if let acct = trx.getAccountLink(), acct.keys.first! == account.key {
          trx.ref?.removeValue()
        }
      }
    }
    
    account.ref?.removeValue()
  }
  
  func find(transaction trx: Transaction, with searchString: String) -> [Transaction] {
    // search across all transactions in app
    // -- save trx twice: once under acct and again under separate trx child under root
    // probably can't return values because async, accept array and populate instead
    return [Transaction]()
  }
  
  func setUserID(to userID: String) {
    let defaults = UserDefaults.standard
    defaults.set(userID, forKey: "userID")
  }
  
  func getUserID() -> String? {
    let defaults = UserDefaults.standard
    guard let userID = defaults.value(forKey: "userID") else { return nil }
    return (userID as! String)
  }
  
}
