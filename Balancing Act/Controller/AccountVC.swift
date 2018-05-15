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
  var reconcileMode: Bool = false {
    didSet {
      if reconcileMode {
        unreconciledTrx = transactions.filter({ (trx) -> Bool in
          return trx.reconciled == false
        })
        table.reloadData()
        view.backgroundColor = .green
      } else {
        view.backgroundColor = .white
      }
    }
  }
  var account: Account?
  var store: Store!
  var updateIndex: Int?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = account!.nickname
    self.store = Store()
    table.delegate = self
    table.dataSource = self
    
    let thisAccountRef = account!.ref
    trxRef = thisAccountRef?.child("transactions").queryOrdered(byChild: "creation")
    observeChanges()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "editTransaction" {
      let destVC = segue.destination as! EditTransactionVC
      destVC.account = self.account!
      if let index = sender {
        destVC.transaction = self.transactions[index as! Int]
        // change array source if in reconcile mode
      }
    }
  }
  
  @IBAction func newTransaction(sender: UIBarButtonItem) {
    performSegue(withIdentifier: "editTransaction", sender: nil)
  }
  
  @IBAction func reconcileModeTapped(sender: UIBarButtonItem) {
    reconcileMode = !reconcileMode
  }
  
  func observeChanges() {
    trxRef.observe(.childAdded) { (snapshot) in
      self.transactions.append(Transaction(snapshot: snapshot)!)
      self.table.insertRows(at: [IndexPath(row: self.transactions.count-1, section: 0)], with: .fade)
    }
    trxRef.observe(.childRemoved) { (snapshot) in
      guard let index = self.indexOfTransaction(snapshot: snapshot) else { return }
      self.transactions.remove(at: index)
      self.table.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
    }
    trxRef.observe(.childChanged) { (snapshot) in
      guard let updated = self.indexOfTransaction(snapshot: snapshot) else { return }
      self.transactions[updated] = Transaction(snapshot: snapshot)!
      self.table.reloadRows(at: [IndexPath(row: updated, section: 0)], with: .fade)
    }
  }
  
  func indexOfTransaction(snapshot: DataSnapshot) -> Int? {
    if let trx = Transaction(snapshot: snapshot) {
      return self.transactions.index(where: { (transaction) -> Bool in
        return trx.key == transaction.key
      })
    }
    return nil
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
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    updateIndex = indexPath.row
    performSegue(withIdentifier: "editTransaction", sender: indexPath.row)
  }
  
}
