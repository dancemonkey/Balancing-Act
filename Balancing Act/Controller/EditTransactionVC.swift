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
  
  // MARK: Outlets
  
  @IBOutlet weak var payee: UITextField!
  @IBOutlet weak var amount: UITextField!
  @IBOutlet weak var date: UIDatePicker!
  @IBOutlet weak var category: UITextField!
  @IBOutlet weak var memo: UITextField!
  @IBOutlet weak var button: UIButton!
  @IBOutlet weak var clearSwitch: UISwitch!
  @IBOutlet weak var reconcileSwitch: UISwitch!
  @IBOutlet weak var depositSwitch: UISwitch!
  
  // MARK: Properties
  
  var transaction: Transaction?
  var store: Store?
  var account: Account?
  var updating: Bool = false
  var deposit: Bool = false
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let trx = transaction {
      depositSwitch.isOn = trx.isDeposit!
      setupForExisting(transaction: trx)
      self.title = trx.payee
    } else {
      clearSwitch.setOn(false, animated: true)
      reconcileSwitch.setOn(false, animated: true)
      self.title = "New Transaction"
    }
  }
  
  // MARK: Helper Functions
  
  func setupForExisting(transaction trx: Transaction) {
    payee.text = trx.payee
    self.amount.text = "\(Money.decimalFormat(amount: trx.amount))"
    date.date = trx.trxDate
    category.text = trx.category
    memo.text = trx.memo
    button.setTitle("UPDATE", for: .normal)
    clearSwitch.setOn(trx.cleared, animated: true)
    reconcileSwitch.setOn(trx.reconciled, animated: true)
    depositSwitch.isOn = trx.isDeposit ?? false
  }
  
  func createTransaction() {
    guard let payee = payee.text,
    let amount = Double(amount.text!)
      else { return }
    
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
        "reconciled": trx.reconciled,
        "accountLink": [acct.key : true],
        "deposit": depositSwitch.isOn
        ] as [String : Any]
      store.update(values: values, in: trx, for: acct)
    } else {
      self.transaction = Transaction(payee: payee, amount: amount, category: category.text, memo: memo.text, date: date.date)
      self.transaction?.setDeposit(to: depositSwitch.isOn)
    }
  }
  
  // MARK: Actions
  
  @IBAction func done(sender: UIButton) {
    createTransaction()
    if !updating, let trx = self.transaction, let acct = self.account {
      let store = Store()
      trx.setDeposit(to: depositSwitch.isOn)
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
  
  @IBAction func clearSwitchTapped(sender: UISwitch) {
    if let trx = self.transaction {
      trx.setCleared(to: clearSwitch.isOn)
      if !clearSwitch.isOn {
        trx.setReconciled(to: clearSwitch.isOn)
        reconcileSwitch.setOn(clearSwitch.isOn, animated: true)
      }
    }
    account?.setReconciledBalance()
  }
  
  @IBAction func reconcileSwitchTapped(sender: UISwitch) {
    if let trx = self.transaction {
      trx.setReconciled(to: reconcileSwitch.isOn)
      if reconcileSwitch.isOn {
        clearSwitch.setOn(reconcileSwitch.isOn, animated: true)
        trx.setCleared(to: reconcileSwitch.isOn)
      }
    }
    account?.setReconciledBalance()
  }
  
  @IBAction func depositSwitched(sender: UISwitch) {
    
  }
  
}
