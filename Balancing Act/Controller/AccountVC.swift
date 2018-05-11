//
//  AccountVC.swift
//  Balancing Act
//
//  Created by Drew Lanning on 5/11/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import UIKit
import Firebase

class AccountVC: UIViewController {
  
  var account: Account?
  var table: UITableView!
  var trxRef: DatabaseReference!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = account!.nickname
    
    let accountsRef = Database.database().reference(withPath: "accounts")
    let thisAccountRef = accountsRef.child(account!.key)
    trxRef = thisAccountRef.child("transactions")
    
    print(trxRef)
  }
  
  @IBAction func newTransaction(sender: UIBarButtonItem) {
    let newTrx = Transaction(payee: "Giant Eagle", amount: 99.88)
    let ref = self.trxRef.child("\(newTrx.date)")
    ref.setValue(newTrx.toAnyObject())
  }
  
}

extension AccountVC: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return UITableViewCell()
  }
  
}

extension AccountVC: UITableViewDelegate {
  
}
