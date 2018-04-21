//
//  Transaction+CoreDataClass.swift
//  Balancing Act
//
//  Created by Drew Lanning on 4/19/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//
//

import Foundation
import CoreData

enum TrxType: Int16 {
  case deposit = 0, fee, transferIn, transferOut, ach, atm
}

@objc(Transaction)
public class Transaction: NSManagedObject {
  
  public override func awakeFromInsert() {
    super.awakeFromInsert()
    self.creation = Date() as NSDate
    self.cleared = false
    self.reconciled = false
    self.split = false
  }
  
  func setup(type: TrxType, number: Int, amount: Double, date: Date, category: String?) {
    self.type = type.rawValue
    self.number = Int16(number)
    self.amount = amount
    self.date = date as NSDate
    self.category = category
  }
  
  func setType(as type: TrxType) {
    self.type = type.rawValue
  }
  
  func extractType(from type: Int16) -> TrxType {
    return TrxType(rawValue: type)!
  }

  func clear() {
    self.cleared = !self.cleared
  }
  
  func reconcile() {
    self.reconciled = !reconciled
  }
  
  func setTrxNumber(to num: Int) {
    self.number = Int16(num)
  }
  
  func split(using transactions: [Transaction]) {
    self.split = true
    self.splitTransactions = NSSet(array: transactions)
  }
  
  func removeSplit() {
    self.split = false
    self.splitTransactions = nil
  }
  
  func getAmount() -> Double {
    if split {
      return splitTransactions!.reduce(0, { (total, trx) -> Double in
        return total + (trx as! Transaction).getAmount()
      })
    } else {
      return self.getAmount()
    }
  }
  
  func getCategory() -> [String] {
    if split {
      return splitTransactions!.map({ (trx) -> String in
        return (trx as! Transaction).category!
      })
    } else {
      return [self.category ?? "uncategorized"]
    }
  }
  
  override public var description: String {
    get {
      if split {
        return """
        type: \(TrxType.init(rawValue: type)!)
        amount: \(self.amount)
        date: \(String(describing: self.date!))
        category: \(self.splitTransactions!)
        cleared: \(self.cleared)
        reconciled: \(self.reconciled)
        -=-=-=-=-=-
        """
      } else {
        return """
        type: \(TrxType.init(rawValue: type)!)
        amount: \(self.amount)
        date: \(String(describing: self.date!))
        category: \(String(describing: self.category!))
        cleared: \(self.cleared)
        reconciled: \(self.reconciled)
        -=-=-=-=-=-
        """
      }
    }
  }
  
}
