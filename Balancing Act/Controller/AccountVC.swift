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
  
  // MARK: Outlets
  @IBOutlet weak var table: UITableView!
  @IBOutlet weak var infoView: InfoView!
  @IBOutlet weak var reconcileBtn: UIBarButtonItem!
  @IBOutlet weak var newTransaction: UIBarButtonItem!
  @IBOutlet weak var reconcileModeBtn: UIBarButtonItem!
  @IBOutlet weak var toolbar: UIToolbar!
  
  // MARK: Properties
  var trxRef: DatabaseQuery!
  var transactions: [Transaction] = []
  var unreconciledTrx: [Transaction] = []
  var reconcileMode: Bool = false {
    didSet {
      if reconcileMode {
        setUnreconciledTrx()
        view.backgroundColor = UIColor(named: Constants.Colors.depositColor.rawValue)
        updateInfoView()
        toggleInfoView()
      } else {
        view.backgroundColor = .white // UIColor(named: Constants.Colors.primary.rawValue)
        if let acct = self.account {
          acct.setReconciledBalance()
          updateInfoView()
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
    self.title = account!.nickname
    reconcileBtn.isEnabled = reconcileMode
    view.backgroundColor = .white // UIColor(named: Constants.Colors.primary.rawValue)
    table.delegate = self
    table.dataSource = self
    
    trxRef = account?.ref?.child(Constants.FBPaths.transactions.rawValue).queryOrdered(byChild: Constants.TrxKeys.trxDate.rawValue)
    observeChanges()
    
    self.toolbar.backgroundColor = .white //UIColor(named: Constants.Colors.primary.rawValue)
    self.toolbar.barTintColor = .white //UIColor(named: Constants.Colors.primary.rawValue)
    self.toolbar.isTranslucent = false
    self.infoView.backgroundColor = .clear
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateInfoView()
  }
  
  // MARK: Segues
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Constants.SegueIDs.editTransaction.rawValue {
      let destVC = segue.destination as! EditTransactionVC
      destVC.delegate = self
      destVC.account = self.account!
      if let index = sender {
        destVC.transaction = self.transactions[index as! Int]
      }
    }
  }
  
  // MARK: Actions
  
  @IBAction func newTransaction(sender: UIBarButtonItem) {
    performSegue(withIdentifier: Constants.SegueIDs.editTransaction.rawValue, sender: nil)
  }
  
  @IBAction func reconcileModeTapped(sender: UIBarButtonItem) {
    setReconcileMode()
  }
  
  @IBAction func reconcileCleared() {
    for trx in transactions {
      if trx.cleared {
        trx.setReconciled(to: true)
      }
    }
    setUnreconciledTrx()
    account?.resetCleared()
    setReconcileMode()
    table.reloadData()
  }
  
  // MARK: UI Updates
  
  func observeChanges() {
    
    trxRef.observe(.value) { (snapshot) in
      var newTrx: [Transaction] = []
      for child in snapshot.children {
        if let snapshot = child as? DataSnapshot,
          let trx = Transaction(snapshot: snapshot) {
          newTrx.append(trx)
        }
      }
      self.transactions = newTrx.reversed()
      self.table.reloadData()
    }
    
  }
  
  // MARK: Helper Functions
  
  func setReconcileMode() {
    reconcileMode = !reconcileMode
    reconcileBtn.isEnabled = reconcileMode
    newTransaction.isEnabled = !reconcileMode
  }
  
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
    infoView.recBalanceLbl.isHidden = !reconcileMode
    infoView.totalBalance.isHidden = reconcileMode
  }
  
  func updateInfoView() {
    guard let acct = self.account else { return }
    if !reconcileMode {
      self.infoView.updateBalance(with: acct.currentBalance!)
    } else {
      acct.setClearedTotal { (total) in
        DispatchQueue.main.async {
          self.infoView.updateCleared(with: acct.reconciledBalance! + total)
        }
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
    let cell = table.dequeueReusableCell(withIdentifier: Constants.CellIDs.transactionCell.rawValue) as! TransactionCell
    cell.configure(with: trx)
    return cell
  }
  
}

extension AccountVC: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if !reconcileMode {
      performSegue(withIdentifier: Constants.SegueIDs.editTransaction.rawValue, sender: indexPath.row)
    } else {
      let trx = unreconciledTrx[indexPath.row]
      trx.toggleCleared()
      tableView.reloadData()
      updateInfoView()
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 65.0
  }
  
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
      let store = Store()
      store.remove(transaction: self.transactions[indexPath.row])
      self.updateAccountBalance()
    }
    delete.image = UIImage(named: "trash3")
    
    return UISwipeActionsConfiguration(actions: [delete])
  }
  
  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    if reconcileMode {
      return UITableViewCellEditingStyle.none
    } else {
      return UITableViewCellEditingStyle.delete
    }
  }
  
}

extension AccountVC: BalanceUpdateDelegate {
  func updateAccountBalance() {
    guard let acct = self.account else { return }
    acct.setCurrentBalance { (total) in
      self.infoView.updateBalance(with: total)
    }
  }
}

