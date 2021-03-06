//
//  TestViewController.swift
//  Balancing Act
//
//  Created by Drew Lanning on 4/21/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import UIKit
import Firebase

class CreateAccountVC: UIViewController {
  
  // MARK: Outlets
  @IBOutlet weak var nicknameField: UITextField!
  @IBOutlet weak var button: UIButton!
  @IBOutlet weak var startingBalance: UITextField!
  
  // MARK: Properties
  var ref: DatabaseReference!
  var account: Account?
  var store: Store!
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    self.store = Store()
    ref = store.allAccountsRef 
    if let account = self.account {
      nicknameField.text = account.nickname
      startingBalance.text = Money.decimalFormat(amount: account.startingBalance)
      button.setTitle("UPDATE", for: .normal)
      self.title = account.nickname
    } else {
      self.title = "New Account"
    }
    
    addInputAccessoryForTextFields(textFields: [nicknameField, startingBalance], dismissable: false, previousNextable: true)
    
    setUIColors()
  }
  
  // MARK: Actions
  
  @IBAction func createAccountTouched(sender: UIButton) {
    guard let nickname = nicknameField.text, let balance = startingBalance.text else { return }
    if let existingAccount = self.account {
      let values = [
        Constants.AccountKeys.nickname.rawValue : nickname,
        Constants.AccountKeys.startingBalance.rawValue : Double(balance) as Any,
        Constants.AccountKeys.currentBalance.rawValue : existingAccount.clearedTotal as Any,
        Constants.AccountKeys.reconciledBalance.rawValue : existingAccount.reconciledBalance as Any
        ] as [String : Any]
      store.update(values: values, in: existingAccount)
    } else {
      let account = Account(nickname: nickname,
                            balance: Double(balance)!)
      store.addNew(account: account)
    }
    clearFields()
    navigationController?.popViewController(animated: true)
  }
  
  @IBAction func cancel(sender: UIButton) {
    navigationController?.popViewController(animated: true)
  }
  
  // MARK: Helper Functions
  
  func clearFields() {
    nicknameField.text = ""
    startingBalance.text = ""
  }
  
  func setUIColors() {
    let altBlack = UIColor(named: Constants.Colors.altBlack.rawValue)
    button.backgroundColor = UIColor(named: Constants.Colors.primary.rawValue)
    nicknameField.textColor = altBlack
    startingBalance.textColor = altBlack
  }
  
}
