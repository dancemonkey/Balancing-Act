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
  
  // MARK: Outlets
  @IBOutlet weak var table: UITableView!

  // MARK: Properties
  var ref: DatabaseReference!
  var accounts: [Account] = []
  var store: Store?
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Accounts"
    store = Store()
    observeChanges()

    table.delegate = self
    table.dataSource = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  // MARK: Segues
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showAccount" {
      let destVC = segue.destination as! AccountVC
      destVC.account = self.accounts[(sender as! IndexPath).row]
    } else if segue.identifier == "accountEdit" {
      let destVC = segue.destination as! CreateAccountVC
      destVC.account = (sender as! Account)
    }
  }
  
  // MARK: Actions
  
  @IBAction func newAccountTapped(sender: UIBarButtonItem) {
    performSegue(withIdentifier: "newAccount", sender: self)
  }
  
  // MARK: Helper Functions
  
  func observeChanges() {
    ref = store?.allAccountsRef
    print("ref: \(ref)")
    ref.observe(.value) { (snapshot) in
      print("value observed")
      var newAccounts: [Account] = []
      for child in snapshot.children {
        print("child: \(child)")
        if let snapshot = child as? DataSnapshot,
          let account = Account(snapshot: snapshot) {
          print("account: \(account)")
          newAccounts.append(account)
        }
      }
      self.accounts = newAccounts
      self.table.reloadData()
    }
  }

}

// MARK: Extensions

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
  
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let delete = UITableViewRowAction(style: .destructive, title: "delete") { (action, indexPath) in
      let store = Store()
      store.remove(account: self.accounts[indexPath.row])
    }
    
    let edit = UITableViewRowAction(style: .normal, title: "edit") { (action, indexPath) in
      self.performSegue(withIdentifier: "accountEdit", sender: self.accounts[indexPath.row])
    }
    
    return [delete, edit]
  }
}
