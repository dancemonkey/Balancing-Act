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
  var deposit: Bool = false
  
  @IBOutlet weak var payee: UITextField!
  @IBOutlet weak var amount: UITextField!
  @IBOutlet weak var date: UIDatePicker!
  @IBOutlet weak var category: UITextField!
  @IBOutlet weak var memo: UITextField!
  @IBOutlet weak var button: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let trx = transaction {
      var amount: Double
      if trx.amount < 0 {
        // set deposit switch to false
        amount = -trx.amount
      } else {
        // set deposit switch to true
        amount = trx.amount
      }
      payee.text = trx.payee
      self.amount.text = "\(amount)"
      date.date = trx.trxDate
      category.text = trx.category
      memo.text = trx.memo
      button.setTitle("UPDATE", for: .normal)
    }
  }
  
  func createTransaction() {
    guard let payee = payee.text,
    var amount = Double(amount.text!)
      else { return }
    if !deposit {
      amount = -amount
    }
    
    if let trx = self.transaction, let acct = self.account {
      updating = true
      let store = Store()
      let values = [
        "payee": payee,
        "amount": amount,
        "trxDate": self.date.date.description,
        "category": self.category.text!,
        "memo": self.memo.text!,
        "cleared": trx.cleared,
        "reconciled": trx.reconciled
        ] as [String : Any]
      store.update(values: values, for: trx, in: acct)
//      let trxRef = trx.ref!
//      trxRef.setValue([
//        "payee": payee,
//        "amount": amount,
//        "trxDate": self.date.date.description,
//        "category": self.category.text!,
//        "memo": self.memo.text!,
//        "cleared": trx.cleared,
//        "reconciled": trx.reconciled
//        ])
//      account?.setCurrentBalance()
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
