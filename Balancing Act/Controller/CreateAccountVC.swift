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
    }
  }
  
  // MARK: Actions
  
  @IBAction func createAccountTouched(sender: UIButton) {
    guard let nickname = nicknameField.text, let balance = startingBalance.text else { return }
    if let existingAccount = self.account {
      let values = [
        "nickname" : nickname,
        "startingBalance" : Double(balance) as Any,
        "currentBalance": existingAccount.clearedTotal as Any,
        "reconciledBalance": existingAccount.reconciledBalance as Any
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
  
}
