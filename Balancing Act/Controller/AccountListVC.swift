//
//  AccountListVC.swift
//  Balancing Act
//
//  Created by Drew Lanning on 5/10/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import UIKit
import Firebase

class AccountListVC: UIViewController {
  
  var ref: DatabaseReference!
  var accounts: [Account] = []
  @IBOutlet weak var table: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    ref = Database.database().reference(withPath: "accounts")
    
    ref.observe(.value) { (snapshot) in
      var newAccounts: [Account] = []
      for child in snapshot.children {
        if let snapshot = child as? DataSnapshot,
          let account = Account(snapshot: snapshot) {
          newAccounts.append(account)
        }
      }
      self.accounts = newAccounts
      self.table.reloadData()
    }
    
    table.delegate = self
    table.dataSource = self
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "accountEdit" {
      let destVC = segue.destination as! CreateAccountVC
      destVC.account = self.accounts[(sender as! IndexPath).row]
    }
  }

}

extension AccountListVC: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return accounts.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    cell.textLabel?.text = accounts[indexPath.row].nickname
    return cell
  }
}

extension AccountListVC: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "accountEdit", sender: indexPath)
  }
}
