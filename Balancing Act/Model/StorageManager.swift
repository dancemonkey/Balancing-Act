//
//  TrxStorageManager.swift
//  Balancing Act
//
//  Created by Drew Lanning on 4/19/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import UIKit
import CoreData

class StorageManager {
  
  var context: NSManagedObjectContext {
    get {
      let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
      context.stalenessInterval = 0
      return context
    }
  }
  
  func save() {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    appDelegate.saveContext()
  }
  
  func addNew(transaction trx: Transaction, to account: Account) {
    self.context.insert(trx)
    account.apply(transaction: trx)
  }
  
  func addNew(account: Account) {
    self.context.insert(account)
  }
}
