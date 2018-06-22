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
  @IBOutlet weak var doneBtn: UIButton!
  @IBOutlet weak var cancelBtn: UIButton!
  
  var date: Date?
  var delegate: DateSelectDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    guard let existingDate = date else { return }
    datePicker.setDate(existingDate, animated: true)
    self.title = "Select Date"
    
    doneBtn.backgroundColor = UIColor(named: Constants.Colors.primary.rawValue)
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
