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
  @IBOutlet weak var acctNumberField: UITextField!
  @IBOutlet weak var nicknameField: UITextField!
  @IBOutlet weak var button: UIButton!
  
  var ref: DatabaseReference!
  var account: Account?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    ref = Database.database().reference(withPath: "accounts")
    if let account = self.account {
      bankField.text = account.bank!
      acctNumberField.text = account.acctNumber!
      nicknameField.text = account.nickname
      button.setTitle("Update Account", for: .normal)
    }
  }
  
  @IBAction func createAccountTouched(sender: UIButton) {
    guard let nickname = nicknameField.text else { return }
    
    let account = Account(bank: bankField.text,
                          acctNumber: acctNumberField.text,
                          nickname: nickname)
    
    let accountRef = self.ref.child(nickname.lowercased())
    accountRef.setValue(account.toAnyObject())
    clearFields()
    navigationController?.popViewController(animated: true)
  }
  
  func clearFields() {
    bankField.text = ""
    acctNumberField.text = ""
    nicknameField.text = ""
  }
  
}
