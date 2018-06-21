//
//  EditTransactionVC.swift
//  Balancing Act
//
//  Created by Drew Lanning on 5/13/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import UIKit
import Firebase
import SkyFloatingLabelTextField

class EditTransactionVC: UIViewController {
  
  // MARK: Outlets
  
  @IBOutlet weak var payee: SkyFloatingLabelTextField!
  @IBOutlet weak var amount: SkyFloatingLabelTextField!
  @IBOutlet weak var category: SkyFloatingLabelTextField!
  @IBOutlet weak var memo: SkyFloatingLabelTextField!
  @IBOutlet weak var button: UIButton!
  @IBOutlet weak var clearSwitch: UISwitch!
  @IBOutlet weak var reconcileSwitch: UISwitch!
  @IBOutlet weak var depositSwitch: UISwitch!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var dateField: UITextField!
  
  // MARK: Properties
  
  var transaction: Transaction?
  var store: Store?
  var account: Account?
  var updating: Bool = false
  var deposit: Bool = false
  var delegate: BalanceUpdateDelegate? = nil
  var rawDate: Date?
  var textFields: [UITextField]?
  
  let datePickerTag: Int = 9
  let notificationCenter = NotificationCenter.default
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    textFields = [dateField, payee, amount, category, memo]
    setupTextFieldDelegates(for: textFields!)
    
    notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    
    addInputAccessoryForTextFields(textFields: self.textFields!, dismissable: false, previousNextable: true)
    
    if let trx = transaction {
      depositSwitch.isOn = trx.isDeposit!
      setupForExisting(transaction: trx)
      self.title = trx.payee
    } else {
      clearSwitch.setOn(false, animated: true)
      reconcileSwitch.setOn(false, animated: true)
      self.title = "New Transaction"
      self.rawDate = Date()
      dateField.text = simpleDate(from: Date())
    }
    
    setUIColors()
    
  }
  
  // MARK: Helper Functions
  
  func setupForExisting(transaction trx: Transaction) {
    payee.text = trx.payee
    self.amount.text = "\(Money.decimalFormat(amount: trx.amount))"
    dateField.text = trx.simpleDate
    rawDate = trx.trxDate
    category.text = trx.category
    memo.text = trx.memo
    button.setTitle("UPDATE", for: .normal)
    clearSwitch.setOn(trx.cleared, animated: true)
    reconcileSwitch.setOn(trx.reconciled, animated: true)
    depositSwitch.isOn = trx.isDeposit ?? false
    dateField.text = trx.simpleDate
  }
  
  func setUIColors() {
    let altBlack = UIColor(named: Constants.Colors.altBlack.rawValue)
    button.backgroundColor = UIColor(named: Constants.Colors.primary.rawValue)
    
    for sw in [clearSwitch, reconcileSwitch, depositSwitch] {
      sw?.onTintColor = UIColor(named: Constants.Colors.primary.rawValue)
    }
    
    if let fields = textFields {
      for field in fields {
        field.textColor = altBlack
      }
    }
  }
  
  func createTransaction() {
    guard let payee = payee.text,
    let amount = Double(amount.text!)
      else { return }
    
    if let trx = self.transaction, let acct = self.account {
      updating = true
      let store = Store()
      let values = [
        Constants.TrxKeys.payee.rawValue: payee,
        Constants.TrxKeys.amount.rawValue: amount,
        Constants.TrxKeys.trxDate.rawValue: self.rawDate?.description ?? Date().description,
        Constants.TrxKeys.category.rawValue: self.category.text!,
        Constants.TrxKeys.memo.rawValue: self.memo.text!,
        Constants.TrxKeys.cleared.rawValue: trx.cleared,
        Constants.TrxKeys.reconciled.rawValue: trx.reconciled,
        Constants.TrxKeys.accountLink.rawValue: [acct.key : true],
        Constants.TrxKeys.deposit.rawValue: depositSwitch.isOn
        ] as [String : Any]
      store.update(values: values, in: trx, for: acct)
    } else {
      self.transaction = Transaction(payee: payee, amount: amount, category: category.text, memo: memo.text, date: rawDate ?? Date())
      self.transaction?.setDeposit(to: depositSwitch.isOn)
    }
  }
  
  @objc func adjustForKeyboard(notification: NSNotification) {
    let userInfo = notification.userInfo!
    
    let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
    
    if notification.name == Notification.Name.UIKeyboardWillHide {
      scrollView.contentInset = UIEdgeInsets.zero
    } else {
      scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
    }
    
    scrollView.scrollIndicatorInsets = scrollView.contentInset
  }
  
  func simpleDate(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd/yyyy"
    return formatter.string(from: date)
  }
  
  // MARK: Segues
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Constants.SegueIDs.showDatePicker.rawValue {
      let destVC = segue.destination as! DatePickerVC
      destVC.date = rawDate ?? Date()
      destVC.delegate = self
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
    delegate?.updateAccountBalance()
    navigationController?.popViewController(animated: true)
  }
  
  @IBAction func cancel(sender: UIButton) {
    navigationController?.popViewController(animated: true)
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
  
  @IBAction func setDatePressed(sender: UIButton) {
    performSegue(withIdentifier: Constants.SegueIDs.showDatePicker.rawValue, sender: self)
  }
  
  @IBAction func depositSwitched(sender: UISwitch) {
    
  }

}

// MARK: Extensions

extension EditTransactionVC: DateSelectDelegate {
  func save(date: Date) {
    self.rawDate = date
    self.dateField.text = simpleDate(from: date)
    dateField.removeHighlight()
    dateField.resignFirstResponder()
  }
}

extension EditTransactionVC: UITextFieldDelegate {
  func setupTextFieldDelegates(for fields: [UITextField]) {
    for field in fields {
      field.delegate = self
    }
  }
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    textField.highlight()
    if textField.tag == datePickerTag {
      performSegue(withIdentifier: Constants.SegueIDs.showDatePicker.rawValue, sender: self)
      return false
    }
    return true
  }
  
  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    textField.removeHighlight()
    return true
  }
  
}
