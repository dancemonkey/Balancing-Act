//
//  EditTransactionVC.swift
//  Balancing Act
//
//  Created by Drew Lanning on 5/13/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import UIKit
import Firebase

class EditTransactionVC: UIViewController {
  
  var transaction: Transaction?
  var store: Store?
  var account: Account?
  var updating: Bool = false
  
  @IBOutlet weak var payee: UITextField!
  @IBOutlet weak var amount: UITextField!
  @IBOutlet weak var date: UIDatePicker!
  @IBOutlet weak var category: UITextField!
  @IBOutlet weak var memo: UITextField!
  @IBOutlet weak var button: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let trx = transaction {
      payee.text = trx.payee
      amount.text = "\(trx.amount)"
      date.date = trx.trxDate
      category.text = trx.category
      memo.text = trx.memo
      button.setTitle("UPDATE", for: .normal)
    }
  }
  
  func createTransaction() {
    guard let payee = payee.text,
    let amount = Double(amount.text!)
      else { return }
    
    if let trx = self.transaction {
      updating = true
      let trxRef = trx.ref! 
      trxRef.setValue([
        "payee": payee,
        "amount": amount,
        "trxDate": self.date.date.description,
        "category": self.category.text!,
        "memo": self.memo.text!,
        "cleared": trx.cleared,
        "reconciled": trx.reconciled
        ])
    } else {
      self.transaction = Transaction(payee: payee, amount: amount, category: category.text, memo: memo.text, date: date.date)
    }
  }
  
  @IBAction func done(sender: UIButton) {
    createTransaction()
    if !updating, let trx = self.transaction, let acct = self.account {
      let store = Store()
      store.addNew(transaction: trx, to: acct)
    }
    navigationController?.popViewController(animated: true)
  }
  
  @IBAction func clear() {
    for view in view.subviews {
      if view is UITextField {
        (view as! UITextField).text = ""
      }
      date.date = Date()
    }
  }
  
}
