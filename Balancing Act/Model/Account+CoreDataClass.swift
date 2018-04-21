//
//  Account+CoreDataClass.swift
//  Balancing Act
//
//  Created by Drew Lanning on 4/19/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Account)
public class Account: NSManagedObject {
  
  var reconciledTotal: Double? {
    get {
      guard let transactions = self.transactions else {
        return nil
      }
      let reconciledTrx = transactions.filter { (trx) -> Bool in
        return (trx as! Transaction).reconciled == true
      }
      return reconciledTrx.reduce(0, { (total, trx) -> Double in
        return total + (trx as! Transaction).amount
      })
    }
  }
  
  func setup(number: Int, startingBalance: Double, bank: String, name: String) {
    self.accountNumber = Int64(number)
    self.startingBalance = startingBalance
    self.currentBalance = startingBalance
    self.bank = bank
    self.name = name
  }
  
  public override func awakeFromInsert() {
    super.awakeFromInsert()
    self.creation = Date() as NSDate
    self.currentBalance = self.startingBalance
  }
  
  func apply(transaction trx: Transaction) {
    self.addToTransactions(trx)
    self.currentBalance = self.currentBalance + trx.amount
  }
  
  func remove(transaction trx: Transaction) {
    self.removeFromTransactions(trx)
    self.currentBalance = self.currentBalance - trx.amount
    self.managedObjectContext?.delete(trx)
  }
  
  func reconcileCleared() {
    guard let transactions = self.transactions else {
      return
    }
    
    let trxToRec = transactions.filter({ (trx) -> Bool in
      return (trx as! Transaction).cleared == true && (trx as! Transaction).reconciled == false
    })
    
    trxToRec.forEach({ (trx) in
      (trx as! Transaction).reconciled = true
    })
    self.lastReconcile = Date() as NSDate
  }
  
  func getNonReconciledTrx() -> [Transaction]? {
    guard let transactions = self.transactions else {
      return nil
    }
    return transactions.filter({ (trx) -> Bool in
      return (trx as! Transaction).reconciled == false
    }) as? [Transaction]
  }
  
  override public var description: String {
    get {
      return """
      account: \(name!)
      bank: \(bank!)
      account #: \(accountNumber)
      starting balance: \(startingBalance)
      current balance: \(currentBalance)
      -=-=-=-=-=-
      """
    }
  }
  
}
