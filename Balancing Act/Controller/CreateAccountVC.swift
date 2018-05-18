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
  
  @IBOutlet weak var bankField: UITextField!
  @IBOutlet weak var nicknameField: UITextField!
  @IBOutlet weak var button: UIButton!
  @IBOutlet weak var startingBalance: UITextField!
  
  var ref: DatabaseReference!
  var account: Account?
  var store: Store!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.store = Store()
    ref = Database.database().reference(withPath: "accounts")
    if let account = self.account {
      bankField.text = account.bank!
      nicknameField.text = account.nickname
      button.setTitle("Update Account", for: .normal)
    }
  }
  
  @IBAction func createAccountTouched(sender: UIButton) {
    guard let nickname = nicknameField.text, let balance = startingBalance.text else { return }
    
    let account = Account(bank: bankField.text,
                          nickname: nickname,
                          balance: Double(balance)!)
    store.addNew(account: account)
    clearFields()
    navigationController?.popViewController(animated: true)
  }
  
  func clearFields() {
    bankField.text = ""
    nicknameField.text = ""
    startingBalance.text = ""
  }
  
}
