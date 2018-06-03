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
  
  func export(sender: IndexPath) {
    let account = self.accounts[sender.row]
    let fileName = "\(account.nickname).csv"
    let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
    
    var csvText: String = "Starting Balance: \(account.startingBalance)\n"
    csvText.append("Date,Payee,Category,Memo,Cleared,Debit,Credit\n")
    
    observeAndWriteTransactions(for: account) { (trx) in
      // get list of trx from FB for this account
      let transactions: [Transaction] = trx
      
      // write trx data to text file
      let count = transactions.count
      
      if count > 0 {
        for trx in transactions {
          csvText.append(
            "\(trx.simpleDate),\(trx.payee),\(trx.category),\(trx.memo),\(trx.cleared),"
          )
          let deposit: Bool = trx.isDeposit ?? false
          if !deposit {
            csvText.append("\(trx.amount),\n")
          } else {
            csvText.append(",\(trx.amount)\n")
          }
        }
        
        // save text file to temp directory and share with ActivityVC
        do {
          try csvText.write(to: path, atomically: true, encoding: String.Encoding.utf8)
          let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
          vc.excludedActivityTypes = [
            UIActivityType.assignToContact,
            UIActivityType.saveToCameraRoll,
            UIActivityType.postToVimeo,
            UIActivityType.postToWeibo,
            UIActivityType.postToFlickr,
            UIActivityType.postToTwitter,
            UIActivityType.postToFacebook,
            UIActivityType.postToTencentWeibo,
            UIActivityType.openInIBooks
          ]
          DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
          }
        } catch {
          print("failed to create file")
          print(error)
        }
      } else {
        print("no data to export")
      }
    }
    
  }
  
  func observeAndWriteTransactions(for account: Account, completion: @escaping ([Transaction]) -> ()) {
    var trx: [Transaction] = []
    let trxRef: DatabaseQuery? = account.ref?.child("transactions").queryOrdered(byChild: "creation")
    trxRef?.observeSingleEvent(of: .value, with: { (snapshot) in
      for child in snapshot.children {
        guard let snap = child as? DataSnapshot else { return }
        let transaction = Transaction(snapshot: snap)
        trx.append(transaction!)
      }
      completion(trx)
    })
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
  
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
      let store = Store()
      store.remove(account: self.accounts[indexPath.row])
    }
    delete.image = UIImage(named: "trash3")!
    
    let edit = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
      self.performSegue(withIdentifier: "accountEdit", sender: self.accounts[indexPath.row])
    }
    edit.image = UIImage(named: "edit")!
    
    let exportAction = UIContextualAction(style: .normal, title: "Export") { (action, view, completion) in
      self.export(sender: indexPath)
    }
    exportAction.backgroundColor = .blue
    exportAction.image = UIImage(named: "export")!
    
    return UISwipeActionsConfiguration(actions: [exportAction, edit, delete])
  }
}
