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
  
  // TODO: custom XIBs for cells
  
  var ref: DatabaseReference!
  var accounts: [Account] = []
  @IBOutlet weak var table: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Accounts"
    observeChanges()
    
    table.delegate = self
    table.dataSource = self
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showAccount" {
      let destVC = segue.destination as! AccountVC
      destVC.account = self.accounts[(sender as! IndexPath).row]
    }
  }
  
  @IBAction func newAccountTapped(sender: UIBarButtonItem) {
    performSegue(withIdentifier: "newAccount", sender: self)
  }
  
  func observeChanges() {
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
    let cell = table.dequeueReusableCell(withIdentifier: "accountCell") as! AccountCell
    cell.configure(with: accounts[indexPath.row])
    return cell
  }
}

extension AccountListVC: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      performSegue(withIdentifier: "showAccount", sender: indexPath)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 55.0
  }
}
