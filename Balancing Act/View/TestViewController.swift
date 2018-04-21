//
//  TestViewController.swift
//  Balancing Act
//
//  Created by Drew Lanning on 4/21/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import UIKit
import CoreData

class TestViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let account = Account(context: context)
    account.setup(number: 0288960213, startingBalance: 1000.00, bank: "Bank Of America", name: "Checking")
    print(account)
    
    let firstTrx = Transaction(context: context)
    firstTrx.setup(type: .deposit, number: 0, amount: 100.00, date: Date(), category: "gratuity")
    print(firstTrx)
    
    account.apply(transaction: firstTrx)
    print(account)
    
    account.remove(transaction: firstTrx)
    print(account)
  }
  
}
