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
  
  // TODO: Now back to integrating google sheets access so I can append/export data
  // QUESTION: Or just offer CSV export/backup, keep it simple?
  
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
    
    authUI = FUIAuth.defaultAuthUI()
    authUI.delegate = self
    authUI.providers = self.providers
    
    authController = authUI!.authViewController()
    if Auth.auth().currentUser == nil {
      accountsBtn.isEnabled = false
      logoutBtn.title = "Login"
      present(authController, animated: true, completion: nil)
    } else {
      accountsBtn.isEnabled = true
      logoutBtn.title = "Logout"
    }
    
  }
  
  @IBAction func accountsPressed(sender: UIButton) {
    performSegue(withIdentifier: "showAccounts", sender: self)
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
    }
  }
  
  // MARK: Actions
  @IBAction func signout(sender: UIBarButtonItem) {
    do {
      try authUI.signOut()
      accountsBtn.isEnabled = false
      logoutBtn.title = "Login"
      present(authController!, animated: true, completion: nil)
    } catch {
      print(error)
    }
  }
}
