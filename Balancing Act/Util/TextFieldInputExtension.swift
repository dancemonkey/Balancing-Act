//
//  TextFieldInputExtension.swift
//  Balancing Act
//
//  Created by Drew Lanning on 6/8/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import UIKit

extension UIViewController {
  func addInputAccessoryForTextFields(textFields: [UITextField], dismissable: Bool = true, previousNextable: Bool = false) {
    for (index, textField) in textFields.enumerated() {
      let toolbar: UIToolbar = UIToolbar()
      toolbar.sizeToFit()
      
      var items = [UIBarButtonItem]()
      if previousNextable {
        let previousButton = UIBarButtonItem(image: UIImage(named: "BackArrow"), style: .plain, target: nil, action: nil)
        previousButton.width = 30
        if textField == textFields.first {
          previousButton.isEnabled = false
        } else {
          previousButton.target = textFields[index - 1]
          previousButton.action = #selector(UITextField.becomeFirstResponder)
        }
        
        let nextButton = UIBarButtonItem(image: UIImage(named: "ForwardArrow"), style: .plain, target: nil, action: nil)
        nextButton.width = 30
        if textField == textFields.last {
          nextButton.isEnabled = false
        } else {
          nextButton.target = textFields[index + 1]
          nextButton.action = #selector(UITextField.becomeFirstResponder)
        }
        items.append(contentsOf: [previousButton, nextButton])
      }
      
      let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
      let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing))
      items.append(contentsOf: [spacer, doneButton])
      
      
      toolbar.setItems(items, animated: false)
      textField.inputAccessoryView = toolbar
    }
  }
}
