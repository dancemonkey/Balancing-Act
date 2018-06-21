//
//  FontStyleExtension.swift
//  Balancing Act
//
//  Created by Drew Lanning on 6/19/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//
// Got this from https://spin.atomicobject.com/2018/02/02/swift-scaled-font-bold-italic/

import UIKit

extension UIFont {
  func withTraits(traits:UIFontDescriptorSymbolicTraits) -> UIFont {
    let descriptor = fontDescriptor.withSymbolicTraits(traits)
    return UIFont(descriptor: descriptor!, size: 0) //size 0 means keep the size as it is
  }
  
  func bold() -> UIFont {
    return withTraits(traits: .traitBold)
  }
  
  func italic() -> UIFont {
    return withTraits(traits: .traitItalic)
  }
}
