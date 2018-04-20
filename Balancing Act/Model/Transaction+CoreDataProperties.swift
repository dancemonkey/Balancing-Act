//
//  Transaction+CoreDataProperties.swift
//  Balancing Act
//
//  Created by Drew Lanning on 4/19/18.
//  Copyright © 2018 Drew Lanning. All rights reserved.
//
//

import Foundation
import CoreData


extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var type: Int16
    @NSManaged public var number: Int16
    @NSManaged public var amount: Double
    @NSManaged public var date: NSDate?
    @NSManaged public var creation: NSDate?
    @NSManaged public var category: String?
    @NSManaged public var split: Bool
    @NSManaged public var cleared: Bool
    @NSManaged public var reconciled: Bool
    @NSManaged public var splitTransactions: NSSet?
    @NSManaged public var account: Account?

}

// MARK: Generated accessors for splitTransactions
extension Transaction {

    @objc(addSplitTransactionsObject:)
    @NSManaged public func addToSplitTransactions(_ value: Transaction)

    @objc(removeSplitTransactionsObject:)
    @NSManaged public func removeFromSplitTransactions(_ value: Transaction)

    @objc(addSplitTransactions:)
    @NSManaged public func addToSplitTransactions(_ values: NSSet)

    @objc(removeSplitTransactions:)
    @NSManaged public func removeFromSplitTransactions(_ values: NSSet)

}
