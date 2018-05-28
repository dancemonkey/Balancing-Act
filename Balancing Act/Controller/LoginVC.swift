//
//  ViewController.swift
//  QuickstartApp
//
//  Created by Drew Lanning on 5/20/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

class LoginVC: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
  
  
  // If modifying these scopes, delete your previously saved credentials by
  // resetting the iOS simulator or uninstall the app.
  
  // TODO: show list of my spreadsheets in table, let me select one
  // TODO: add arbitrary data to last row of selected sheet
  // TODO: integrate all of the amazing skills I've learned into Balancing Act
  
  private let scopes = [kGTLRAuthScopeSheetsSpreadsheetsReadonly]
  
  private let service = GTLRSheetsService()
  var signInButton: GIDSignInButton?
  @IBOutlet weak var accountsBtn: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    accountsBtn.isHidden = true
    
    // Configure Google Sign-in.
    GIDSignIn.sharedInstance().delegate = self
    GIDSignIn.sharedInstance().uiDelegate = self
    GIDSignIn.sharedInstance().scopes = scopes
    if GIDSignIn.sharedInstance().hasAuthInKeychain() {
      GIDSignIn.sharedInstance().signInSilently()
      accountsBtn.isHidden = false
    } else {
      setupGIDButton()
    }
  }
  
  func setupGIDButton() {
    signInButton = GIDSignInButton(frame: CGRect(x: view.center.x - 122/2, y: view.center.y - 48/2, width: 122.0, height: 48.0))
    view.addSubview(signInButton!)
  }
  
  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
            withError error: Error!) {
    if let error = error {
      showAlert(title: "Authentication Error", message: error.localizedDescription)
      self.service.authorizer = nil
    } else {
      self.signInButton?.isHidden = true
      self.service.authorizer = user.authentication.fetcherAuthorizer()
      accountsBtn.isHidden = false
    }
  }
  
  // Helper for showing an alert
  func showAlert(title : String, message: String) {
    let alert = UIAlertController(
      title: title,
      message: message,
      preferredStyle: UIAlertControllerStyle.alert
    )
    let ok = UIAlertAction(
      title: "OK",
      style: UIAlertActionStyle.default,
      handler: nil
    )
    alert.addAction(ok)
    present(alert, animated: true, completion: nil)
  }
  
  @IBAction func accountsPressed(sender: UIButton) {
    performSegue(withIdentifier: "showAccounts", sender: self)
  }
}
