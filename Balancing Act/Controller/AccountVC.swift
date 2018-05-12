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
  var trxRef: DatabaseReference!
  var transactions: [Transaction] = []
  var unreconciledTrx: [Transaction] = []
  var reconcileMode: Bool = false
  var account: Account?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = account!.nickname
    
    let accountsRef = Database.database().reference(withPath: "accounts")
    let thisAccountRef = accountsRef.child(account!.key)
    trxRef = thisAccountRef.child("transactions")
    let orderedByDate = thisAccountRef.child("transactions").queryOrdered(byChild: "creation")
    
    orderedByDate.observe(.value) { (snapshot) in
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
    
    table.delegate = self
    table.dataSource = self
  }
  
  @IBAction func newTransaction(sender: UIBarButtonItem) {
    let newTrx = Transaction(payee: "Giant Eagle", amount: 99.88)
    let ref = self.trxRef.child("\(newTrx.creation)")
    ref.setValue(newTrx.toAnyObject())
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
  
}
