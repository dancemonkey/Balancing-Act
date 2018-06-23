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
import FirebaseGoogleAuthUI

class LoginVC: UIViewController, FUIAuthDelegate {
  
  // MARK: Auth Properties
  private let providers: [FUIAuthProvider] = [
    FUIGoogleAuth()
  ]
  var authController: UINavigationController!
  var authUI: FUIAuth!
  
  // MARK: Outlets
  @IBOutlet weak var accountsBtn: UIButton!
  @IBOutlet weak var logoutBtn: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setNavBarAppearance()
    
    authUI = FUIAuth.defaultAuthUI()
    authUI.delegate = self
    authUI.providers = self.providers
    
    accountsBtn.backgroundColor = UIColor(named: Constants.Colors.primary.rawValue)
    
    authController = authUI!.authViewController()
    if Auth.auth().currentUser == nil {
      accountsBtn.isEnabled = false
      logoutBtn.title = "Login"
      present(authController, animated: true, completion: nil)
    } else {
      accountsBtn.isEnabled = true
      logoutBtn.title = "Logout"
      performSegue(withIdentifier: Constants.SegueIDs.showAccounts.rawValue, sender: self)
    }
    
  }
  
  // MARK: Helper Functions
  
  func setNavBarAppearance() {
    guard let nav = navigationController else { return }
    nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    nav.navigationBar.isTranslucent = false
    nav.navigationBar.backgroundColor = UIColor(named: Constants.Colors.primary.rawValue)
    nav.navigationBar.barTintColor = UIColor(named: Constants.Colors.primary.rawValue)
    nav.navigationBar.tintColor = .white
  }
  
  // MARK: Auth Delegate
  func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
    if let err = error {
      print(err)
    } else {
      let store = Store()
      store.setUserID(to: user!.uid)
      accountsBtn.isEnabled = true
      logoutBtn.title = "Logout"
      performSegue(withIdentifier: Constants.SegueIDs.showAccounts.rawValue, sender: self)
    }
  }
  
  // MARK: Actions
  @IBAction func signout(sender: UIBarButtonItem) {
    do {
      try authUI.signOut()
      accountsBtn.isEnabled = false
      logoutBtn.title = "Login"
      let store = Store()
      store.setUserID(to: "")
      present(authController!, animated: true, completion: nil)
    } catch {
      print(error)
    }
  }
  
  @IBAction func accountsPressed(sender: UIButton) {
    performSegue(withIdentifier: Constants.SegueIDs.showAccounts.rawValue, sender: self)
  }
}
