//
//  DatePickerVC.swift
//  Balancing Act
//
//  Created by Drew Lanning on 6/15/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//

import UIKit

class DatePickerVC: UIViewController {
  
  @IBOutlet weak var datePicker: UIDatePicker!
  
  var date: Date?
  var delegate: DateSelectDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    guard let existingDate = date else { return }
    datePicker.setDate(existingDate, animated: true)
    self.title = "Select Date"
  }
  
  @IBAction func save(sender: UIButton) {
    let saveDate = datePicker.date
    delegate?.save(date: saveDate)
    navigationController?.popViewController(animated: true)
  }
  
  @IBAction func cancel(sender: UIButton) {
    navigationController?.popViewController(animated: true)
  }
}
