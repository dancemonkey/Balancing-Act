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
  
  // TODO: labels to show updated balance and reconciled balance as you clear transactions
  
  // MARK: Outlets
  @IBOutlet weak var table: UITableView!
  @IBOutlet weak var infoView: InfoView!
  @IBOutlet weak var reconcileBtn: UIBarButtonItem!
  
  // MARK: Properties
  var trxRef: DatabaseQuery!
  var transactions: [Transaction] = []
  var unreconciledTrx: [Transaction] = []
  var reconcileMode: Bool = false {
    didSet {
      if reconcileMode {
        setUnreconciledTrx()
        view.backgroundColor = .green
        toggleInfoView()
        updateInfoView()
      } else {
        view.backgroundColor = .white
        if let acct = self.account {
          acct.setReconciledBalance()
          toggleInfoView()
          acct.resetCleared()
        }
      }
      table.reloadData()
    }
  }
  var account: Account?
  var updateIndex: Int?
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    infoView.isHidden = true
    self.title = account!.nickname
    table.delegate = self
    table.dataSource = self
    
    trxRef = account?.ref?.child("transactions").queryOrdered(byChild: "creation")
    observeChanges()
  }
  
  // MARK: Segues
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "editTransaction" {
      let destVC = segue.destination as! EditTransactionVC
      destVC.account = self.account!
      if let index = sender {
        destVC.transaction = self.transactions[index as! Int]
      }
    }
  }
  
  // MARK: Actions
  
  @IBAction func newTransaction(sender: UIBarButtonItem) {
    performSegue(withIdentifier: "editTransaction", sender: nil)
  }
  
  @IBAction func reconcileModeTapped(sender: UIBarButtonItem) {
    reconcileMode = !reconcileMode
    reconcileBtn.isEnabled = reconcileMode
  }
  
  @IBAction func reconcileCleared() {
    for trx in transactions {
      if trx.cleared {
        trx.setReconciled(to: true)
      }
    }
    setUnreconciledTrx()
    account?.resetCleared()
    table.reloadData()
  }
  
  // MARK: UI Updates
  
  func observeChanges() {
    trxRef.observe(.childAdded) { (snapshot) in
      let trx = Transaction(snapshot: snapshot)!
      self.transactions.append(trx)
      self.table.insertRows(at: [IndexPath(row: self.transactions.count-1, section: 0)], with: .fade)
    }
    trxRef.observe(.childRemoved) { (snapshot) in
      guard let index = self.indexOfTransaction(snapshot: snapshot) else { return }
      self.transactions.remove(at: index)
      self.table.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
    }
    trxRef.observe(.childChanged) { (snapshot) in
      guard let updated = self.indexOfTransaction(snapshot: snapshot) else { return }
      if !self.reconcileMode {
        self.transactions[updated] = Transaction(snapshot: snapshot)!
      }
      self.table.reloadRows(at: [IndexPath(row: updated, section: 0)], with: .fade)
    }
  }
  
  // MARK: Helper Functions
  
  func indexOfTransaction(snapshot: DataSnapshot) -> Int? {
    if let trx = Transaction(snapshot: snapshot) {
      let targetArray = reconcileMode ? unreconciledTrx : transactions
      return targetArray.index(where: { (transaction) -> Bool in
        return trx.key == transaction.key
      })
    }
    return nil
  }
  
  func setUnreconciledTrx() {
    unreconciledTrx = transactions.filter({ (trx) -> Bool in
      return trx.reconciled == false
    })
  }
  
  func toggleInfoView() {
    infoView.isHidden = !infoView.isHidden
  }
  
  func updateInfoView() {
    guard let acct = self.account else { return }
    acct.setClearedTotal { (total) in
      DispatchQueue.main.async {
        self.infoView.update(with: acct.reconciledBalance! + total)
      }
    }
  }
  
}

// MARK: Extensions

extension AccountVC: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return (reconcileMode == false) ? transactions.count : unreconciledTrx.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let trx = reconcileMode == false ? transactions[indexPath.row] : unreconciledTrx[indexPath.row]
    let cell = table.dequeueReusableCell(withIdentifier: "transactionCell") as! TransactionCell
    cell.configure(with: trx)
    return cell
  }
  
}

extension AccountVC: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if !reconcileMode {
      performSegue(withIdentifier: "editTransaction", sender: indexPath.row)
    } else {
      let trx = unreconciledTrx[indexPath.row]
      trx.toggleCleared()
      updateInfoView()
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 65.0
  }
  
}
