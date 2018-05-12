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
  
  // MARK: Properties
  @IBOutlet weak var table: UITableView!
  var trxRef: DatabaseQuery!
  var transactions: [Transaction] = []
  var unreconciledTrx: [Transaction] = []
  var reconcileMode: Bool = false
  var account: Account?
  var store: Store!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = account!.nickname
    self.store = Store()
    table.delegate = self
    table.dataSource = self
    
    let accountsRef = Database.database().reference(withPath: "accounts")
    let thisAccountRef = accountsRef.child(account!.key)
    trxRef = thisAccountRef.child("transactions").queryOrdered(byChild: "creation")
    observeChanges()
  }
  
  @IBAction func newTransaction(sender: UIBarButtonItem) {
    let newTrx = Transaction(payee: "Giant Eagle", amount: 99.88)
    store.addNew(transaction: newTrx, to: self.account!)
  }
  
  @IBAction func reconcileModeTapped(sender: UIBarButtonItem) {
    unreconciledTrx = transactions.filter({ (trx) -> Bool in
      return trx.reconciled == false
    })
    reconcileMode = !reconcileMode
    table.reloadData()
  }
  
}

extension AccountVC: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return (reconcileMode == false) ? transactions.count : unreconciledTrx.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let trx = reconcileMode == false ? transactions[indexPath.row] : unreconciledTrx[indexPath.row]
    let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
    cell.textLabel?.text = trx.payee
    cell.detailTextLabel?.text = "\(trx.simpleDate) - $\(trx.amount)"
    return cell
  }
  
}

extension AccountVC: UITableViewDelegate {
  func observeChanges() {
    trxRef.observe(.value) { (snapshot) in
      var newTrx: [Transaction] = []
      for child in snapshot.children {
        if let snapshot = child as? DataSnapshot,
          let trx = Transaction(snapshot: snapshot) {
          newTrx.append(trx)
        }
      }
      self.transactions = newTrx
      self.table.reloadData()
    }
    trxRef.removeAllObservers()
    
    trxRef.observe(.childAdded) { (snapshot) in
      self.transactions.append(Transaction(snapshot: snapshot)!)
      self.table.insertRows(at: [IndexPath(row: self.transactions.count-1, section: 0)], with: .fade)
    }
    trxRef.observe(.childRemoved) { (snapshot) in
      // get index of removed row
      // remove that index from transactions (or unreconciledTransactions)
      // delete that row from the table
    }
  }
}
