//
//  Constants.swift
//  Balancing Act
//
//  Created by Drew Lanning on 6/11/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import UIKit

// Constants
// + Firebase paths
// + Model object keys
// + SegueIDs
// - Fonts, colors, styles
// + Cell IDs
// - UIImage Names

struct Constants {
  
  enum FBPaths: String {
    case accounts, transactions
  }
  
  enum AccountKeys: String {
    case nickname, startingBalance, creation, currentBalance, reconciledBalance
  }
  
  enum TrxKeys: String {
     case payee, amount, trxDate, reconciled, memo, category, cleared, accountLink, deposit
  }
  
  enum UserDefaultKeys: String {
    case userID
  }
  
  enum SegueIDs: String {
    case newAccount, showAccount, accountEdit, editTransaction, showAccounts, showDatePicker
    // two are similar, rename/rethink
  }
  
  enum CellIDs: String {
    case accountCell, transactionCell
  }
  
  enum Colors: String {
    case depositColor, reconciledColor, primary, secondary, accentSuccess, accentWarning, accentError, altBlack
  }
}
